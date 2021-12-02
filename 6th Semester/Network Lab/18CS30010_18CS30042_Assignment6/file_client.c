/*
Name : Avijit Mandal
Roll No. : 18CS30010
Name : Sumit Kumar Yadav
Roll No. : 18CS30042
*/

#include <stdio.h> // standard input output
#include <sys/types.h> // father to below 2
#include <sys/socket.h> 
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <netdb.h> 
#include <sys/stat.h>
#include <fcntl.h>


void error(const char * msg){
	printf("%s\n",msg);
	exit(1);
}

bool isdelimeter(char ch){
	return ch==' '|| ch=='\t' || ch=='.' || ch==':' || ch==';' || ch == '\n' || ch == ','; 
}

int main(int argc, char const *argv[])
{
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;

	char buff[100];
	// if(argc < 3){
	// 	error("Provide all Details");
	// }

	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if(sockfd < 0){
		error("error in generating socket");
	}

	portno = 8080;//atoi("8080");
	server = gethostbyname("127.0.0.1");

	if(server == NULL){
		error("Error, no such host");
	}

    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, 
         (char *)&serv_addr.sin_addr.s_addr,
         server->h_length);
    serv_addr.sin_port = htons(portno);

    n = connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr));
    if(n < 0){
    	error("ERROR connecting");
    }

    int word = 0;
    char c;

    printf("Enter File Name\n");

    char file_name[100];
    scanf("%s", file_name);

    send(sockfd, file_name, strlen(file_name),0);

	int fout = open("received.txt", O_TRUNC|O_CREAT|O_WRONLY, 0777);
	if(fout < 0){
		error("Error in creating file");
	}
	int size1;
    int cntW = 0, cntB = 0;
    bool wordRunning = false;
    bool inside = false;
    int cnt = 0;

    for (int i = 0; i < 15; ++i)
    {
    	buff[i] = '$';
    }

    for (int i = 0; i < 15; ++i)
    {
    	buff[i] = '$';
    }

    bool blank = true;
    bool d = false;
    while(true){
    	size1 = recv(sockfd,buff,sizeof(buff),0);    	if(size1 == 0) break;
    	d = true;

    	cnt++;
    	if(buff[0] == '$')break;
		buff[size1]='\0';
		blank = false;
		inside = true;
		int ind = 0;
		while(buff[ind] != '\0'){

			char ch = buff[ind];
			if(ch == '$')break;
			cntB++;
			// printf("%c",ch);
			write(fout,&ch,1);

	    	if(isdelimeter(ch) == false){
				wordRunning = true;
			}
			else{
				if(wordRunning){
					cntW++;
					wordRunning = false;
					// printf("\n+++word end: %c +++++\n",ch );
				}
			}
			ind++;
		}

	}

	if(d == false){
		printf("ERR 01: File Not Found\n");
		close(sockfd);
		close(fout);
		exit(1);
	}

	if (wordRunning)
	{
		cntW++;
	}
	if (inside || blank)
	{
		printf("The file transfer is successful. Size of the file = %d bytes, no. of words = %d\n",cntB, cntW);
	}

    close(sockfd);
	close(fout);


    return 0;
}