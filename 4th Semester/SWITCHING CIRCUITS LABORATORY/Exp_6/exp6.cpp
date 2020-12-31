//Sumit kumar yadav : 18CS30042
//Avijit Mandal : 18CS30010

// int main()
// {
//     ios_base::sync_with_stdio(false);
//     cin.tie(0);cout.tie(0);

//     int t;
//     cin>>t;
//     //t=1
//     while(t--){
//       cout<<t<<"\n";
//     }
// } 



#include<bits/stdc++.h>
#include<stdio.h>
#include <list>
#include<stdlib.h>
using namespace std;
#define ll long long int
#define F first
#define S second
#define pb push_back
#define YES 'Y'
#define NO 'N'
#define INCOMPLETE 2
#define NOTVIEWED 3
ifstream input;
ofstream verilog;


int no_inputs,no_outputs,no_states;
int** state_chart;
int** output_chart;
char merger_table[6][6][100];
int no_of_nodes = 0;
struct node{
  char name[3];
  int count = 2;
  bool marked = false;
};
int n;
list <struct node> nodes;
list <struct node> compatibility_list;
int encode(int n1,int n2)
{
	int ans=0;
	for(int i=0;i<n1;i++)
	{
		ans+=(n-1-i);
	}
	ans+=(n2-n1-1);

	return ans;
}

pair<int,int> decode(int a)
{
	pair<int,int> ans = make_pair(0,0);

	for(int i=0;i<n;i++)
	{
		a-=(n-1-i);
		if(a<0)
		{
			a+=(n-1-i);
			break;
		}
		ans.F++;
	}
	ans.S = ans.F+1+a;
	return ans;
}

void push_front(struct node temp){
  list<struct node>::iterator it = nodes.begin();
  for(int i=0;i<no_of_nodes;i++){
    if((*it).name[0]==temp.name[0]&&(*it).name[1]==temp.name[1]) return;
    advance(it,1);  
  }
  nodes.push_front(temp);
  no_of_nodes++;
}

void DFS(bool** adj_mat,int node_no,struct node temp,int no_of_nodes){
  
  compatibility_list.push_back(temp);
  list<struct node>::iterator it = nodes.begin();
  for(int i=0;i<no_of_nodes;i++){
    if(adj_mat[node_no][i]==true){
      (*it).marked = true;
      DFS(adj_mat,i,*it,no_of_nodes);
    }
    advance(it,1);
  }
}

bool check_compatibility(int i,int j){
  if(i>j){
    int temp = i;
    i = j;
    j = temp;
  }
  if(i<0||j<0||merger_table[i][j][0]==YES||merger_table[i][j][0]==INCOMPLETE) return true;
  if(merger_table[i][j][0]==NO) return false;
  if(merger_table[i][j][0]==NOTVIEWED){
    bool temp = false;
    int r = 1;
    merger_table[i][j][0] = YES;
    for(int k=0;k<no_inputs;k++){
      if(output_chart[i][k]==output_chart[j][k]||output_chart[i][k]<0||output_chart[j][k]<0){
        
        if(check_compatibility(state_chart[i][k],state_chart[j][k])){
          if(state_chart[i][k]>=0 && state_chart[j][k]>=0&&state_chart[i][k]!=state_chart[j][k]&&(state_chart[i][k]!=i||state_chart[j][k]!=j)&&(state_chart[i][k]!=j||state_chart[j][k]!=i)){
            if(state_chart[i][k]<state_chart[j][k]) {
              struct node temp;
              temp.name[0] = 'A' + state_chart[i][k];
              temp.name[1] = 'A' + state_chart[j][k];
              temp.name[2] = '\0';
              merger_table[i][j][r++] = 'A' + state_chart[i][k];
              merger_table[i][j][r++] = 'A' + state_chart[j][k];
              merger_table[i][j][r++] = ',';
              push_front(temp);
              
            }
            else{
              struct node temp;
              temp.name[0] = 'A' + state_chart[j][k];
              temp.name[1] = 'A' + state_chart[i][k];
              temp.name[2] = '\0';
              merger_table[i][j][r++] = 'A' + state_chart[j][k];
              merger_table[i][j][r++] = 'A' + state_chart[i][k];
              merger_table[i][j][r++] = ',';
              push_front(temp);
              
            }
            
          }

        }
        else temp = true;
      }
      else{
        temp = true;
      }
    } 
    if(temp){
      merger_table[i][j][0] = NO;
      merger_table[i][j][1] = '\0';
      return false;
    }
    else{
      merger_table[i][j][0] = YES;
      merger_table[i][j][r] = '\0'; 
    }
  }
}



