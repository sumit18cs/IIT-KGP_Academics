/*
Name: Sumit Kumar Yadav
Roll No.: 18CS30042
*/

%{ 
	#include <stdio.h>
	#include <string.h>
	extern int yylex();
	void yyerror(char *s);
%}

%union {
	int val;
}


// Punctuators and operators
%token  NOT EXCLAMATION HASH PERCENTAGE XOR AND MULTIPLY OPENROUNDBRACKET CLOSEROUNDBRACKET MINUS DECREMENT 
%token  EQUAL EQUALEQUAL ELLIPSIS SUBTRACTASSIGN ANDASSIGN ADDASSIGN ORASSIGN XORASSIGN GREATERTHANEQUAL
%token  PLUS INCREMENT OPENCURLYBRACKET CLOSECURLYBRACKET OPENSQUAREBRACKET CLOSESQUAREBRACKET OR COLON
%token  SEMICOLON COMMA LESSTHAN LEFTSHIFT DOT GREATERTHAN RIGHTSHIFT QUESTIONMARK DIVIDE LESSTHANEQUAL 
%token  NOTEQUAL POINTER MULTIPLYASSIGN DIVIDEASSIGN MODASSIGN LEFTSHIFTASSIGN RIGHTSHIFTASSIGN 


// Keywords
%token  SIZEOF EXTERN STATIC VOID CHAR SHORT INT LONG FLOAT DOUBLE CASE DEFAULT IF ELSE SWITCH 
%token  WHILE DO FOR GOTO CONTINUE  BREAK RETURN STRUCT TYPEDEF UNION RESTRICT VOLATILE CONST INLINE


// Extras 
%token INT_CONSTANT FLOAT_CONSTANT CHAR_CONSTANT IDENTIFIER STRING_LITERAL
%start translation_unit

%token SINGLE_LINE_COMMENT
%token MULTI_LINE_COMMENT

%%



// Primary Expression
constant : INT_CONSTANT | FLOAT_CONSTANT | CHAR_CONSTANT ;
primary_expression : IDENTIFIER | constant | STRING_LITERAL | OPENROUNDBRACKET expression CLOSEROUNDBRACKET 
{ printf("PRIMARY_EXPRESSION\n");};


// Postfix Expression
postfix_expression : primary_expression | postfix_expression OPENSQUAREBRACKET expression CLOSESQUAREBRACKET | postfix_expression OPENROUNDBRACKET CLOSEROUNDBRACKET | postfix_expression OPENROUNDBRACKET argument_expression_list CLOSEROUNDBRACKET | postfix_expression DOT IDENTIFIER | postfix_expression POINTER IDENTIFIER | postfix_expression INCREMENT | postfix_expression DECREMENT | OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENCURLYBRACKET initializer_list CLOSECURLYBRACKET |  OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENCURLYBRACKET initializer_list COMMA CLOSECURLYBRACKET 
{printf("POSTFIX_EXPRESSION\n");};


// Argument Expression List
argument_expression_list : assignment_expression | argument_expression_list COMMA assignment_expression 
{printf("ARGUMENT_EXPRESSION_LIST\n");};


// Unary Expression
unary_expression : postfix_expression | INCREMENT unary_expression | DECREMENT unary_expression | unary_operator cast_expression | SIZEOF unary_expression | SIZEOF OPENROUNDBRACKET type_name CLOSEROUNDBRACKET 
{printf("UNARY_EXPRESSION\n");};


// Unary Operator
unary_operator: AND | MULTIPLY | PLUS | MINUS | NOT | EXCLAMATION 
{printf("UNARY_OPERATOR\n");};


// Cast expression
cast_expression : unary_expression | OPENROUNDBRACKET type_name CLOSEROUNDBRACKET cast_expression 
{printf("CAST_EXPRESSION\n");};


// Multiplicative expression
multiplicative_expression : cast_expression | multiplicative_expression MULTIPLY cast_expression | multiplicative_expression DIVIDE cast_expression | multiplicative_expression PERCENTAGE cast_expression 
{printf("MULTIPLICATIVE_EXPRESSION\n");};


// Additive Expression
additive_expression : multiplicative_expression | additive_expression PLUS multiplicative_expression | additive_expression MINUS multiplicative_expression 
{printf("ADDITIVE_EXPRESSION\n");};


// Shift Expression
shift_expression : additive_expression | shift_expression LEFTSHIFT additive_expression | shift_expression RIGHTSHIFT additive_expression 
{printf("SHIFT_EXPRESSION\n");};


// Relational Expression
relational_expression : shift_expression | relational_expression LESSTHAN shift_expression | relational_expression GREATERTHAN shift_expression | relational_expression LESSTHANEQUAL shift_expression | relational_expression GREATERTHANEQUAL shift_expression 
{printf("RELATIONAL_EXPRESSION\n");};


