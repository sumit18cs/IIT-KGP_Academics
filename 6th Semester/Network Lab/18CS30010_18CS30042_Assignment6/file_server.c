
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

#define server_buff_size 10

void error(const char * msg){
	printf("%s\n",msg);
	exit(1);
}

int main(int argc, char const *argv[])
{
	// if(argc < 2){
	// 	fprintf(stderr, "Port No Provided. Programming Terminated\n");
	// 	exit(1);
	// }

	int sockfd, newsockfd, portno, n;

	char buff[100];

	struct sockaddr_in serv_addr, cli_addr;
	socklen_t clilen;

	sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if(sockfd < 0){
		error("Error in opening Socket");
	}

	bzero((char *)&serv_addr, sizeof(serv_addr)); // clears server address
	portno = 8080; // hardcode 8080


	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(portno);

	n = bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr));

	if(n < 0){
		error("Binding Failed");
	}

	listen(sockfd, 5); // maximum number of clients that can connect to a server at a time
	clilen = sizeof(cli_addr);

	while(true){

		newsockfd = accept(sockfd, (struct sockaddr *)&cli_addr, &clilen);
		if(newsockfd < 0){
			error("Error on Accept");
		}
		bzero(buff, 100);

		n = read(newsockfd, buff, 100); // file name read

		int fd = open(buff,O_RDONLY);

		if(fd < 0){
			printf("FILE NOT EXIST\n");
			close(newsockfd);
			close(fd);
			continue;
		}

		for (int i = 0; i < 100; ++i)
		{
			buff[i] = '$';
		}

		// int cnt = 0;
		// char stcon[] = "$#start#$";

		// send(newsockfd, stcon, strlen(stcon), 0);
		while(true){
			// cnt++;
			// starting to write code for communication 
			// n = read(fd, &ch, 1); // when connection is closed
			n = read(fd, buff, server_buff_size);

			if(buff[0] == '$' || n==0){
				break;
			}
			// write(newsockfd, &ch, 1);
			// printf("%c",ch );
			send(newsockfd, buff, server_buff_size, 0);
			buff[n] = '\0';
			// printf("%d. %s\n",cnt, buff);
			for (int i = 0; i < server_buff_size; ++i)
			{
				buff[i] = '$';
			}
		}

		close(newsockfd);
		close(fd);
		printf("Connection Closed : File Transfer Done\n");

	}
	close(sockfd);

	return 0;
}