int main() {

	input.open("m1.txt");
	verilog.open("verilog1.v");
  cin >> no_states;
  cin >> no_inputs;
  char map_input[no_inputs][100];
  for(int i=0;i<no_inputs;i++){
    cin >> map_input[i];
  }
  char map_output[no_outputs][100];
  cin >> no_outputs;
  for(int i=0;i<no_outputs;i++){
    cin >> map_output[i];
  }
  
  state_chart = new int*[no_states];
  for(int i=0;i<no_states;i++){
    
    state_chart[i] = new int[no_inputs];
    
  }
  output_chart = new int*[no_states];
  for(int i=0;i<no_states;i++){
    
    output_chart[i] = new int[no_inputs];
    
  }
  
  //Get input FSM table
  for(int i=0;i<no_states;i++){
    for(int j=0;j<no_inputs;j++){
      cin >> state_chart[i][j];
      state_chart[i][j]--;
      cin >> output_chart[i][j];
      output_chart[i][j]--;

    }
  }
  char ***merger_table = new char**[no_states];
  for(int i=0;i<no_states;i++){
    
    merger_table[i] = new char*[no_states];
    for (int j=0;j<no_states;j++)
    {
      merger_table[i][j] = new char[100];
    }
  }
  
  //Initialise merger table
  cout << endl <<endl;
  cout << "Merger table :- " <<endl;
  cout << endl;
  for(int i=0;i<no_states;i++){
    
    for(int j=0;j<no_states;j++){
      if(i>=j){
        merger_table[i][j][0] = YES;
      }
      else{
        merger_table[i][j][0] = NOTVIEWED;
      }
      merger_table[i][j][1] = '\0';
    }
  }
  
  //Form merger table
  for(int i=0;i<no_states;i++){
    for(int j=i+1;j<no_states;j++){
      check_compatibility(i,j);
    }
  }
  for(int i=1;i<no_states;i++){
    cout << (char)('A' + i) << '\t';
    for(int j=0;j<i;j++){
      cout << merger_table[j][i] << '\t';
    }
    cout << endl;
  }
  for(int i=0;i<no_states-1;i++){
    cout << ' ' << '\t' << (char)('A' + i);
  }
  cout <<endl;

  //Display all nodes
  cout << endl <<endl;
  cout << "The adjacency matrix is :-" <<endl;
  cout << endl;
  list<struct node>::iterator it = nodes.begin();
  cout << '\t';
  for(int i=0;i<no_of_nodes;i++){
    cout << (*it).name << '\t';
    advance(it,1);
  }


  //Adjacency matrix
  list<struct node>::iterator it_i = nodes.begin();
  bool **adj_mat;
  adj_mat = (bool **)malloc(no_of_nodes*sizeof(bool*));
  for(int i=0;i<no_of_nodes;i++) adj_mat[i] = (bool*) malloc(no_of_nodes*sizeof(bool));
  for(int i=0;i<no_of_nodes;i++){
    list<struct node>::iterator it_j = nodes.begin();
    for(int j=0;j<no_of_nodes;j++){
      int k=1;
      adj_mat[i][j] = false;
      while(merger_table[(*it_i).name[0]-'A'][(*it_i).name[1]-'A'][k]!='\0'){
        if(merger_table[(*it_i).name[0]-'A'][(*it_i).name[1]-'A'][k]==(*it_j).name[0]&&merger_table[(*it_i).name[0]-'A'][(*it_i).name[1]-'A'][k+1]==(*it_j).name[1]){
          adj_mat[i][j] = true;
          break;
        }
        k++;
      }
      advance(it_j,1);
    }
    advance(it_i,1);
  }
  cout << endl;
  it = nodes.begin();
  for(int i=0;i<no_of_nodes;i++){
    cout << (*it).name << '\t';
    for(int j=0;j<no_of_nodes;j++){
      cout << adj_mat[i][j] << '\t' ;
    }
    cout << endl;
    advance(it,1);
  }
  
  //Form the merged nodes
  bool temp = true;
  while(temp){
    it = nodes.begin();
    for(int i=0;i<no_of_nodes;i++){
      //printing the compatible lists
      compatibility_list;
    }
  }
  return 0;
}
