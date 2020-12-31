//Name : Sumit Kumar Yadav
//Roll No. : 18CS30042

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
	
#define MAXN   	  200
#define infinity    10e7
FILE *fptr;

typedef struct EDGE{
	int y;  //edge x->y
	int c;  //capacity of the edge
	int f;  //flow value through the edge
	struct EDGE *next;  //pointer to next edge type node
}EDGE;

typedef struct VERTEX{
	int x;  //id of the vertex
	int n;  //need value of the vertex
	EDGE *p; //pointer pointing to the first node in adjacency list of vertex
}VERTEX;

typedef struct GRAPH{
	int V;  //no. of vertex
	int E;  //no. of edge
	VERTEX **H;
}GRAPH;

typedef struct AUGMENTING_PATH{
	int residual_capacity;    
	int length;		
	int *path;
}AUGMENTING_PATH;

AUGMENTING_PATH selected_path;
int Actual_Edge[MAXN][MAXN];	//it is 1 means edge is given in the graph initially
int Edge[MAXN][MAXN];         //it is 1 means edge exist otherwise not
int len = 1;
int check=0;		//to check whether it is need based flow or normal max flow
int ans=1;			//to check need based flow is possible or not
int positive_n=0;		//sum of needs where need>0
int negative_n=0;   	//sum of needs where need<0

//Function to calculate minimum of a and b
int min(int a, int b){
	if(a<b){
		return a;
	}
	else{
		return b;
	}
}

//Function to add new vertex to the Graph
VERTEX * add_new_vertex(int id, int n)
{
	int a,b;
	a=id;
	b=n;
	VERTEX *temp = (VERTEX *)malloc(sizeof(VERTEX));
	temp->p = (EDGE *)malloc(sizeof(EDGE));
	temp->p = NULL;
	temp->n = b;
	temp->x = a;
	return temp;
}

//Function to add new edge to the Graph
void add_new_edge(GRAPH *G, int x, int y, int c)
{
	EDGE* edge = (EDGE *)malloc(sizeof(EDGE));
	edge->f = 0;
	edge->y = y;
	edge->c = c;
	
	EDGE *temp = (G->H[x])->p;
	edge->next = temp;
	(G->H[x])->p = edge;
}

//Function to Initialize the augmented path
void new_selected_path()
{
	selected_path.path = (int *)malloc(MAXN*sizeof(int));
	selected_path.residual_capacity = 0;
	selected_path.length = 0;
	for(int i=0;i<MAXN;i++)
	{
		selected_path.path[i]=-1;
	}
}

//Function to calculate all the Augmented path
void calculate_all_paths(GRAPH *G,int s, int t,int path[], int visited[], int residual_capacity)
{
	visited[s] = 1;
	int previous_residual_capacity = residual_capacity;
	path[len++] = s;
	if(s!=t)
	{
		EDGE* edge = (G->H[s])->p;
		while(edge!=NULL)
		{
		      int current_residual_capacity = edge->c - edge->f;
		      int a=0;
		      if(visited[edge->y]==1)
		      {
		      	edge = edge->next;
			      a=1;
		      }
		      else if(current_residual_capacity==0)
		      {
		      	edge = edge->next;
			      a=1;
		      }
		      if(a==1)
		      {
		      	continue;
		      }
      		residual_capacity = min(residual_capacity, current_residual_capacity);
      		calculate_all_paths(G, edge->y, t, path, visited, residual_capacity);
      		edge = edge->next;
		}
	}
	else
	{
		AUGMENTING_PATH current_path;

	    	current_path.length = len-1;
	    	current_path.path = (int *)malloc(MAXN*sizeof(int));
	    	current_path.residual_capacity = residual_capacity;
	    	for(int i=1; i<=len-1; i++)
	    	{
	      	current_path.path[i] = path[i];
	    	}

		//compare the paths 

		if(selected_path.length == 0)
		{
			selected_path= current_path;
		}   
		else if(selected_path.length > current_path.length)
		{
			selected_path= current_path;
		}
		else if(selected_path.length == current_path.length && selected_path.residual_capacity < current_path.residual_capacity)
		{
			selected_path= current_path;
		}
	}
	residual_capacity = previous_residual_capacity;
	visited[s] = 0;
	len--;
}

//Function to update the flow of the edges
void flow_addition(GRAPH *G, int a, int b, int residual_capacity)
{
	EDGE *edge = (G->H[a])->p;
	while(edge!=NULL)
	{
		if(edge->y!=b)
		{
			edge = edge->next;   
		}
		else
		{
	      	edge->f = edge->f + residual_capacity;
	      	edge = edge->next; 
		}   	  
  	}
}

//Function to update Augmented path
void update(GRAPH *G)
{
	for(int i = selected_path.length; i>=2; i=i-1)
	{
    		int a = selected_path.path[i-1];
      	int b = selected_path.path[i];
      	flow_addition(G, a, b, selected_path.residual_capacity);
      	flow_addition(G, b, a, -selected_path.residual_capacity);
    	}
}