// Equality Expression
equality_expression : relational_expression | equality_expression EQUALEQUAL relational_expression | equality_expression NOTEQUAL relational_expression 
{printf("EQUALITY_EXPRESSION\n");};


// And Expression
AND_expression : equality_expression | AND_expression AND equality_expression 
{printf("AND_expression\n");};


// Exclusive-OR-Expression:
exclusive_OR_expression : AND_expression | exclusive_OR_expression XOR AND_expression 
{printf("EXCLUSIVE_OR_EXPRESSION \n");}; 


// Inclusive_OR_Expression
inclusive_OR_expression : exclusive_OR_expression | inclusive_OR_expression '|' exclusive_OR_expression 
{printf("INCLUSIVE_OR_EXPRESSION\n");};


// Logical AND expression
logical_AND_expression : inclusive_OR_expression | logical_AND_expression AND inclusive_OR_expression 
{printf("LOGICAL_AND_EXPRESSION\n");};


// Logical OR expression
logical_OR_expression : logical_AND_expression | logical_OR_expression OR logical_AND_expression 
{printf("LOGICAL_OR_EXPRESSION \n");};


// Conditional expression
conditional_expression : logical_OR_expression | logical_OR_expression QUESTIONMARK expression COLON conditional_expression 
{printf("CONDITIONAL_EXPRESSION\n");};


// Assignment expression
assignment_expression : conditional_expression | unary_expression assignment_operator assignment_expression 
{printf("ASSIGNMENT_EXPRESSION\n");};


// Assignment operator
assignment_operator : EQUAL | MULTIPLYASSIGN | DIVIDEASSIGN | MODASSIGN | ADDASSIGN | SUBTRACTASSIGN | LEFTSHIFTASSIGN | RIGHTSHIFTASSIGN | ANDASSIGN | XORASSIGN | ORASSIGN 
{printf("ASSIGNMENT_OPERATOR\n");};


// Expression
expression : assignment_expression | expression COMMA assignment_expression 
{printf("EXPRESSION\n");};


// Constant Expression
constant_expression : conditional_expression 
{printf("CONSTANT_EXPRESSION\n");};


// declaration
declaration : declaration_specifiers SEMICOLON | declaration_specifiers init_declarator_list SEMICOLON 
{printf("DECLARATION\n");};


// Declaration Specifiers
declaration_specifiers : storage_class_specifier | storage_class_specifier declaration_specifiers | type_specifier | type_specifier declaration_specifiers | type_qualifier | type_qualifier declaration_specifiers | function_specifier  | function_specifier declaration_specifiers 
{printf("DECLARATION_SPECIFIERS\n");};


// Init declarator list
init_declarator_list : init_declarator | init_declarator_list COMMA init_declarator 
{printf("INIT_DECLARATOR_LIST\n");};


// Init Declarator
init_declarator : declarator | declarator EQUAL initializer 
{printf("INIT_DECLARATOR\n");};


// Type Qualifier
type_qualifier : CONST | VOLATILE | RESTRICT 
{printf("TYPE_QUAIFIER \n");};


// Storage Class Specifier
storage_class_specifier : EXTERN | STATIC 
{printf("STORAGE_CLASS_SPECIFIER\n");};


// Type Specifier
type_specifier : VOID | CHAR | SHORT | INT | LONG | FLOAT | DOUBLE  
{printf("TYPE_SPECIFIER\n");};


// Specifier Qualifier List
specifier_qualifier_list : type_specifier | type_specifier specifier_qualifier_list | type_qualifier | type_qualifier specifier_qualifier_list  
{printf("SPECIFIER_QUALIFIER_LIST\n");};


// Function Specifier
function_specifier : INLINE 
{printf("FUNCTION_SPECIFIER\n");};


// Declarator
declarator : pointer direct_declarator | direct_declarator 
{printf("DECLARATOR\n");};


// Direct Declarator
direct_declarator : IDENTIFIER | OPENROUNDBRACKET declarator CLOSEROUNDBRACKET | direct_declarator OPENSQUAREBRACKET  type_qualifier_list_opt assignment_expression_opt CLOSESQUAREBRACKET | direct_declarator OPENSQUAREBRACKET STATIC type_qualifier_list_opt assignment_expression CLOSESQUAREBRACKET | direct_declarator OPENSQUAREBRACKET type_qualifier_list STATIC assignment_expression CLOSESQUAREBRACKET | direct_declarator OPENSQUAREBRACKET type_qualifier_list_opt MULTIPLY CLOSESQUAREBRACKET | direct_declarator OPENROUNDBRACKET parameter_type_list CLOSEROUNDBRACKET | direct_declarator OPENROUNDBRACKET identifier_list_opt CLOSEROUNDBRACKET {printf("DIRECT_DECLARATOR\n");};
type_qualifier_list_opt : %empty | type_qualifier_list
assignment_expression_opt : %empty | assignment_expression
identifier_list_opt : %empty | identifier_list



