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

#define SIZE 100
#define BLOCKSIZE 10

void error(const char * msg){
	printf("%s\n",msg);
	exit(1);
}


int main(int argc, char const *argv[])
{
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;

	char buff[SIZE];

	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if(sockfd < 0){
		error("error in generating socket");
	}

	portno = 8082;//atoi("8080");
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
    char filename[SIZE];

    printf("Enter file name: ");
	scanf("%[^\n]s", filename);

	send(sockfd, filename, strlen(filename),0);

	recv(sockfd, buff, sizeof(char), MSG_WAITALL);

	if(strcmp(buff,"E") == 0){
		printf("File Not Found in Server Side\n");
		close(sockfd);
		exit(0);
	}

	strcpy(filename, "recieved.txt");
	int fp = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);


	int filesize;
	n = recv(sockfd, &filesize, sizeof(int), MSG_WAITALL);

	int complete_block = filesize / BLOCKSIZE;
	int sz_last_block = filesize % BLOCKSIZE;

	for(int i = 1; i <= complete_block ; i++){
		n = recv(sockfd, buff, BLOCKSIZE, MSG_WAITALL);
		write(fp,buff,n);
	}
	n = recv(sockfd,buff, sz_last_block, MSG_WAITALL);
	write(fp,buff,n);

	int total = complete_block + ((sz_last_block > 0)?1:0);
	close(fp);
	printf("The file transfer is successful. Total number of blocks received = %d, Last block size = %d\n", total, sz_last_block);

    return 0;
}
