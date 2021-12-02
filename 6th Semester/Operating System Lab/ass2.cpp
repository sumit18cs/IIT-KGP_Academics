// Name : Avijit Mandal
// Roll No. : 18CS30010
// Name : Sumit Kumar Yadav
// Roll No.: 18CS30042

#include<bits/stdc++.h>
#include<unistd.h>      // for fork() , exec() , pid_t 
#include<fcntl.h>
#include<sys/wait.h>    // wait()

using namespace std;

// Trims all the whitespaces  of the string
string trim(string s){
    string L, R;

    bool flag = 0;
    int sz = s.size();
    // first remove white space of right side
    for(int i = sz-1; i >= 0; i--){
        if(flag){
            R+=s[i];
        }
        else if(s[i]!=' '){
            flag = true;
            i++;
        }
    }
    reverse(R.begin(), R.end());

    // remove white space from left side
    for(int i = 0; i < R.size(); i++){
        if(R[i]!=' '){
            R = R.substr(i,INT_MAX);    // inbuilt function to extract only required substring
            break;
        }
    }

    return R;   
}

// Split the string into several ones by the delimiter
vector<string> split(string line, char check){
    vector<string>res;
    stringstream file(line);    // Create a string stream from the command
    string aux;

    // Read from the string stream till the delimiter
    while(getline(file, aux, check)){
        res.push_back(aux);
    }

    return res;
}

// Splits the command into input and ouput
vector<string> split_input_output (string line){
    vector<string>result(3);

    vector<string>temp = split(line, '<');

    if(temp.size()==1){
        vector<string>temp1 = split(line,'>');
        if(temp1.size() == 1){
            result[0] = temp1[0];
        }
        else{
            result[0] = temp1[0];
            result[2] = temp1[1];
        }
    }
    else{
        result[0] = temp[0];
        vector<string>temp2 = split(line, '>');
        if(temp2.size()==1){
            result[1] = temp[1];
        }
        else{
            temp2 = split(temp[1],'>');
            result[1]=temp2[0];
            result[2]=temp2[1];
        }
    }

    result[0] = trim(result[0]);
    result[1] = trim(result[1]);
    result[2] = trim(result[2]);

    return result;
}

// Open files and redirect input and output with files as arguments
void redirect(string inp, string out){
    if(inp.size()){
        // Open input redirecting file
        int input_file = open(inp.c_str(), O_RDONLY);
        if(input_file < 0){
            cout<<"Error opening file: "<<inp<<endl;
            exit(EXIT_FAILURE);
        }
        if(dup2(input_file, STDIN_FILENO) < 0){
            cout<<"Error redirecting file: " << inp << "\n";
            exit(EXIT_FAILURE);         
        }
    }

    if(out.size()){
        // Open output redirecting file
        int output_file = open(out.c_str(), O_CREAT | O_WRONLY, 0777);
        if(output_file < 0){
            cout<<"Error opening file: " << out << "\n";
            exit(EXIT_FAILURE);
        }

        if(dup2(output_file, STDOUT_FILENO) < 0){
            cout<<"Error redirecting file: " << out << "\n";
            exit(EXIT_FAILURE); 
        }
    }
}

// Execute the commands
void execute_command(string line){
    vector<string> vec_string;

    //split the command into arguments
    for(auto tmp:split(line,' ')){
        vec_string.push_back(tmp);
    }
    int vec_string_size = (int)vec_string.size();

    // Create a char* array for the arguments
    char *arguments[vec_string_size+1];
    arguments[vec_string_size] = NULL;  // end with null pointer

    for(int i = 0; i < vec_string_size; i++){
        arguments[i] = const_cast<char*>(vec_string[i].c_str());        //convert string to char *
    }

    execvp(arguments[0],arguments); // a.out, ls, sort, uniq 
}
//Main Function
int main()
{
    string line;
    while(true)
    {
        bool background_process = false; // flag for background running

        // Get input command
        cout<<" Enter_Command> ";
        getline(cin, line); // input string

        // erase whitespaces 
        line = trim(line);

        // consider of the background process
        if( line.back() == '&'){
            background_process = true;
            line.back() = ' ';
        }

        // Split into several commands wrt to |
        vector<string> command_list = split(line, '|');

        // If no pipes are required
        if(command_list.size()==1)
        {
            // Split the commands and redirection
            vector< string > res = split_input_output(command_list[0]);
            pid_t pid;
            pid = fork();
            if(pid == 0)
            {
                //child process
                redirect(res[1],res[2]); // Redirect input and output
                execute_command(res[0]); // Execute the command
                exit(0); // Exit the child process  only if error occur
            }
            else if(pid<0){
                //Error forking 
                perror("Error!!");
                return 1;
            }

            if(background_process == false){
                wait(NULL);
            }
        }

        else
        {
            int n=command_list.size(); // No. of pipe commands
            int current[2], previous[2];

            for(int i=0; i<n; i++)
            {
                vector<string> res = split_input_output(command_list[i]);
                if(i!=n-1){                 // Create new pipe except for the last command
                    pipe(current);
                }
                
                pid_t pid = fork();          // Fork for every command

                // In the child process
                if(pid == 0)
                {
                    if( i==0 || i==n-1){
                        redirect(res[1], res[2]);  // For the first and last command redirect the input output files
                    }

                    // Read from previous command for everything except the first command
                    if(i!=0){
                        dup2(previous[0],0);
                        close(previous[0]);
                        close(previous[1]);
                    }

                    // Write into pipe for everything except last command
                    if(i!=n-1){
                        close(current[0]);
                        dup2(current[1],1);
                        close(current[1]);
                    }

                    // Execute command
                    execute_command(res[0]);
                    exit(0);    // Exit the child process  only if error occur
                }

                // In parent process
                if(i!=0){
                    close(previous[0]);
                    close(previous[1]);
                }
                
                // Copy current into previous for everything except the last process
                if(i!=n-1){
                    previous[0] = current[0];
                    previous[1] = current[1];
                }
            }

            // If no background, then wait for all child processes to return
            if(background_process == false){
                while( wait(NULL) > 0);
            }
        }
    }
}