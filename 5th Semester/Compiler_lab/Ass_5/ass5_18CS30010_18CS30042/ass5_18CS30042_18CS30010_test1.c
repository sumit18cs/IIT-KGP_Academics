
// Name:- Avijit Mandal
// Roll:- 18CS30010
// Name:- Sumit Kumar Yadav	
// Roll No:- 18CS30042
// Compilers Assignment 5

void print_details()
{
	printf("sumit kumar yadav\n");
	printf("18CS30042\n");
	printf("Avijit mandal\n");
	printf("18CS30010\n");
	printf("Compiler lab assignment\n");
}

int check_divisibilty(int a,int n)
{
	int check;
	check=0;
	int r;
	r=n%a;
	if(r==0){
		check=1;
	}
	else{
		check=0;
	}
	return (check);
}

int main()
{	
	print_details();
	int n=10;
	int a=2;
	int p;
	p=check_divisibilty(a,n);
	if(p==1)
	{
		printf("%d is divisible by %d",n,a);
	}
	else{
		printf("%d is not divisible by %d",n,a);
	}
	return 0;
}



