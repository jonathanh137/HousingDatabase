#include <stdio.h>
#include <string.h>    
#include <stdlib.h>    
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>    
#include <pthread.h>
#include <sys/time.h>
#include <time.h>
#include <regex.h>
 
//used to store website information
struct webPage 
{
	int handle;
	char webURL[20];
	double avgtime;
	double mintime;
	double maxtime;
	char status[10];
};

//global variables
struct webPage sitePinged[100];
int numSites = 0;
int needping = 0;
int hcount = 0;

//This will handle connection for each client
void *handle_thread(void *sockfd)
{
    	//Get the socket descriptor
    	int sock = *(int*)sockfd;
    	int read_size;
	char *p[10];
     	char array[1024];
	char buffer[1024];
	char tempString[1024];
	regex_t regtext;
	char regexp[50];
	strcpy(regexp,"[a-zA-Z0-9_\\-]\\.[a-zA-Z0-9_\\-]");	//filters out some invalid inputs
	if(regcomp(&regtext,regexp,0) != 0)
	{	
		printf("regex invalid\n");	
		return 0;
	}
    	//Receive a message from client
    	while( (read_size = recv(sock , buffer, 1024 , 0)) > 0 )
    	{	
		int i = 0;
		int j = 0;
		char *temp = NULL;
		temp = strtok(buffer, "\n");
        	if(temp != NULL)
		{	
			if(strcmp(temp, "showHandles") == 0) 		// showHandles command
			{
				strcpy(array, "Handles: ");
				if(hcount == 0)
					strcat(array, "None\n");
				else
				{
					for(j = 1; j <= hcount; j++)
					{
						snprintf(tempString, sizeof(tempString), "%i ", j);
						strcat(array, tempString);
					}
					strcat(array, "\n");
				}
			}
			else if(strcmp(temp, "showHandleStatus") == 0) 		//showHandleStatus command
			{	
				strcpy(array, "\0");
				if(numSites == 0)
					strcpy(array, "No handle requests");
				else
				{
					for(j = 0; j < numSites; j++)
					{
						snprintf(tempString, sizeof(tempString), "%i %s %.5f %.5f %.5f %s\n", sitePinged[j].handle, sitePinged[j].webURL, sitePinged[j].avgtime, sitePinged[j].mintime, sitePinged[j].maxtime, sitePinged[j].status);
						strcat(array, tempString);		
					}
				}
			}
			else
			{
			temp = strtok(temp, " ");
			if(temp != NULL)
			{
				p[0] = temp;
				i++;
				if(strcmp(p[0], "pingSites") == 0) 	//pingSites command
				{
					temp = strtok(NULL, ",");
					while(temp != NULL)
					{
						if(regexec(&regtext,temp,0,NULL,0) != 0)
						{
							printf("invalid URL: %s\n", temp);
						}
						sitePinged[numSites].handle = hcount + 1;
						strcpy(sitePinged[numSites].webURL, temp);
						sitePinged[numSites].avgtime = 0;
						sitePinged[numSites].mintime = 0;
						sitePinged[numSites].maxtime = 0;
						strcpy(sitePinged[numSites].status, "IN_QUEUE");
						i++;
						numSites++;
						needping++;
						temp = strtok(NULL, ",");
					}
					for(j = 0; j < numSites; j++)
					{
						printf("%s ", sitePinged[j].webURL);
					}
					printf("\n");
					hcount++;
					snprintf(array, sizeof(array), "Handle is %i", hcount);
				
				}
				else if(strcmp(p[0], "showHandleStatus") == 0)		//showHandleStatus <handle> command
				{	
					strcpy(array, "\0");
					if(numSites == 0)
						strcpy(array, "No handle requests\n");
					else
					{
						temp = strtok(NULL, "\n");
						if(temp != NULL)
						{
							int flag = 0;
							int tempNum = atoi(temp);
							for(j = 0; j < numSites; j++)
							{
								if(tempNum == sitePinged[j].handle) 	//searches for specified handle 
								{
									snprintf(tempString, sizeof(tempString), "%i %s %.5f %.5f %.5f %s\n", sitePinged[j].handle, sitePinged[j].webURL, sitePinged[j].avgtime, sitePinged[j].mintime, sitePinged[j].maxtime, sitePinged[j].status);
									strcat(array, tempString);
									flag++;
								}		
							}
							if(flag == 0)
								strcpy(array, "No requests from that handle\n");
						}
						else
						{
							strcpy(array, "Invalid command: missing <handle>\n");
						}
					}
				}
				else //when command is not found
				{
					strcpy(array, "Invalid command\n");
				}
			}
			}
		}
		write(sock , array, sizeof(array)); 	//sends reply to client
    	}
     
    	if(read_size == 0)
    	{
        	printf("Client disconnected\n");
        	fflush(stdout);
    	}
    	else if(read_size == -1)
    	{
        	perror("recv failed");
    	} 
    	//Free the socket pointer
    	free(sockfd);
    	return 0;
}

