// Name:- Avijit Mandal
// Roll:- 18CS30010
// Name:- Sumit Kumar Yadav	
// Roll No:- 18CS30042
// Compilers Assignment 5

void print(int a,int n)
{
	if(a==n)
	{
		printf("Number is an armstrong_number\n");
	}
	else{
		printf("Number is not an armstrong_number\n");
	}
}

int armstrong_number(int n)
{
	int a;
	int s=0;
	while(n>0)
	{
		a=n%10;
		a=a*a*a;
		s=s+a;
		n=n/10;
	}
	return (s);
}

int main () {
	int n;
	int a;
	//test 1
	n=153;
	a=armstrong_number(n);
	print(a,n);
	//test 2
	n=132;
	a=armstrong_number(n);
	print(a,n);
	//test 3
	n=847;
	a=armstrong_number(n);
	print(a,n);
}
