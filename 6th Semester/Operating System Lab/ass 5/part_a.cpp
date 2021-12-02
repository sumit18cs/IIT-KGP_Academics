#include<bits/stdc++.h>
#include<unistd.h>
#include<sys/wait.h>
#include<sys/shm.h>
#include<sys/ipc.h>
#include<time.h>
#include<signal.h>
#include<pthread.h>
using namespace std;

#define max_size 15
#define max_job 10

// Structure for Jobs
struct job{

	pid_t process_id; 
	int producer_number; 
	int priority; 
	int time;  
	int job_id; 

	// constructor
	job(){}

	job(int id, int no, int prio, int t, int j_id){
          process_id = id;
          producer_number = no;
          priority = prio;
          time = t;
          job_id = j_id;
        }

      void print(){
    printf("Producer: %d, Producer TID: %d, Priority: %d, Compute Time: %d, Job ID: %d\n", producer_number, process_id, priority, time, job_id);
  }
};

// Structure for storing shared memory segment SHM
struct SHM{
	job all_jobs[max_size+1];
	int job_created;
      int job_completed;
	int total;
	pthread_mutex_t mutex;
};

int check(SHM *H,int x, int y)
{
    // H[0] 
      job job_x,job_y;              // declare 2 job each for x and y
      job_x=H[0].all_jobs[x];      // fetch job1
      job_y=H[0].all_jobs[y];      // fetch job2
      if(job_y.priority<job_x.priority){
            return 1;
      }
      else{
            return 0;
      }
}

void heapify_up(SHM *H, int index)
{
      while((index/2)>0)
      {
            job parent_node,current_node;
            parent_node=H[0].all_jobs[index/2];
            current_node=H[0].all_jobs[index];
            if( check(H,index/2,index) == 1){
                  return ;
            }
            else{
                  H[0].all_jobs[index/2]=current_node;
                  H[0].all_jobs[index]=parent_node;
            }
            index=index/2;
      }
}

void heapify_down(SHM *H, int index)
{
      int left_node,right_node,n,minimum;
      left_node = 2*index;
      right_node = 2*index+1;
      n = H[0].total;
      if(left_node<=n){
            if(check(H,left_node,index)==1){
                  minimum=left_node;
            }
            else{
                  minimum=index;
            }
      }
      else{
            minimum=index;
      }
      if(check(H,right_node,minimum)==1){
            if(right_node<=n){
                  minimum=right_node;
            }
      }
      if(minimum != index)
      {
            job job_1,job_2;
            job_1=H[0].all_jobs[minimum];
            job_2=H[0].all_jobs[index];
	      H[0].all_jobs[minimum]=job_2;
            H[0].all_jobs[index]=job_1;
            heapify_down(H, minimum);
      }
}

int retrieve(SHM *H,job *j)
{
      if(H[0].total==0){
            return -1;
      }

      *j = H[0].all_jobs[1];	// Remove the top job

	// Order the priority queue
      H[0].all_jobs[1] = H[0].all_jobs[H[0].total];
      H[0].total=H[0].total-1;
      heapify_down(H,1);
      return 0;
}

int insertJob(SHM *H, job j)
{
	// queue is full
	if(H[0].total == max_size){
            return -1;
      } 

      H[0].total =H[0].total+1;	    
      H[0].all_jobs[H[0].total] = j;      
      heapify_up(H, H[0].total);          
	return 0;
}

int accessMemory(SHM *H, int ch, job *jp = NULL)
{
	pthread_mutex_lock(&(H[0].mutex));  // Lock the code
	int x;
      switch(ch)
      {
            case 0:
                  x =  insertJob(H, *jp);
                  pthread_mutex_unlock(&(H[0].mutex));
                  return x;
            case 1:
                  x = retrieve(H, jp);
                  pthread_mutex_unlock(&(H[0].mutex));
                  return x;
            case 2:
                  H[0].job_created =H[0].job_created+ 1;
                  x=H[0].job_created;
                  pthread_mutex_unlock(&(H[0].mutex));
                  return x;
            case 3:
                  H[0].job_completed = H[0].job_completed+1;
                  x=H[0].job_completed;
                  pthread_mutex_unlock(&(H[0].mutex));
                  return x;
            default:
                  pthread_mutex_unlock(&(H[0].mutex));
                  return -1;
      }
}

int main()
{
      int i,NC,NP;
      int shmid = shmget(IPC_PRIVATE, sizeof(SHM), 0700|IPC_CREAT);
      if(shmid < 0)
      {
            cout<<"Shared Memory creation error"<<endl;
            exit(EXIT_FAILURE);
      }
      SHM *shared_memory = (SHM *)shmat(shmid, NULL, 0);

      shared_memory[0].total = 0;
      shared_memory[0].job_created =0;
      shared_memory[0].job_completed = 0; 
      pthread_mutexattr_t attr;
      pthread_mutexattr_init(&attr);
      pthread_mutex_init(&(shared_memory[0].mutex), &attr);
      pthread_mutexattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
      

	cout<<"Enter number of Producers and Consumers respectively :  ";
      cin>>NP>>NC; 

	//consumer processes

	for(i=1; i <= NC; i++)
	{
		pid_t a = fork();
		if( a == 0 )
		{
			srand(time(NULL) ^ (getpid()<<16)); 
			pid_t id = getpid();  
			for(;;)
			{
				sleep(rand() % 4);  
 
				job current;
				while(accessMemory(shared_memory, 1, &current) == -1){
					usleep(10000);
                        }

				cout<<"Consumer: "<<i<<", Consumer PID: "<<id<<", ";
				current.print();

				accessMemory(shared_memory, 3); 
				sleep(current.time); 
			}
		}
	}

	// producer processes
	for(i=1; i <= NP; i++)
	{
		pid_t a = fork(); 
		if( a == 0 )
		{
			srand(time(NULL) ^ (getpid()<<16));  
			pid_t id = getpid();  
			for(;;)
			{
				job gen(id, i, (rand() % 10) + 1, (rand() % 4) + 1, (rand() % 100000) + 1);  
				sleep(rand() % 4);  

				while(accessMemory(shared_memory, 0, &gen) == -1)
					usleep(10000);

				accessMemory(shared_memory, 2); 
				gen.print();
			}
		}
	}
	// Run till required jobs has reached
      clock_t st = clock(), en;
      double time = 0;
	while(true)
	{
		usleep(10000); // sleep for 1 second
		time += 0.01;
		if(shared_memory[0].job_completed >= max_job)
		{
			printf("Time Executed: %.3f s\n", time + (((double)(clock() - st)) / CLOCKS_PER_SEC)); 
			kill(-getpid(), SIGQUIT); 
		}
	}
}