//Name : Sumit Kumar Yadav
//Roll no.: 18CS30042
//Second Programming Assignment
//Convex hull of circles

#include <time.h>
#include<stdio.h>
#include<stdlib.h>
#include<math.h>		//for sqrt() and atan2() function
#define MAXN 100001	//max size of auxiliary array for merge sort during intermediate process

//Point structure definition
typedef struct point
{
	double x;
	double y;
}point;

//Stack structure definition
struct Stack{
	point data;
	struct Stack* next;
};

//Merge sort code
void merge(point *p,int l,int m,int u)
{
	int a,b,i;
	double x[MAXN],y[MAXN];
	a=l;
	b=m+1;
	for(i=l;i<=u;i++)
	{
		if(a>m)
		{
			x[i]=p[b].x;
			y[i]=p[b].y;
			b++;
		}
		else if(b>u)
		{
			x[i]=p[a].x;
			y[i]=p[a].y;
			a++;
		}
		else if(p[a].x>p[b].x)
		{
			x[i]=p[b].x;
			y[i]=p[b].y;
			b++;
		}
		else
		{
			x[i]=p[a].x;
			y[i]=p[a].y;
			a++;
		}
	}
	for(i=l;i<=u;i++)
	{
		p[i].x=x[i];
		p[i].y=y[i];
	}
}
void mergesort(point *p,int l,int u)
{
	int m;
	if(l>=u)
	{
		return;
	}
	m=(l+u)/2;
	mergesort(p,l,m);
	mergesort(p,m+1,u);
	merge(p,l,m,u);
}

//create stack
struct Stack* createStack(point data)
{
	struct Stack* s=(struct Stack*)malloc(sizeof(struct Stack));
	s->data=data;
	s->next=NULL;
	return s;
}

//insert element in the stack
void push(struct Stack** root,point data){
	struct Stack* s=createStack(data);
	s->next=*root;
	*root=s;
}

//delete top element of the stack
void pop(struct Stack** root){
	struct  Stack* temp=*root;
	*root=(*root)->next;
	free(temp);
}

//This function check whether point is lies left or right to the given line segment/ray
int check(double x1, double x2, double x, double y1, double y2, double y)
{
	double ans=x2*y-x*y2-x1*y+x*y1+x1*y2-x2*y1;
	if(ans==0){return 0;}
	else if(ans>0){return 1;}
	else{return 2;}

	//0 means point (x,y) , (x1,y1) and (x2,y2) are collinear
	//1 means point (x,y) is at left with respect to the line segment/ray joining (x1,y1) and (x2,y2)
	//2 means point (x,y) is at right with respect to the line segment/ray joining (x1,y1) and (x2,y2)
}

//Calculate Upper hull and Lower hull
//flag = 1 for Upper hull
//flag = 2 for Lower hull
int CH(point *p,int n,int flag,point *H)
{
	struct Stack* head=NULL;   //initialize stack

	//insert first 2 points in the stack
	push(&head,p[0]);
	push(&head,p[1]);

	int m=2;			//m store size of stack at any instant
	int i;
	for(i=2;i<n;i++)
	{	
		while(m>1)
		{
			//find topmost element of the stack
			double x2=head->data.x;
			double y2=head->data.y;

			pop(&head);			//remove the top element to obtain second topmost element

			//second topmost element of the stack
			double x1=head->data.x;
			double y1=head->data.y;

			point *q=(point *)malloc(sizeof(point));
			q->x=x2;
			q->y=y2;
			push(&head,q[0]);		//push the topmost element in the stack

			if(flag==1)
			{
				if( check(x1,x2,p[i].x,y1,y2,p[i].y) != 1){break;}
			}
			else
			{
				if( check(x1,x2,p[i].x,y1,y2,p[i].y) != 2){break;}
			}
			pop(&head);
			m--;
		}
		push(&head,p[i]);
		m++;
	}
	i=0;
	int ans=m;
	while(m>0){
		H[i].x=head->data.x;
		H[i].y=head->data.y;
		m--;i++;
		pop(&head);
		
	}
	return ans;		//ans store the size of hull
}