//thread that handles pinging the website
void *pingWeb()
{	
	struct hostent * host_addr;
	char * hostname;
	int i;
	int j;
	int rc;
	struct timespec tstart, tend;
	double times[10];
	while(1)
	{
		for(i = 0; i < 10;i++)
		{
			times[i] = 0;
		}
		while(1) //waits for website that needs pinging
		{
			if(needping > 0) //breaks out of loop to start executing
				break;
		}
		for(i = 0; i < numSites; i++)
		{
			if(strcmp(sitePinged[i % 100].status, "IN_QUEUE") == 0) 	//searches for website that is in queue
			{
				strcpy(sitePinged[i % 100].status, "IN_PROGRESS");
				needping--;
				hostname = sitePinged[i % 100].webURL;
				host_addr = gethostbyname(hostname);
				break;
			}
		}
	
		for(j = 0; j < 10; j++) 	//runs 10 times for 10 response times of website
		{
			int sockpg;
   			struct sockaddr_in host;     
    			//Create socket
    			sockpg = socket(AF_INET , SOCK_STREAM , 0);
    			if (sockpg == -1)
    			{
       				printf("Could not create socket\n");
    			}
       		 	bcopy((char*)host_addr->h_addr, (char*)&host.sin_addr, host_addr->h_length); 
    			host.sin_family = AF_INET;
    			host.sin_port = htons( 80 );

			clock_gettime(CLOCK_MONOTONIC, &tstart); 	//starts clock
    			//Connect to remote server
    			if (rc = connect(sockpg , (struct sockaddr *)&host , sizeof(host)) < 0)
   			{
       				printf("connect error\n");
        			return 0;
    			}
			if (rc == 0) 
			{
        			clock_gettime(CLOCK_MONOTONIC, &tend); 		//stops clock
				times[j] = ((double)tend.tv_sec + 1.0e-9*tend.tv_nsec) - ((double)tstart.tv_sec + 1.0e-9*tstart.tv_nsec);
        			if(j == 0) 	//get initial values for mininum and maximum times for comparison with future values
				{
					sitePinged[i].mintime = times[j];
					sitePinged[i].maxtime = times[j];
				}
				sitePinged[i].avgtime += times[j];
				if(sitePinged[i].mintime > times[j])	//insert minimum time
					sitePinged[i].mintime = times[j];
				if(sitePinged[i].maxtime < times[j])	//insert maximum time
					sitePinged[i].maxtime = times[j];
				printf("It took %.5f seconds\n", times[j]);
        			close(sockpg);
			}
		}
		sitePinged[i].avgtime /= 10;		//calculate average time
		strcpy(sitePinged[i].status,"COMPLETE");	//change status of pinged website
    		printf("Connected to website\n");
	}
    		return 0;
}
 
int main(int argc , char *argv[])
{
	int sockfd , new_socket , c , *new_sock;
    	struct sockaddr_in server , client;
    	char *message;
	int wthread_amount = 0;
     
    	//Create socket
    	sockfd = socket(AF_INET , SOCK_STREAM , 0);
    	if (sockfd == -1)
    	{
        	printf("Could not create socket");
    	}
     
    	//Prepare the sockaddr_in structure
    	server.sin_family = AF_INET;
    	server.sin_addr.s_addr = INADDR_ANY;
    	server.sin_port = htons( 8888 );
     
    	//Bind
    	if( bind(sockfd,(struct sockaddr *)&server , sizeof(server)) < 0)
    	{
        	printf("bind failed\n");
        	return 1;
    	}
    	printf("bind completed\n");
     
    	//Listen to socket
    	listen(sockfd , 3);
     
    	//Accept and incoming connection
    	printf("Waiting for incoming connections...\n");
    	c = sizeof(struct sockaddr_in);
    	while( (new_socket = accept(sockfd, (struct sockaddr *)&client, (socklen_t*)&c)) )
    	{
        	printf("Connection accepted\n");
         
        	//Reply to the client
        	message = "Server received connection\n";
        	write(new_socket , message , strlen(message));
         
        	pthread_t sniff_thread;
		pthread_t worker_thread;
        	new_sock = malloc(1);
        	*new_sock = new_socket;
         
        	if( pthread_create( &sniff_thread , NULL ,  handle_thread , (void*) new_sock) < 0)	//create client thread
        	{
            		perror("could not create thread");
            		return 1;
        	}  
        	printf("Thread assigned\n");
		if(wthread_amount != 1)
		{
			wthread_amount = 1;
			if(pthread_create(&worker_thread, NULL, pingWeb, NULL) < 0)	//create worker thread
			{
				perror("could not create thread");
				return 1;
			}
			printf("Worker thread created\n");
		}
    	} 
    	if (new_socket<0)
    	{
        	perror("accept failed");
        	return 1;
    	}
	close(sockfd);
    	return 0;
}
 
