/*
Name: Sumit Kumar Yadav
Roll No.: 18CS30042
*/

int sum(int a,int b)
{
      return a+b;
}
int recursion(int a,int b)
{
      if(a<0 || b<0){return 1;}
      else
      {
            return 2+recursion(a-2,b-2);
      }
}
int main()
{
      int a,b,i,c;
      char ch[]="Sumit Kumar Yadav";
      char ch1[]="18CS30042";
      char ch2[]="Computer Science and Engineering";
      char ch3[]="IIT Kharagpur";
      a=100;
      b=20;
      for(i=0;i<1;i++)
      {
            if(a<b)
            {
                  c=1;
            }
            else
            {
                  c=0;
            }
      }
      printf("%d",c);
      int d;
      d=sum(a,b);             //function call
      printf("%d",c);
      d=recursion(a,b);       //recursion
      int x[24]={0};
      for(i=1;i<20;i++)
      {
            x[i]=x[i]+x[i-1];       //prefix sum
      }
      a=0;
      b=0;
      for(i=0;i<20;i++)
      {
            if(x[i]%2==0)
            {
                  a++;
            }
            else
            {
                  b++;
            }
      }
      if(a>b)
      {
            printf("number of even prefix sum are greater than odd prfix sum");
      }
      else if(b<a)
      {
            printf("number of odd prefix sum are greater than even prfix sum");
      }
      int s=0;
      for(i=0;i<20;i++)
      {
            s=s+x[i];
      }
      printf("%d",s);
      a=23;
      b=25;

      //Swap a and b
      c=a;
      a=b;
      b=c;
      printf("a=%d, b=%d",a,b);

      //check number is armstrong or not
      int num, p, r, ans = 0;
      printf("Enter a three-digit integer: ");
      scanf("%d", &num);
      p = num;
      while (p != 0) 
      {
            r=p%10;
            ans=ans+r*r*r;
            p=p/10;
      }
      if (ans == num)
      {
            printf("%d is an Armstrong number.", num);
      }
      else
      {
            printf("%d is not an Armstrong number.", num);
      }
}