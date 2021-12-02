
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
#include <sys/stat.h>
#include <fcntl.h>

#define SIZE 100
#define BLOCKSIZE 10

void error(const char * msg){
	printf("%s\n",msg);
	exit(1);
}

int main(int argc, char const *argv[]){

	int sockfd, newsockfd, portno, n;

	char buff[SIZE];

	struct sockaddr_in serv_addr, cli_addr;
	socklen_t clilen;

	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if(sockfd < 0){
		error("Error in opening Socket");
	}

	bzero((char *)&serv_addr, sizeof(serv_addr)); // clears server address
	portno = 8082; // hardcode 8080


	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(portno);

	n = bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));

	if(n < 0){
		error("Binding Failed");
	}

	listen(sockfd, 5); // maximum number of clients that can connect to a server at a time
	clilen = sizeof(cli_addr);

	newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);
	if(newsockfd < 0){
		error("Error on Accept");
	}
	bzero(buff, SIZE);

	n = read(newsockfd, buff, SIZE); // file name read

	int fd = open(buff,O_RDONLY);

	printf("%s\n", buff);

	if(fd < 0){

		strcpy(buff,"E");
		send(newsockfd, buff, strlen(buff), 0);

		printf("FILE NOT EXIST\n");
		close(newsockfd);
		close(sockfd);
		exit(0);
	}

	struct stat st;
	stat(buff, &st);
	int filesize = st.st_size;	

	int complete_block = filesize / BLOCKSIZE;
	int sz_last_block = filesize % BLOCKSIZE;

	strcpy(buff,"E");
	send(newsockfd, buff, strlen(buff), 0);

	send(newsockfd,&filesize,sizeof(filesize),0);


	while( (n = read(fd,buff,BLOCKSIZE)) > 0){
		send(newsockfd, buff, n, 0);
	}

	int total = complete_block + ((sz_last_block > 0)?1:0);
	close(fd);
	
	return 0;
}