//Function to calculate max flow
void ComputeMaxFlow(GRAPH *G, int s, int t)
{
	int V;
	int i,j,flow=0;
	V=G->V;
	for(i=1; i<=V; i=i+1)
	{
		for(j=1; j<=V; j=j+1)
		{
			if(Edge[i][j]==1)
			{
				if(Edge[j][i]==0)
				{
					if(i!=j)
					{
						add_new_edge(G, j, i, 0);
		      			Edge[j][i] = 1;
					}
				}
			}
		}
	}
	while(1)
	{
		new_selected_path();
		len = 1;
	  	int *path = (int *)malloc((G->V+3)*sizeof(int));
	  	for(int i=0;i<G->V+3;i++)
	  	{
	  		path[i]=-1;
  		}
  		int visited[MAXN]={0};
  		new_selected_path();
 		calculate_all_paths(G, s, t, path, visited, infinity);
   		if(selected_path.length == 0)
   		{
   			break;
   		}
    		flow=flow+selected_path.residual_capacity;
    		update(G);
  	}
    	if( flow!= positive_n && check==1)
    	{
    		ans=0;
	    	printf("\nNOT POSSIBLE TO SATISFY THE NEEDS.\n");
	    	return;
	}
	else
	{
		printf("\nComputed Flow value = %d\n", flow);  
	}
}

//Function to calculate the need based flow
void NeedBasedFlow(GRAPH *G)
{
	printf("In Need Based Flow :-\n");
	check=1;
	int total_vertex = G->V, total_edge = G->E;
	for(int i=1;i<=total_vertex;i++)
	{
	    	if((G->H[i])->n > 0)
	    	{
	    		positive_n += (G->H[i])->n;
	    	}
	    	else
	    	{
	    		negative_n += (G->H[i])->n;
	    	} 
  	}
  	if(positive_n+negative_n !=0)
  	{
  		ans=0;
    		printf("NOT POSSIBLE TO SATISFY THE NEEDS.\n");
    		return;
  	}
  	VERTEX * source = add_new_vertex(G->V+1,0);
  	G->H[G->V+1] = source;

  	VERTEX * sink = add_new_vertex(G->V+2,0);
  	G->H[G->V+2] = sink;
  	int i;
  	for(i = 1; i<=total_vertex; i++)
  	{
    		int new_capacity = (G->H[i])->n;
    		if(new_capacity<0)
    		{
    			add_new_edge(G,source->x,i,-new_capacity);
      		total_edge=total_edge+1;
    		}
    		else
    		{
      		add_new_edge(G,i,sink->x,new_capacity);
      		total_edge=total_edge+1;
    		}
 	}
  	ComputeMaxFlow(G, source->x, sink->x);
}

//Function to read the graph
GRAPH* ReadGraph(char *fname) 
{
	fptr=fopen(fname,"r");
 
  	int V,E;
     fscanf(fptr,"%d",&V);
     fscanf(fptr,"%d",&E);
    //scanf("%d%d",&V,&E);

    GRAPH *G = (GRAPH *)malloc(sizeof(GRAPH)); 
    G->H = (VERTEX **)malloc((V+5)*sizeof(VERTEX *));

    G->V = V;
    G->E = E;

 	int i;
  
 	int b=V,a;
  	for(i=1;i<=b;i++)
  	{
	    	fscanf(fptr,"%d",&a);
	    	//scanf("%d",&a);
	    	VERTEX *newVertex = add_new_vertex(i,a);
	    	G->H[i] = newVertex;
  	}
  	int x,y,c;
  	for(i=1;i<=G->E;i++)
  	{
	    	x,y,c;
	    	fscanf(fptr,"%d %d %d",&x,&y,&c);
	    	//scanf("%d %d %d",&x,&y,&c);
	    	Actual_Edge[x][y] = 1; 
	    	Edge[x][y] = 1;
	    	add_new_edge(G, x, y,c);    
	}
  	return G;
}

//Function to print the Graph
void PrintGraph(GRAPH *G)
{
	int a,b;
	a=G->V;
	for(int i = 1;i<= a; i++)
	{
		int d=i;
		printf("%d ",d);
	    	EDGE *edge = (G->H[i])->p;
	    	while(edge!=NULL)
	    	{
	    		b=Actual_Edge[i][edge->y];
	    		if(b==0){
	    			edge = edge->next;
	    		}
	      	else if(b==1)
	      	{
	      		printf("-> (%d, %d, %d)",edge->y, edge->c, edge->f);
	      		edge = edge->next;
      		}	
    		}
    		printf("\n");
  	}
}

//main function
int main(){
	int source, sink;
	char input_txt[21];
	printf("Input the name of input file, e.g input.txt\n");
	scanf("%s", input_txt);

	//Initialize matrices to 0
	for(int i=0;i<MAXN;i++)
	{
		for(int j=0;j<MAXN;j++)
		{
			Actual_Edge[i][j]=0;
			Edge[i][j]=0;
		}
	}

	GRAPH *G;

	G = ReadGraph(input_txt);
	//G=ReadGraph();

	printf("Input Graph is :-\n");
 	PrintGraph(G);
  	
  	printf("Enter the Source vertex and Sink Vertex\n");
  	scanf("%d %d", &source, &sink);

  	printf("Maxflow in the Graph :-\n");
  	ComputeMaxFlow(G, source, sink);

  	printf("Graph after computing Max Flow :-\n");
  	PrintGraph(G);

   	G = ReadGraph(input_txt);
  	//G=ReadGraph();
  	NeedBasedFlow(G);

  	if(ans==1){
  		printf("Graph after computing Need Based Flow in the given Graph:-\n");
  		PrintGraph(G);
  	}
}