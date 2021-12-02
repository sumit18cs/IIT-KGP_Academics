
/*
Name : Avijit Mandal
Roll No. : 18CS30010
Name : Sumit Kumar Yadav
Roll No. : 18CS30042
*/

#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 
#include <stdbool.h> 
  
#define PORT    8080 
#define MAXLINE 1024 
#define ENOUGH  255

void printError(char *msg){
    fprintf(stderr, "%s\n",msg);
    fprintf(stderr, "Exiting...\n" );
}

char* retWord(int num){
    char* word = (char *)malloc(ENOUGH*sizeof(char)); 
    strcpy(word,"WORD");
    char* str = (char *)malloc(ENOUGH*sizeof(char));
    sprintf(str, "%d", num);
    strcat(word,str);

    return word;
}

int main() { 
    int sockfd; 
    char buffer[MAXLINE]; 
    struct sockaddr_in servaddr, cliaddr; 
      
    // Creating socket file descriptor 
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);

    if(sockfd < 0){
        printError("Socket creation error");
        exit(EXIT_FAILURE);
    }
      
    memset(&servaddr, 0, sizeof(servaddr)); 
    memset(&cliaddr, 0, sizeof(cliaddr)); 
      
    // Filling server information 
    servaddr.sin_family    = AF_INET; // IPv4 
    servaddr.sin_addr.s_addr = INADDR_ANY; 
    servaddr.sin_port = htons(PORT); 
      
    // Bind the socket with the server address 
    int b = bind(sockfd, (const struct sockaddr *)&servaddr,  sizeof(servaddr));
    if(b < 0){
        printError("Error in binding");
        exit(EXIT_FAILURE);
    }

    int clilen;
    int n; 
  
    clilen = sizeof(cliaddr); 

    while(true){

        n = recvfrom(sockfd, (char *)buffer,MAXLINE,0,( struct sockaddr *) &cliaddr,&clilen); 
        if(n < 0){
            printError("Error in receiving");
        }

        buffer[n] = '\0'; 
        printf("Client : %s\n", buffer);
        
        FILE *file = fopen(buffer,"r"); 
        if(file == NULL){
            char *msg = "FILE_NOT_FOUND";
            sendto(sockfd, (const char *)msg, strlen(msg),0, (const struct sockaddr *) &cliaddr,clilen);     
            fprintf(stderr, "%s\n", msg);
            continue;
        }

        char line[MAXLINE];
        fscanf(file,"%s",line);

        // if first word is not hello
        if(strcmp(line,"HELLO")!=0){
            char *msg = "WRONG_FILE_FORMAT";
            sendto(sockfd, (const char *)msg, strlen(msg),0, (const struct sockaddr *) &cliaddr,clilen); 
            fclose(file);
            printError("Wrong File Format");
        }
        // sending hello
        sendto(sockfd, (const char *)line, strlen(line),0, (const struct sockaddr *) &cliaddr,clilen); 


        int cnt = 0;

        while(true){

            cnt++;
            n = recvfrom(sockfd, (char *)buffer,MAXLINE,0,( struct sockaddr *) &cliaddr,&clilen); 
            buffer[n] = '\0'; 

            printf("Client : %s\n", buffer);

            char word[30];
            strcpy(word,retWord(cnt));

            if(strcmp(word,buffer)!=0){
                char errmsg[]="Expected WORDi format";
                char *msg = "INVALID_REQUEST";
                sendto(sockfd, (const char *)msg, strlen(msg),0, (const struct sockaddr *) &cliaddr,clilen);
                fprintf(stderr, "%s\n", errmsg);
                break;
            }

            // Checking if EOF occured without END

            if(fscanf(file,"%s",line)==EOF){
                char errmsg[]="Expected to end with END";
                char *msg = "INVALID_REQUEST";
                sendto(sockfd, (const char *)msg, strlen(msg),0, (const struct sockaddr *) &cliaddr,clilen);
                fprintf(stderr, "%s\n",errmsg);
                break;
            }

            // Closing After End

            if(strcmp(line,"END")==0){

                char *msg = "END";
                sendto(sockfd, (const char *)msg, strlen(msg),0, (const struct sockaddr *) &cliaddr,clilen);
                break;
            }

            // sending WORDi
            sendto(sockfd, (const char *)line, strlen(line),0, (const struct sockaddr *) &cliaddr,clilen);
        }
        fclose(file);
    }
      
    return 0; 
} 