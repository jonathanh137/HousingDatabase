#include<stdio.h>
#include<stdlib.h>
#include<string.h>   
#include<sys/socket.h>
#include<arpa/inet.h>
#include <netinet/in.h>
#include <netdb.h>
 
int main(int argc , char *argv[])
{
	int sockfd;
	struct hostent *server_addr = gethostbyname(argv[1]);
	struct sockaddr_in server;
     
    	//Create socket
    	sockfd = socket(AF_INET , SOCK_STREAM , 0);
	if (sockfd == -1)
    	{
        	printf("Could not create socket");
    	}
         
    	bcopy((char*)server_addr->h_addr, (char*)&server.sin_addr, server_addr->h_length);
    	server.sin_family = AF_INET;
    	server.sin_port = htons( 8888 );
 
    	//Connect to remote server
    	if (connect(sockfd , (struct sockaddr *)&server , sizeof(server)) < 0)
    	{
        	printf("connect error\n");
        	return 1;
    	}
	char server_reply[1024];
     	//Receive a reply from the server
    	if( recv(sockfd, server_reply , 1024 , 0) < 0)
    	{
        	printf("recv failed\n");
    	}
    	printf("%s\n",server_reply);
    	while(1) 
    	{
		char array[1024];
		char buffer[1024];
		//Send some data
		printf("Enter command: ");
		fgets(array, 1024, stdin);
		if(strcmp(array, "help\n") == 0) //User gets help command
			printf("HELP COMMANDS:\n pingSites <argv[0]>, <argv[1]>, ...\n showHandles\n showHandleStatus <handle>\n showHandleStatus\n exit\n help\n");
		else if(strcmp(array, "exit\n") == 0) //User exits client
		{
			printf("You have exited\n");
			break;
		}
		else	//send command to server
    		{
			if( send(sockfd , array , sizeof(array) , 0) < 0)
    			{
        			printf("Send failed\n");
        			return 1;
    			}
			//Receive a reply from the server
    			if( recv(sockfd, buffer , 1024 , 0) < 0)	
        			printf("recv failed\n");
			printf("%s\n",buffer);
		}
     	}
	close(sockfd);
    	return 0;
}