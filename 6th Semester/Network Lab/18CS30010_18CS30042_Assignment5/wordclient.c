/*
Name : Avijit Mandal
Roll No. : 18CS30010
Name : Sumit Kumar Yadav
Roll No. : 18CS30042
*/

// Header files
#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h>
#include <stdbool.h> 

  
#define PORT 8080
#define MAXLINE 1024   // maximum length of the message 
#define MAXI 100        // maximum length of the name of input file name
#define ENOUGH 255

void printError(char *msg){
    fprintf(stderr, "%s\n",msg);
    fprintf(stderr, "Exiting...\n" );
    exit(EXIT_FAILURE);
}

char* retWord(int num){
    char* word = (char *)malloc(ENOUGH*sizeof(char)); 
    strcpy(word,"WORD");
    char* str = (char *)malloc(ENOUGH*sizeof(char));
    sprintf(str, "%d", num);
    strcat(word,str);

    return word;
}

int main()
{
      int sockfd;  // socket file dexcriptor declaration
      struct sockaddr_in servaddr;

      char buffer[MAXLINE];
      char file_name[MAXI]; 

      // Creating socket file descriptor for receiving socket
      sockfd = socket(AF_INET, SOCK_DGRAM, 0);
      if ( sockfd < 0 ) { 
            perror("Socket creation failed"); 
            exit(EXIT_FAILURE); 
      } 
      
      // Initialize all the components of each of the servaddr structure as 0
      memset(&servaddr, 0, sizeof(servaddr)); 
      
      // Configuring server Address information 
      servaddr.sin_family = AF_INET;     //IPv4
      servaddr.sin_port = htons(PORT);    
      servaddr.sin_addr.s_addr = INADDR_ANY; 
      
      printf("Enter the File name i.e, file.txt\n");
      scanf("%s", file_name);

      int n; 
      socklen_t len; 
      
      // File Name Sent to the Server
      sendto(sockfd, (const char *)file_name,strlen(file_name),0,(const struct sockaddr *) &servaddr,sizeof(servaddr)); 
    
      len = sizeof(servaddr);
      n = recvfrom(sockfd, (char *)buffer,MAXLINE,0,(struct sockaddr *)&servaddr,&len); 
      buffer[n] = '\0'; 

      // Error checking
      if(strcmp(buffer,"WRONG_FILE_FORMAT") == 0){
            printError("Wrong File Format");
      }
      if(strcmp(buffer,"FILE_NOT_FOUND") == 0){
            printError("File Not Found");
      }
      
      printf("Server : %s\n", buffer); 

      if(strcmp(buffer,"HELLO")==0)
      {
            // Hello received
            FILE *file = fopen("output.txt","w");   // output will store in this file

            // requesting word[i]
            int cnt = 0;
            while(true){
                  cnt ++;
                  char word[30];
                  strcpy(word,retWord(cnt));

                  printf("requesting %s\n",word);
                  sendto(sockfd, (const char *)word,strlen(word),0,(const struct sockaddr *) &servaddr,sizeof(servaddr)); 

                  len = sizeof(servaddr);
                  n = recvfrom(sockfd, (char *)buffer,MAXLINE,0,(struct sockaddr *)&servaddr,&len); 
                  buffer[n]='\0';

                  printf("Server : %s\n", buffer); 

                  if(strcmp(buffer,"INVALID_REQUEST") == 0){
                      fprintf(stderr, "Incorrect Request\n");
                      fclose(file);
                      break;
                  }

                  if(strcmp(buffer,"END") == 0){
                      fclose(file);
                      break;
                  }
                  fprintf(file,"%s\n",buffer);
            }
      }
      close(sockfd); 
      return 0; 
}