//Print the containment zone
void printcontzone(int u, int l, point *T, point *A)
{
	int i=0,j=0;
	int k;
	printf("\n+++ The containment zone\n");
	printf("--- Upper section\n");
	for(k=0;k<u;k++)
	{
		printf("Arc		:  ( %0.20lf , %0.20lf ) From %0.20lf to %0.20lf \n",A[j].x,A[j].y,A[j+1].x,A[j+1].y);
		if(k==u-1){break;}
		printf("Tangent :  From ( %0.20lf , %0.20lf ) to ( %0.20lf , %0.20lf )\n",T[j].x,T[j].y,T[j+1].x,T[j+1].y);
		j=j+2;
	}
	i=j+2;
	printf("\n--- Lower section\n");
	for(k=0;k<l;k++)
	{
		printf("Arc		:  ( %0.20lf , %0.20lf ) From %0.20lf to %0.20lf \n",A[i].x,A[i].y,A[i+1].x,A[i+1].y);
		if(k==l-1){break;}
		printf("Tangent :  From ( %0.20lf , %0.20lf ) to ( %0.20lf , %0.20lf )\n",T[j].x,T[j].y,T[j+1].x,T[j+1].y);
		j=j+2;
		i=i+2;
	}
}

//Array T store the point of the tangent to the circle where end points are at i,i+1 in this array, increment i=i+2
//Array A store the centre point at i and its angle at i+1, increment i=i+2 
//Calculate the Continment zone
void contzone(point *UH, int u, point *LH, int l,double r, point *T, point *A)
{
	int i;
	int c=0;
	int d=0;
	double x1,y1,m,m1,a1;

	//find point at a distance r from point (x0,y0) having slope m:
	//x1 = x0 + r*(sqrt(1/(1+m*m)))
	//y1 = y0 + m*r*(sqrt(1/(1+m*m)))
	//x1 = x0 - r*(sqrt(1/(1+m*m)))
	//y1 = y0 - m*r*(sqrt(1/(1+m*m)))
	//find angle from axis from point (0,0) to point (x,y)
	//theta angle = atan2(y,x)

	//Upper Hull
	A[d].x=UH[0].x;
	A[d].y=UH[0].y;
	d++;
	A[d].x= 3.141592653589793;

	for(i=0;i<u-1;i++)
	{
		m1=(UH[i+1].y-UH[i].y)/(UH[i+1].x-UH[i].x);	//find slope of line containing adjacent centre
		m=(1)/m1;							
		m=(-1)*m;							//slope perpendicular to that line
		a1=1+m*m;
		a1=1/a1;
		a1=sqrt(a1);
		a1=a1*r;

		//first case (centre at i)
		x1=UH[i].x+a1;
		y1=UH[i].y+m*a1;
		if(check(UH[i].x , UH[i+1].x , x1 , UH[i].y , UH[i+1].y , y1)== 1 ){
			T[c].x=x1;
			T[c].y=y1;
			A[d].y=atan2(T[c].y-UH[i].y,T[c].x-UH[i].x);
		}
		else{
			T[c].x=UH[i].x-a1;
			T[c].y=UH[i].y-m*a1;
			A[d].y=atan2(T[c].y-UH[i].y,T[c].x-UH[i].x); 
		}
		c++;
		d++;
		A[d].x=UH[i+1].x;
		A[d].y=UH[i+1].y;
		d++;

		//second case (centre at i+1)
		x1=UH[i+1].x+a1;
		y1=UH[i+1].y+m*a1;
		if(check(UH[i].x , UH[i+1].x , x1 , UH[i].y , UH[i+1].y , y1)== 1 ){
			T[c].x=x1;
			T[c].y=y1;
			A[d].x=atan2(T[c].y-UH[i+1].y,T[c].x-UH[i+1].x);
		}
		else{
			T[c].x=UH[i+1].x-a1;
			T[c].y=UH[i+1].y-m*a1;
			A[d].x=atan2(T[c].y-UH[i+1].y,T[c].x-UH[i+1].x);
		}
		c++;
	}
	A[d].y= 0.000000000000000;

	//Lower hull
	d++;
	A[d].x=LH[0].x;
	A[d].y=LH[0].y;
	d++;
	A[d].x= 0.000000000000000;
	for(i=0;i<l-1;i++)
	{
		m1=(LH[i+1].y-LH[i].y)/(LH[i+1].x-LH[i].x);
		m=(1)/m1;
		m=(-1)*m;
		a1=1+m*m;
		a1=1/a1;
		a1=sqrt(a1);
		a1=a1*r;

		//first case (centre at i)
		x1=LH[i].x+a1;
		y1=LH[i].y+m*a1;
		if(check(LH[i].x , LH[i+1].x , x1 , LH[i].y , LH[i+1].y , y1)== 1 ){
			T[c].x=x1;
			T[c].y=y1;
			A[d].y=atan2(T[c].y-LH[i].y,T[c].x-LH[i].x);
		}
		else{
			T[c].x=LH[i].x-a1;
			T[c].y=LH[i].y-m*a1;
			A[d].y=atan2(T[c].y-LH[i].y,T[c].x-LH[i].x);
		}
		c++;
		d++;
		A[d].x=LH[i+1].x;
		A[d].y=LH[i+1].y;
		d++;

		//second case (centre at i+1)
		x1=LH[i+1].x+a1;
		y1=LH[i+1].y+m*a1;
		if(check(LH[i].x , LH[i+1].x , x1 , LH[i].y , LH[i+1].y , y1)== 1 ){
			T[c].x=x1;
			T[c].y=y1;
			A[d].x=atan2(T[c].y-LH[i+1].y,T[c].x-LH[i+1].x);
		}
		else{
			T[c].x=LH[i+1].x-a1;
			T[c].y=LH[i+1].y-m*a1;
			A[d].x=atan2(T[c].y-LH[i+1].y,T[c].x-LH[i+1].x);
		}
		c++;
	}
	A[d].y= -3.141592653589793;
}

