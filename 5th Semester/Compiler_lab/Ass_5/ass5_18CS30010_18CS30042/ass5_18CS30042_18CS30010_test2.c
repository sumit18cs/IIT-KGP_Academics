// Name:- Avijit Mandal
// Roll:- 18CS30010
// Name:- Sumit Kumar Yadav	
// Roll No:- 18CS30042
// Compilers Assignment 5

int calculate(int check, int total,int v)
{
	int n = 0 ;
	int arr[10];
	arr[n+1]=15;
	int i=2;
	char a='a';
	double x=2.3;
	n = x + i;
	if(check>= v){
		n++;
	}
	
	return(n);
}
void print_arr(int check, int total)
{
	printf("%d ",check);
	printf("\n");
}

int main()
{	
	int check=10;
	int result;
	print_arr(check,10);
	result = calculate(check,10,70);	
	if(result == 1){
		printf("There was %d pass.\n",result);
	}
	else{
		printf("There were %d n.\n",result);
	}

	return 0;
}


