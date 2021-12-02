#include<bits/stdc++.h>
#include<unistd.h>
#include<sys/wait.h>
#include<sys/shm.h>
#include<sys/ipc.h>
#include<time.h>
#include<signal.h>
#include<pthread.h>
#include <sys/syscall.h>

using namespace std;

#define SIZE 15
#define PSIZE 10

struct job{
  pid_t prod_id; 
  int prod_no; 
  int priority; 
  int time; 
  int job_id;

  job(){}

  job(int id, int no, int prio, int t, int j_id){
    prod_id = id;
    prod_no = no;
    priority = prio;
    time = t;
    job_id = j_id;
  }

  void print(){
    printf("Producer: %d, Producer TID: %d, Priority: %d, Compute Time: %d, Job ID: %d\n", prod_no, prod_id, priority, time, job_id);
  }
};

struct Jobs{
  job jobs_queue[SIZE+1];
  int job_created, job_completed;
  int count;
  pthread_mutex_t m;
};
struct Jobs H;

bool cmp(job a, job b){
  return a.priority > b.priority;
}

void heapify_up(Jobs& H, int pos){
      while((pos/2)>0)
      {
            job par = H.jobs_queue[pos/2];
            job cur = H.jobs_queue[pos];
            if(cmp(par, cur)) {
                  return;
            }
            else{
                  H.jobs_queue[pos]=par;
                  H.jobs_queue[pos/2]=cur;
            }
            pos=pos/2;
    }
}

void heapify_down(Jobs& H, int pos){
      int left,right,n,smallest;
      left = 2*pos;
      right = 2*pos+1;
      n = H.count;
      job l, r;
      if(left <= n){
            l = H.jobs_queue[left];
            r = H.jobs_queue[right];
            if(cmp(l,r)){ 
                  smallest=left;
            }
            else{ 
                  smallest=pos;
            }
      }
      else{ 
            smallest=pos;
      }
      job sm = H.jobs_queue[smallest];
      if(cmp(r,sm)){
            if(right<=n){
                  smallest=right;
            }
      }
      if(smallest != pos){
            job job_1,job_2;
            job_1=H.jobs_queue[smallest];
            job_2=H.jobs_queue[pos];
            H.jobs_queue[smallest]=job_2;
            H.jobs_queue[pos]=job_1;
            heapify_down(H, smallest);
      }
}

int retrieve(Jobs&  H,job *j){
      if(H.count == 0){
            return -1;
      }
      *j = H.jobs_queue[1];

      H.jobs_queue[1] = H.jobs_queue[H.count], 
      H.count=H.count-1;
      heapify_down(H,1);
      return 0;
}

int insertJob(Jobs& H, job& j){
      if(H.count == SIZE){
            return -1;
      } 
      H.count=H.count+1;
      H.jobs_queue[H.count] = j; 
      heapify_up(H, H.count);

      return 0;
}

int accessMemory(Jobs& H, int ch, job *jp = NULL)
{
      pthread_mutex_lock(&(H.m));
      int x;
      switch(ch)
      {
            case 0:
                  x =  insertJob(H, *jp);
                  pthread_mutex_unlock(&(H.m));
                  return x;
            case 1:
                  x = retrieve(H, jp);
                  pthread_mutex_unlock(&(H.m));
                  return x;
            case 2:
                  x = H.job_created += 1;
                  pthread_mutex_unlock(&(H.m));
                  return x;
            case 3:
                  x =  H.job_completed += 1; 
                  pthread_mutex_unlock(&(H.m));
                  return x;
            default:
                  pthread_mutex_unlock(&(H.m));
                  return -1;
      }
}

void *consumer(void* ptr){
  

      srand(time(NULL) ^ (getpid()<<16));
      pthread_t   tid;
      tid = syscall(__NR_gettid);
      while(true)
      {    
                while(H.job_completed >= PSIZE)continue;
            sleep(rand() % 4);
            job hp;
            while(accessMemory(H, 1, &hp) == -1)
                  usleep(10000);
                                    
            printf("Consumer: %d, Consumer TID: %d,", *((int *)ptr), (int)tid);
            hp.print();

            accessMemory(H, 3);
            sleep(hp.time);
      }
}

void* producer(void* ptr){
  

      srand(time(NULL) ^ (getpid()<<16));
      pthread_t   id;
      id = syscall(__NR_gettid);
      while(true)
      {     
            while(H.job_completed >= PSIZE)continue;
            job gen(id, *((int *)ptr), (rand() % 10) + 1, (rand() % 4) + 1, (rand() % 100000) + 1);  // Create a job
            sleep(rand() % 4);

            while(accessMemory(H, 0, &gen) == -1)
                  usleep(10000);

            accessMemory(H, 2);
            gen.print();
      }
}

int main()
{

    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);
    pthread_mutex_init(&H.m, &attr);
    double time=0;
    int nc, np;
    cout<<"Enter number of Producers and Consumers respectively :  ";
      cin>>np>>nc; 

    for(int i=0;i<nc;i++){
      pthread_t ptid_P;
      int *param = new int[1];
      *param = i+1; 
      pthread_create(&ptid_P, NULL, consumer, param);
    }

    for(int i=0;i<np;i++){
      pthread_t ptid_C;
      int *param = new int[1];
      *param = i+1; 
      pthread_create(&ptid_C, NULL, producer, param);

    }
    clock_t st, en;
    st = clock();
    while(true){
      usleep(10000);
      time+=0.01;
      if(H.job_completed >= PSIZE){
            printf("Time Executed: %.3f s\n", time + (((double)(clock() - st)) / CLOCKS_PER_SEC));
            kill(-getpid(), SIGQUIT);
      }
    }
}