// Pointer
pointer : MULTIPLY | MULTIPLY type_qualifier_list | MULTIPLY pointer | MULTIPLY type_qualifier_list pointer 
{printf("POINTER\n");};


// Type Qualifier List
type_qualifier_list : type_qualifier | type_qualifier_list type_qualifier
{printf("TYPE_QUALIFIER_LIST\n");};


// Parameter Type List
parameter_type_list : parameter_list | parameter_list COMMA ELLIPSIS 
{printf("PARAMETER_TYPE_LIST\n");};


// Parameter List
parameter_list : parameter_declaration | parameter_list COMMA parameter_declaration 
{printf("PARAMETER_LIST\n");};


// Parameter Declaration
parameter_declaration : declaration_specifiers declarator | declaration_specifiers 
{printf("PARAMETER_DECLARATION\n");};


// Identifier List
identifier_list: IDENTIFIER | identifier_list COMMA IDENTIFIER 
{printf("IDENTIFIER_LIST\n");};


// Type Name
type_name : specifier_qualifier_list 
{printf("TYPE_NAME\n");};


// Initializer
initializer : assignment_expression | OPENCURLYBRACKET initializer_list CLOSECURLYBRACKET | OPENCURLYBRACKET initializer_list COMMA CLOSECURLYBRACKET
{printf("INITIALIZER\n");};


// Initializer List
initializer_list : designation_opt initializer | initializer_list COMMA designation_opt initializer {printf("INITIALIZER_LIST\n");};
designation_opt : %empty | designation


// Designation
designation : designator_list EQUAL 
{printf("DESIGNATION\n");};


// Designator List
designator_list : designator | designator_list designator 
{printf("DESIGNATOR_LIST\n");};


// Designator
designator : OPENSQUAREBRACKET constant_expression CLOSESQUAREBRACKET | DOT IDENTIFIER 
{printf("DESIGNATOR\n");};


// Statement
statement : labeled_statement | compound_statement | expression_statement | selection_statement | iteration_statement | jump_statement 
{printf("STATEMENT\n");} ;


// Labeled Statement
labeled_statement : IDENTIFIER COLON statement | CASE constant_expression COLON statement | DEFAULT COLON statement 
{printf("LABELED_STATMENT\n");};


// Compound Statement
compound_statement : OPENCURLYBRACKET CLOSECURLYBRACKET | OPENCURLYBRACKET block_item_list CLOSECURLYBRACKET 
{printf("COMPOUND_STATEMENT\n");};


// Block Item List
block_item_list : block_item | block_item_list block_item 
{printf("BLOCK_ITEM_LIST\n");};


// Block Item
block_item : declaration | statement 
{printf("BLOCK_ITEM\n");};


// Expression Statemt
expression_statement : SEMICOLON | expression SEMICOLON 
{printf("EXPRESSION_STATEMENT\n");};


// Selection Statement
selection_statement : IF OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement | IF OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement ELSE statement | SWITCH OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement 
{printf("SELECTION_STATEMENT\n");};


// Looping Statements
iteration_statement : WHILE OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement | DO statement WHILE OPENROUNDBRACKET expression CLOSEROUNDBRACKET SEMICOLON | FOR OPENROUNDBRACKET expression_opt SEMICOLON expression_opt SEMICOLON expression_opt CLOSEROUNDBRACKET statement  
{printf("ITERATION_STATEMENT\n");};
expression_opt : %empty | expression


// Jump Statements
jump_statement : GOTO IDENTIFIER SEMICOLON | CONTINUE SEMICOLON | BREAK SEMICOLON | RETURN SEMICOLON | RETURN expression SEMICOLON 
{printf("JUMP_STATEMENT\n");} ;


// Translation Unit
translation_unit : external_declaration | translation_unit external_declaration 
{printf("TRANSLATION_UNIT\n");};


// External Declaration
external_declaration : function_definition | declaration 
{printf("EXTERNAL_DECLARATION\n");};


// Function Definition
function_definition : declaration_specifiers declarator declaration_list compound_statement | declaration_specifiers declarator compound_statement 
{printf("FUNCTION_DEFINITION\n");};


// Declartation List
declaration_list : declaration | declaration_list declaration 
{printf("DECLARATION_LIST\n");};


%%

void yyerror(char *s) {
	printf ("ERROR IS : %s",s);
}