int main()
{
	// clock_t t; 
   	// t = clock(); 
	int n,i;
	double r;
	scanf("%d %lf",&n,&r);
	//cin >> n >> r;

	point *p=(point *)malloc(n*sizeof(point));
	for(i=0;i<n;i++)
	{
		scanf("%lf %lf",&p[i].x,&p[i].y);
		//cin >> p[i].x >> p[i].y;
	}

	//part 2 
	mergesort(p,0,n-1);		//function call
	printf("+++ Circles after sorting\n");
	for(i=0;i<n;i++)
	{
		printf("%0.20lf     %0.20lf\n",p[i].x,p[i].y);
		//cout << (setprecision(20)) << p[i].x << "     " << p[i].y <<"\n";
	}

	//part 3
	point *H=(point *)malloc(n*sizeof(point));
	point *UH=(point *)malloc(n*sizeof(point));
	point *LH=(point *)malloc(n*sizeof(point));
	int j=0;

	//Upper hull
	int size_uh=CH(p,n,1,H);	//function call
	for(i=size_uh-1;i>=0;i--){
		UH[j].x=H[i].x;
		UH[j].y=H[i].y;
		j++;
	}
	printf("\n+++ Upper hull\n");
	for(i=0;i<size_uh;i++)
	{
		printf("%0.20lf     %0.20lf\n",UH[i].x,UH[i].y);
	}

	//Lower hull
	int size_lh=CH(p,n,2,H);	//function call
	for(i=0;i<size_lh;i++){
		LH[i].x=H[i].x;
		LH[i].y=H[i].y;
	}
	printf("\n+++ Lower hull\n");
	for(i=0;i<size_lh;i++)
	{
		printf("%0.20lf     %0.20lf\n",LH[i].x,LH[i].y);
	}

	//part 4
	point *T=(point *)malloc((4*n)*sizeof(point));
	point *A=(point *)malloc((4*n)*sizeof(point));
	contzone(UH,size_uh,LH,size_lh,r,T,A);		//function call for calculating containment zone
	printcontzone(size_uh,size_lh,T,A);			//function call for printing the containment zone

	// t = clock() - t; 
    	// double time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds 
   	// printf("fun() took %f seconds to execute \n", time_taken); 
}