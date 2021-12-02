#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/wait.h>
#include <errno.h>
#include <iostream>
#include <string>
#include<bits/stdc++.h>
#include <arpa/inet.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>
#include <netdb.h>
#include <unistd.h>
#include <fstream>
#define TIMEOUT 100 																		//Second after a user has to timeout
#define lli long long
using namespace std;

#define STDIN 0


const int MAX_SIZE = 100000;
const int MAX_USER = 5;
int ID; 



void update_userID(int port){

	long long all_port[] = {4000, 5000, 6000, 7000, 8000};
	for(int i = 0; i < MAX_USER; i++){
		if(port == all_port[i])
		{
			ID = i;
		}
	}
}     																				// To get Track of it's own user ID

int findUserByName(char user_name[], char user[MAX_USER][MAX_SIZE])
{
	int res = 0;
	while(strcmp(user_name,user[res]) != 0)
	{
		res++;
	}
	return res;
}

void error( char *msg ){
		perror(msg);
		exit(-1);
}

int main(int argc,char *argv[])
{

	int serverfd;
	int clilen;
	int port;
	int opt = 1;

	if(argc < 2)
	{
		printf("Insufficient arguments provided\n");
		exit(1);
	}
	port = atoi(argv[1]);

	update_userID(port); 															// Updating its ID

	struct sockaddr_in server_addr, client_addr;
	bzero((char *) &server_addr, sizeof(server_addr));
	bzero((char *) &client_addr, sizeof(client_addr));
	clilen = sizeof(client_addr);

	struct timeval tv;
	tv.tv_sec = 0;
    tv.tv_usec = 200;

	char user[MAX_USER][MAX_SIZE];
	struct sockaddr_in user_addresses[MAX_USER];

	int client_fd[MAX_USER];

	for (int i=0;i < MAX_USER;i++){
		bzero((char *) &user_addresses[i], sizeof(user_addresses[i]));
	}

	// Table to track of the User Details

	// NAMES
	user[0][0] = 'A'; user[0][1] = '\0';
	user[1][0] = 'B'; user[1][1] = '\0';
	user[2][0] = 'C'; user[2][1] = '\0';
	user[3][0] = 'D'; user[3][1] = '\0';
	user[4][0] = 'E'; user[4][1] = '\0';

	// PORT
	user_addresses[0].sin_port = htons(4000);
	user_addresses[1].sin_port = htons(5000);
	user_addresses[2].sin_port = htons(6000);
	user_addresses[3].sin_port = htons(7000);
	user_addresses[4].sin_port = htons(8000);

	// ADDR
	/* As working on same computer we are making every IP 127.0.0.1 */


	lli last_communication[5];													// To get Track of last communicated Time
	memset(last_communication, -1, sizeof(last_communication));					// intializing with -1

	serverfd = socket(AF_INET, SOCK_STREAM, 0);				
	if( serverfd < 0){
		error ((char *)"tcp Socket creation failed ");
	}
	// set server address

	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(port);
	server_addr.sin_addr.s_addr = INADDR_ANY;

	// bind socket to server address
	if( bind(serverfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0){
		close(serverfd);
		perror("tcp Binding failed");
		
	}

	listen (serverfd, MAX_USER); 												// listen to at max MAX_SIZE connections
	
	printf("Server Running %s\n", user[ID]);

	fd_set fd_read;																// set of fds
	FD_ZERO(&fd_read);
	struct hostent *temp;
	temp = gethostbyname(argv[2]); 												// 127.0.0.1

	for(int i = 0; i < MAX_USER ; i++)											// Assigning IP for evry USER, i.e copying temp in sin_addr
	{

		client_fd[i]= -1;
		user_addresses[i].sin_family = AF_INET;
		bcopy((char *)temp->h_addr, 
         (char *)&user_addresses[i].sin_addr.s_addr,
         temp->h_length);
	}

	
	int max = 0;
	int conn_count =0 ;
	char input[MAX_SIZE];

	while(1)
	{

		FD_SET( STDIN, &fd_read);
		FD_SET( serverfd, &fd_read);
		max = serverfd;

		for(int i = 0; i < MAX_USER ; i++)
		{
			lli absolute_time = 0;
			if(client_fd[i] != -1)
				absolute_time = time(NULL)-last_communication[i];

			if(absolute_time >= TIMEOUT)
			{
				cout<<"User Timedout"<<endl;
				last_communication[i] = -1;
				client_fd[i] = -1;
			}	


			if(client_fd[i] != -1)
				FD_SET( client_fd[i], &fd_read);

			if(client_fd[i] != -1)
			{
				if(max < client_fd[i])
				{
					max = client_fd[i];
				}
			}
		}

		if(select(max + 1, &fd_read, NULL, NULL, &tv) < 0)
		{
			perror("Select failed");
		}

		if(FD_ISSET(STDIN, &fd_read))
		{
			for( int l = 0; l < MAX_SIZE; l++)
			{
				input[l] = '\0';
			}

			int no_chars = read(STDIN,input,sizeof(input));
			char client_name[MAX_SIZE];
			int k = 0;
			while(input[k]!='/')
			{
				client_name[k] = input[k];
				k++;
			}

			client_name[k] = '\0';
			k++;
			char input_msg[MAX_SIZE];

			for(int i=k;i<MAX_SIZE;i++)
			{
				input_msg[i-k]=input[i];
			}
			
			k = 0;
			k = findUserByName(client_name, user);

			if(k >= MAX_USER)
			{
				error((char *)"ERROR! User Not Found");
				goto DONE;
			}

			if(client_fd[k] < 0){

				client_fd[k] = socket(AF_INET, SOCK_STREAM, 0);

			    if (client_fd[k] < 0) 
			    {
			        error((char *)"ERROR! error in opening socket");
			    }
			    if (connect(client_fd[k],(struct sockaddr *) &user_addresses[k],sizeof(user_addresses[k])) < 0) 
			    {
			        error((char *)"ERROR! error in connecting");
			    }

			    char id[2];
				id[0] = ID+'0';
				id[1] = '\0';
				send(client_fd[k], id, strlen(id)+1, 0);								// SENDS THE IDENTIRY OF CLIENT ID
			}

			int send_flag = send(client_fd[k],input_msg,strlen(input_msg), 0);
			last_communication[k] = time(NULL);											// UPDATING THE LAST COMMUNICATION TIME							
    		
    		if (send_flag < 0) 
    		{
         		error((char *)"ERROR! error in writing in socket");
    		}
    
		}

		DONE:
		;

		if(FD_ISSET(serverfd, &fd_read))
		{

			struct sockaddr_in clientaddr;
			int clientlen = sizeof(clientaddr);
			int new_user_fd = accept(serverfd,(struct sockaddr *)&clientaddr,(socklen_t*)&clientlen);


			if(new_user_fd == -1){
				perror("ERROR! error in accepting");
			}

			char id[2];																// recieving the ID of sender
			recv(new_user_fd, id, strlen(id)+1, 0);

			int index = id[0]-'0';
			client_fd[index] = new_user_fd;
			last_communication[index] = time(NULL);							

			char addr[100]; 
            inet_ntop(AF_INET, &(clientaddr.sin_addr), addr, 100);
			printf("SUCCESS! Connection Established with %s\n",addr);

		}

		for( int i = 0; i < MAX_USER; i++)
		{ 
			if(FD_ISSET(client_fd[i], &fd_read))
			{
				char buffer[MAX_SIZE];
				for( int ind = 0; ind<MAX_SIZE; ind++)
				{
					buffer[ind] = '\0';				// intialize buffer to null
				}

				int len = recv(client_fd[i], buffer, sizeof(buffer), 0);	// recv from browser i
				last_communication[i] = time(NULL);

				if(len < 0 or len == 0)
				{
					if(len < 0)
						perror("ERROR! Reading failed from Browser");
					if(len == 0)
						continue;
				}

				printf("From: %s\nMessage: %s",user[i], buffer);
			}
		}
	}
}