/*
Name: Sumit Kumar Yadav
Roll No.: 18CS30042
*/





 void comment();
"/*"			{comment();}
void comment(){
	char c, prev = 0;
	while ((c = yyinput()) != 0){
		if (c == '/' && prev == '*') return;
		prev = c;
	}
	char* temp=(char*)calloc(30,sizeof(char));
	strcpy(temp,"unterminated comment");
	yyerror(temp);
}
%{

#include <math.h>
#include "y.tab.h"
extern void yyerror(const char *);

%}

/*Identifier*/
IDENTIFIER 				{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*
IDENTIFIER_NONDIGIT		[a-zA-Z_]
DIGIT					[0-9]

/*Constant*/
CONSTANT				{INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{CHARACTER_CONSTANT}
INTEGER_CONSTANT 		0|{NON_ZERO_DIGIT}{DIGIT}*
NON_ZERO_DIGIT			[1-9]
FLOATING_CONSTANT 		({FRACTIONAL_CONSTANT}{EXPONENT_PART}?)|({DIGIT}+{EXPONENT_PART})
FRACTIONAL_CONSTANT 	(({DIGIT}+)?\.{DIGIT}+)|(({DIGIT}+)\.)
EXPONENT_PART			([eE][-+]?{DIGIT}+)
SIGN 					"+"|"-"

/*Character*/
ESCAPE_SEQUENCE			\\['"?\\abfnrtv]
CHARACTER_CONSTANT 		'({C_CHAR})+'
C_CHAR 					[^'\\\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE			{C_CHAR}+

/*String*/
S_CHAR  				{ESCAPE_SEQUENCE}|[^("\"|"\\"|"\n")]
S_CHAR_SEQUENCE			{S_CHAR}+
STRING_CONSTANT 			\"({S_CHAR}+)\" 

WHITESPACE  			[ \t\v\n\f]

/* Comments */
SINGLE_LINE_COMMENT		"//"[^("\n")]*
MULTI_LINE_COMMENT		\/\*([^\*]|(\*)+[^\/\*])*(\*)*\/

%%

{SINGLE_LINE_COMMENT}					{ }
{MULTI_LINE_COMMENT} 					{ }
"sizeof"        { return SIZEOF; }
"extern"        { return EXTERN; }
"static"        { return STATIC; }
"void"          { return VOID; }
"char"          { return CHAR; }
"short"         { return SHORT; }
"int"           { return INT; }
"long"          { return LONG; }
"float"         { return FLOAT; }
"double"        { return DOUBLE; }
"case"          { return CASE; }
"default"       { return DEFAULT; }
"if"            { return IF; }
"else"          { return ELSE; }
"switch"        { return SWITCH; }
"while"         { return WHILE; }
"do"            { return DO; }
"for"           { return FOR; }
"goto"          { return GOTO; }
"continue"      { return CONTINUE; }
"break"         { return BREAK; }
"return"        { return RETURN; }
"struct"		{ return STRUCT; }
"typedef"		{ return TYPEDEF; }
"union"			{ return UNION; }
"restrict"      { return RESTRICT; }
"volatile"      { return VOLATILE; }
"const"         { return CONST; }
"inline"        { return INLINE; }


{STRING_CONSTANT} 			{ return STRING_LITERAL; }
{IDENTIFIER}				{ return IDENTIFIER; }
{INTEGER_CONSTANT} 			{ return INT_CONSTANT; }
{FLOATING_CONSTANT} 		{ return FLOAT_CONSTANT; }
{CHARACTER_CONSTANT} 		{ return CHAR_CONSTANT; }



"("				{ return OPENROUNDBRACKET; }
")"				{ return CLOSEROUNDBRACKET; }
"{"				{ return OPENCURLYBRACKET; }
"}"				{ return CLOSECURLYBRACKET; }
"["				{ return OPENSQUAREBRACKET; }
"]"				{ return CLOSESQUAREBRACKET; }
"-"				{ return MINUS; }
"--"			{ return DECREMENT; }
"="				{ return EQUAL; }
"=="			{ return EQUALEQUAL; }
"+"				{ return PLUS; }
"++"			{ return INCREMENT; }
"~"				{ return NOT; }
"!"				{ return EXCLAMATION; }
"#"				{ return HASH; }
"%"				{ return PERCENTAGE; }
"^"				{ return XOR; }
"&"				{ return AND; }
"&&"			{ return AND; }
"*"				{ return MULTIPLY; }
"||"			{ return OR; }
":"				{ return COLON; }
";"				{ return SEMICOLON; }
","				{ return COMMA; }
"<"				{ return LESSTHAN; }
"<<"			{ return LEFTSHIFT; }
"."				{ return DOT; }
">"				{ return GREATERTHAN; }
">>"			{ return RIGHTSHIFT; }
"?"				{ return QUESTIONMARK; }
"/"				{ return DIVIDE; }
"<="			{ return LESSTHANEQUAL; }
">="			{ return GREATERTHANEQUAL; }
"!="			{ return NOTEQUAL; }
"->"			{ return POINTER; }
"*="			{ return MULTIPLYASSIGN; }
"..."			{ return ELLIPSIS; }
"/="			{ return DIVIDEASSIGN; }
"%="			{ return MODASSIGN; }
"+="			{ return ADDASSIGN; }
"<<="			{ return LEFTSHIFTASSIGN; }
">>="			{ return RIGHTSHIFTASSIGN; }
"-="			{ return SUBTRACTASSIGN; }
"&="			{ return ANDASSIGN; }
"^="			{ return XORASSIGN; }
"|="			{ return ORASSIGN; }


{WHITESPACE}			{ /* whitespace separates tokens */ }

.							/* ignore */

%%