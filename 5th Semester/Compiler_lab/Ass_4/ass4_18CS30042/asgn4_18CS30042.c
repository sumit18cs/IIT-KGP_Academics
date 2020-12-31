/*
Name: Sumit Kumar Yadav
Roll No.: 18CS30042
*/

#include <stdio.h>
#include "y.tab.h"
extern char* yytext;
extern int yyparse();


int main() {
  int token;
  yyparse();
  return 0;  
}