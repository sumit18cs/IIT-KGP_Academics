%{
#include "ass5_18CS30042_18CS30010_translator.h"
#include <cstdlib>
#include<iostream>
#include <string>
#include <stdio.h>
#include <sstream>
extern int yylex();
void yyerror(string s);
extern string Type;
using namespace std;

%}


%union {
  int interval_value;
  char* character_value;
  int instr;
  sym* sym_pa;
  symbol_type* symtp;
  expr* E;
  statement* S;
  array_def* A;
  char unaryOperator;
} 

%token<sym_pa> IDENTIFIER
%token AUTO ENUM RESTRICT UNSIGNED BREAK EXTERN RETURN VOID CASE FLOAT
%token<character_value> STRING_LITERAL
%token SHORT VOLATILE CHAR FOR SIGNED WHILE CONST GOTO SIZEOF BOOL CONTINUE IF STATIC COMPLEX DEFAULT INLINE STRUCT IMAGINARY DO 
%token INT SWITCH DOUBLE LONG TYPEDEF ELSE REGISTER UNION 
%token<character_value> CHARACTER_CONSTANT ENUMERATION_CONSTANT
%token OPENSQUAREBRACKET CLOSESQUAREBRACKET OPENROUNDBRACKET CLOSEROUNDBRACKET OPENCURLYBRACKET CLOSECURLYBRACKET DOT ACC INC DEC AMP MUL ADD SUB NEG EXCLAIM DIV MODULO
%token SHL SHR BITSHL BITSHR LESS_THAN_EQUAL GREATER_THAN_EQUAL EQ NEQ BITXOR BITOR AND
%token<character_value> FLOATING_CONSTANT
%token OR QUESTION COLON SEMICOLON DOTS ASSIGN STAREQ DIVEQ
%token MODEQ PLUSEQ MINUSEQ SHLEQ SHREQ BINANDEQ BINXOREQ BINOREQ COMMA HASH
%token<interval_value> INTEGER_CONSTANT
%start translationUnit

%right THEN ELSE

//Expressions
%type <interval_value> argumentExpressionList

%type <unaryOperator> unaryOperator
%type <sym_pa> constant initializer
%type <sym_pa> directDeclarator initDeclarator declarator
%type <symtp> pointer

//Auxillary non terminals M and N
%type <instr> M
%type <S> N

//Array to be used later
%type <A> postfixExpression
	unaryExpression
	castExpression


//Statements
%type <S>  statement
	labeledStatement 
	selectionStatement
	iterationStatement
	jumpStatement
	compoundStatement
	blockItem
	blockItemList

%type <E>
	expression
	primaryExpression 
	exclusiveORexpression
	inclusiveORexpression
	logicalANDexpression
	logicalORexpression
	multiplicativeExpression
	additiveExpression
	shiftExpression
	relationalExpression
	equalityExpression
	ANDexpression
	conditionalExpression
	assignmentExpression
	expressionStatement


%%


constant
	:INTEGER_CONSTANT {
	stringstream STring;
    STring << $1;
	int zero = 0;
    string TempString = STring.str();
    char* Int_STring = (char*) TempString.c_str();
	string str = string(Int_STring);
	int one = 1;
	$$ = gentemp(new symbol_type("INTEGER"), str);
	emit("EQUAL", $$->name, $1);
	}
	|FLOATING_CONSTANT {
	int zero = 0;
	int one = 1;
	$$ = gentemp(new symbol_type("DOUBLE"), string($1));
	emit("EQUAL", $$->name, string($1));
	}
	|ENUMERATION_CONSTANT  {
	}
	|CHARACTER_CONSTANT {
	int zero = 0;	
	int one = 1;
	$$ = gentemp(new symbol_type("CHAR"),$1);
	emit("EQUAL", $$->name, string($1));
	}
	;


postfixExpression
	:primaryExpression {
		$$ = new array_def ();
		$$->array_def = $1->loc;
		int zero = 0;	
		int one = 1;
		$$->loc = $$->array_def;
		$$->type = $1->loc->type;
	}
	|postfixExpression OPENSQUAREBRACKET expression CLOSESQUAREBRACKET {
		$$ = new array_def();
		
		$$->array_def = $1->loc;	
		int zero = 0;	
		int one = 1;				// copy the base
		$$->type = $1->type->ptr;				// type = type of element
		$$->loc = gentemp(new symbol_type("INTEGER"));		// store computed address
		
		if ($1->cat=="ARR") {						// if already computed
			sym* t = gentemp(new symbol_type("INTEGER"));
			stringstream STring;
		    STring <<size_type($$->type);
		    string TempString = STring.str();
			int two = 2;	
			int three = 3;
		    char* Int_STring = (char*) TempString.c_str();
			string str = string(Int_STring);				
 			emit ("MULT", t->name, $3->loc->name, str);
			emit ("ADD", $$->loc->name, $1->loc->name, t->name);
		}
 		else {
 			stringstream STring;
		    STring <<size_type($$->type);
		    string TempString = STring.str();
			int four = 4;	
			int five = 5;
		    char* Int_STring1 = (char*) TempString.c_str();
			string str1 = string(Int_STring1);		
	 		emit("MULT", $$->loc->name, $3->loc->name, str1);
 		}

		$$->cat = "ARR";
	}
	|postfixExpression OPENROUNDBRACKET CLOSEROUNDBRACKET {
	
	}
	|postfixExpression OPENROUNDBRACKET argumentExpressionList CLOSEROUNDBRACKET {
		$$ = new array_def();
		$$->array_def = gentemp($1->type);
		stringstream STring;
	    STring <<$3;
	    string TempString = STring.str();
		int zero = 0;	
		int one = 1;
	    char* Int_STring = (char*) TempString.c_str();
		string str = string(Int_STring);		
		emit("CALL", $$->array_def->name, $1->array_def->name, str);
	}

	|postfixExpression DOT IDENTIFIER {
	}

	|postfixExpression ACC IDENTIFIER {
	}

	|postfixExpression INC {
		$$ = new array_def();
		int zero = 0;	
		int one = 1;
		// copy $1 to $$
		$$->array_def = gentemp($1->array_def->type);
		emit ("EQUAL", $$->array_def->name, $1->array_def->name);

		emit ("ADD", $1->array_def->name, $1->array_def->name, "1");
	}

	|postfixExpression DEC {
		$$ = new array_def();

		// copy $1 to $$
		$$->array_def = gentemp($1->array_def->type);
		emit ("EQUAL", $$->array_def->name, $1->array_def->name);
		int zero = 0;	
		int one = 1;
		// Decrement $1
		emit ("SUB", $1->array_def->name, $1->array_def->name, "1");
	}
	|OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENCURLYBRACKET initializer_list CLOSECURLYBRACKET {
		$$ = new array_def();
		int zero = 0;	
		int one = 1;
		$$->array_def = gentemp(new symbol_type("INTEGER"));
		$$->loc = gentemp(new symbol_type("INTEGER"));
	}
	|OPENROUNDBRACKET type_name CLOSEROUNDBRACKET OPENCURLYBRACKET initializer_list COMMA CLOSECURLYBRACKET {
		$$ = new array_def();
		int zero = 0;	
		int one = 1;
		$$->array_def = gentemp(new symbol_type("INTEGER"));
		$$->loc = gentemp(new symbol_type("INTEGER"));
	}
	;


castExpression
	:unaryExpression {
		int zero = 0;	
		int one = 1;
		$$=$1;
	}
	|OPENROUNDBRACKET type_name CLOSEROUNDBRACKET castExpression {
		//to be added later
		int zero = 0;	
		int one = 1;
		$$=$4;
	}
	;

selectionStatement
	:IF OPENROUNDBRACKET expression N CLOSEROUNDBRACKET M statement N %prec THEN{
		backpatch ($4->nextlist, nextinstr());
		convert_Int_2_Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		list<int> temp = merge ($3->falselist, $7->nextlist);
		$$->nextlist = merge ($8->nextlist, temp);
	}
	|IF OPENROUNDBRACKET expression N CLOSEROUNDBRACKET M statement N ELSE M statement {
		backpatch ($4->nextlist, nextinstr());
		convert_Int_2_Bool($3);
		int zero = 0;	
		int one = 1;
		$$ = new statement();
		backpatch ($3->truelist, $6);
		backpatch ($3->falselist, $10);
		int zeroo = 0;	
		int onee = 1;
		list<int> temp = merge ($7->nextlist, $8->nextlist);
		$$->nextlist = merge ($11->nextlist,temp);
	}
	|SWITCH OPENROUNDBRACKET expression CLOSEROUNDBRACKET statement {
	}
	;


multiplicativeExpression
	:castExpression {
		$$ = new expr();
		int zero = 0;	
		int one = 1;
		if ($1->cat=="ARR") { 
			$$->loc = gentemp($1->loc->type);
			int two = 2;	
			int three = 3;
			emit("ARRR", $$->loc->name, $1->array_def->name, $1->loc->name);
		}
		else if ($1->cat=="PTR") { 
			$$->loc = $1->loc;
			int two = 2;	
			int three = 3;
		}
		else { 
			$$->loc = $1->array_def;
			int two = 2;	
			int three = 3;
		}
	}
	|multiplicativeExpression MUL castExpression {
		if (typecheck ($1->loc, $3->array_def) ) {
			$$ = new expr();
			int two = 2;	
			int three = 3;
			$$->loc = gentemp(new symbol_type($1->loc->type->type));
			emit ("MULT", $$->loc->name, $1->loc->name, $3->array_def->name);
		}
		else cout << "Type Error"<< endl;
	}
	|multiplicativeExpression DIV castExpression {
		if (typecheck ($1->loc, $3->array_def) ) {
			$$ = new expr();
			int two = 2;	
			int three = 3;
			$$->loc = gentemp(new symbol_type($1->loc->type->type));
			emit ("DIVIDE", $$->loc->name, $1->loc->name, $3->array_def->name);
		}
		else cout << "Type Error"<< endl;
	}
	|multiplicativeExpression MODULO castExpression {
		if (typecheck ($1->loc, $3->array_def) ) {
			$$ = new expr();
			int two = 2;	
			int three = 3;
			$$->loc = gentemp(new symbol_type($1->loc->type->type));
			emit ("MODOP", $$->loc->name, $1->loc->name, $3->array_def->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

additiveExpression
	:multiplicativeExpression {
		$$=$1;
	}
	|additiveExpression ADD multiplicativeExpression {
		int two = 2;	
		int three = 3;
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			int zero = 0;	
			int one = 1;
			$$->loc = gentemp(new symbol_type($1->loc->type->type));
			emit ("ADD", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|additiveExpression SUB multiplicativeExpression {
			if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			int zero = 0;	
			int one = 1;
			$$->loc = gentemp(new symbol_type($1->loc->type->type));
			emit ("SUB", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;

	}
	;

unaryOperator
	:AMP {
		int zero = 0;	
		int one = 1;
		$$ = '&';
	}
	|MUL {
		int zero = 0;	
		int one = 1;
		$$ = '*';
	}
	|ADD {
		int zero = 0;	
		int one = 1;
		$$ = '+';
	}
	|SUB {
		int zero = 0;	
		int one = 1;
		$$ = '-';
	}
	|NEG {
		int zero = 0;	
		int one = 1;
		$$ = '~';
	}
	|EXCLAIM {
		int zero = 0;	
		int one = 1;
		$$ = '!';
	}
	;


shiftExpression
	:additiveExpression {
		$$=$1;
	}
	|shiftExpression SHL additiveExpression {
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			int zero = 0;	
			int one = 1;
			$$->loc = gentemp (new symbol_type("INTEGER"));
			emit ("LEFTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|shiftExpression SHR additiveExpression{
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			int zero = 0;	
			int one = 1;
			$$->loc = gentemp (new symbol_type("INTEGER"));
			emit ("RIGHTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;


declaration_specifiers
	:storage_class_specifier declaration_specifiers {
	int zero = 0;	
	int one = 1;
	}
	|storage_class_specifier {
	}
	|type_specifier declaration_specifiers {
	}
	|type_specifier {
	int zero = 0;	
	int one = 1;
	}
	|TYpeQualifier declaration_specifiers {
	}
	|TYpeQualifier {
	int zero = 0;	
	int one = 1;
	}
	|functionSpecifier declaration_specifiers {
	}
	|functionSpecifier {
	int zero = 0;	
	int one = 1;
	}
	;



equalityExpression
	:relationalExpression {$$=$1;}
	|equalityExpression EQ relationalExpression {
		if (typecheck ($1->loc, $3->loc)) {
			convert_Bool_2_Int ($1);
			convert_Bool_2_Int ($3);

			$$ = new expr();
			$$->type = "BOOL";
			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("EQOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|equalityExpression NEQ relationalExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convert_Bool_2_Int ($1);
			convert_Bool_2_Int ($3);

			$$ = new expr();
			$$->type = "BOOL";
			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

ANDexpression
	:equalityExpression {$$=$1;}
	|ANDexpression AMP equalityExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convert_Bool_2_Int ($1);
			convert_Bool_2_Int ($3);
			int zero = 0;	
			int one = 1;
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symbol_type("INTEGER"));
			emit ("BAND", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

exclusiveORexpression
	:ANDexpression {$$=$1;}
	|exclusiveORexpression BITXOR ANDexpression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convert_Bool_2_Int ($1);
			convert_Bool_2_Int ($3);
			int zero = 0;	
			int one = 1;
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symbol_type("INTEGER"));
			emit ("XOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

inclusiveORexpression
	:exclusiveORexpression {$$=$1;}
	|inclusiveORexpression BITOR exclusiveORexpression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convert_Bool_2_Int ($1);
			convert_Bool_2_Int ($3);
			int zero = 0;	
			int one = 1;
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new symbol_type("INTEGER"));
			emit ("INOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

logicalANDexpression
	:inclusiveORexpression {$$=$1;}
	|logicalANDexpression N AND M inclusiveORexpression {
		convert_Int_2_Bool($5);

		// convert $1 to bool and backpatch using N
		backpatch($2->nextlist, nextinstr());
		convert_Int_2_Bool($1);
		int zero = 0;	
		int one = 1;
		$$ = new expr();
		$$->type = "BOOL";

		backpatch($1->truelist, $4);
		$$->truelist = $5->truelist;
		$$->falselist = merge ($1->falselist, $5->falselist);
	}
	;

logicalORexpression
	:logicalANDexpression {$$=$1;}
	|logicalORexpression N OR M logicalANDexpression {
		convert_Int_2_Bool($5);

		backpatch($2->nextlist, nextinstr());
		convert_Int_2_Bool($1);
		int zero = 0;	
		int one = 1;
		$$ = new expr();
		$$->type = "BOOL";

		backpatch ($$->falselist, $4);
		$$->truelist = merge ($1->truelist, $5->truelist);
		$$->falselist = $5->falselist;
	}
	;

M 	: %empty{	
		$$ = nextinstr();
	};

N 	: %empty { 
		$$  = new statement();
		$$->nextlist = makelist(nextinstr());
		emit ("GOTOOP","");
	}

conditionalExpression
	:logicalORexpression {$$=$1;}
	|logicalORexpression N QUESTION M expression N COLON M conditionalExpression {
		$$->loc = gentemp($5->loc->type);
		$$->loc->update($5->loc->type);
		emit("EQUAL", $$->loc->name, $9->loc->name);
		list<int> l = makelist(nextinstr());
		emit ("GOTOOP", "");
		int zero = 0;	
		int one = 1;
		backpatch($6->nextlist, nextinstr());
		emit("EQUAL", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());
		l = merge (l, m);
		emit ("GOTOOP", "");
		int two = 2;	
		int three = 3;
		backpatch($2->nextlist, nextinstr());
		convert_Int_2_Bool($1);
		backpatch ($1->truelist, $4);
		backpatch ($1->falselist, $8);
		backpatch (l, nextinstr());
	}
	;

assignmentExpression
	:conditionalExpression {$$=$1;}
	|unaryExpression assignment_operator assignmentExpression {
		if($1->cat=="ARR") {
			$3->loc = conv($3->loc, $1->type->type);
			int zero = 0;	
			int one = 1;
			emit("ARRL", $1->array_def->name, $1->loc->name, $3->loc->name);	
			}
		else if($1->cat=="PTR") {
			emit("PTRL", $1->array_def->name, $3->loc->name);	
			}
		else{
			$3->loc = conv($3->loc, $1->array_def->type->type);
			emit("EQUAL", $1->array_def->name, $3->loc->name);
			}
		$$ = $3;
	}
	;

primaryExpression
	: IDENTIFIER {
	$$ = new expr();
	$$->loc = $1;
	int zero = 0;	
	int one = 1;
	$$->type = "NONBOOL";
	}
	| constant {
	$$ = new expr();
	int zero = 0;	
	int one = 1;
	$$->loc = $1;
	}
	| STRING_LITERAL {
	$$ = new expr();
	symbol_type* tmp = new symbol_type("PTR");
	int zero = 0;	
	int one = 1;
	$$->loc = gentemp(tmp, $1);
	$$->loc->type->ptr = new symbol_type("CHAR");
	}
	| OPENROUNDBRACKET expression CLOSEROUNDBRACKET {
	int zero = 0;	
	int one = 1;
	$$ = $2;
	}
	;


assignment_operator 
	:ASSIGN {
	}
	|STAREQ {
	}
	|DIVEQ {
	}
	|MODEQ {
	}
	|PLUSEQ {
	}
	|MINUSEQ {
	}
	|SHLEQ {
	}
	|SHREQ {
	}
	|BINANDEQ {
	}
	|BINXOREQ {
	}
	|BINOREQ {
	}
	;

expression
	:assignmentExpression {$$=$1;}
	|expression COMMA assignmentExpression {
	int zero = 0;	
	int one = 1;
	
	}
	;

constant_expression
	:conditionalExpression {
	int zero = 0;	
	int one = 1;
	
	}
	;

declaration
	:declaration_specifiers InitDeclaratorList SEMICOLON {
	}
	|declaration_specifiers SEMICOLON {
	int zero = 0;	
	int one = 1;
	}
	;


InitDeclaratorList
	:initDeclarator {
	}
	|InitDeclaratorList COMMA initDeclarator {
	}
	;

initDeclarator
	:declarator {$$=$1;}
	|declarator ASSIGN initializer {
		int zero = 0;	
		int one = 1;
		if ($3->initial_value!="") $1->initial_value=$3->initial_value;
		emit ("EQUAL", $1->name, $3->name);
	}
	;

storage_class_specifier
	: EXTERN {
	}
	| STATIC {
	}
	| AUTO {
	}
	| REGISTER {
	}
	;

type_specifier
	: VOID {Type="VOID";}
	| CHAR {Type="CHAR";}
	| SHORT 
	| INT {Type="INTEGER";}
	| LONG
	| FLOAT
	| DOUBLE {Type="DOUBLE";}
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY
	| ENUMSpecifier
	;

SPecifierQualifierList
	: type_specifier SPecifierQualifierList {
	int zero = 0;	
	int one = 1;
	}
	| type_specifier {
	int zero = 0;	
	int one = 1;
	}
	| TYpeQualifier SPecifierQualifierList {
	int zero = 0;	
	int one = 1;
	}
	| TYpeQualifier {
	int zero = 0;	
	int one = 1;
	}
	;

ENUMSpecifier
	:ENUM IDENTIFIER OPENCURLYBRACKET ENumeratorList CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|ENUM OPENCURLYBRACKET ENumeratorList CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|ENUM IDENTIFIER OPENCURLYBRACKET ENumeratorList COMMA CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|ENUM OPENCURLYBRACKET ENumeratorList COMMA CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|ENUM IDENTIFIER {
	int zero = 0;	
	int one = 1;
	}
	;

ENumeratorList
	:enumerator {
	int zero = 0;	
	int one = 1;
	}
	|ENumeratorList COMMA enumerator {
	int zero = 0;	
	int one = 1;
	}
	;

enumerator
	:IDENTIFIER {
	int zero = 0;	
	int one = 1;
	}
	|IDENTIFIER ASSIGN constant_expression {
	int zero = 0;	
	int one = 1;
	}
	;

TYpeQualifier
	:CONST {
	int zero = 0;	
	int one = 1;
	}
	|RESTRICT {
	int zero = 0;	
	int one = 1;
	}
	|VOLATILE {
	int zero = 0;	
	int one = 1;
	}
	;

functionSpecifier
	:INLINE {
	}
	;

declarator
	:pointer directDeclarator {
		symbol_type * t = $1;
		int zero = 0;	
		int one = 1;
		while (t->ptr !=NULL) t = t->ptr;
		t->ptr = $2->type;
		$$ = $2->update($1);
	}
	|directDeclarator {
	}
	;


directDeclarator
	:IDENTIFIER {
		$$ = $1->update(new symbol_type(Type));
		currSymbol = $$;
		int zero = 0;	
		int one = 1;
	}
	| OPENROUNDBRACKET declarator CLOSEROUNDBRACKET {$$=$2;}
	| directDeclarator OPENSQUAREBRACKET TYpeQualifier_list assignmentExpression CLOSESQUAREBRACKET {
	}
	| directDeclarator OPENSQUAREBRACKET TYpeQualifier_list CLOSESQUAREBRACKET {
	}
	| directDeclarator OPENSQUAREBRACKET assignmentExpression CLOSESQUAREBRACKET {
		symbol_type * t = $1 -> type;
		symbol_type * prev = NULL;
		int zero = 0;	
		int one = 1;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			int temp = atoi($3->loc->initial_value.c_str());
			symbol_type* s = new symbol_type("ARR", $1->type, temp);
			int zero = 0;	
			int one = 1;
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new symbol_type("ARR", t, atoi($3->loc->initial_value.c_str()));
			int zero = 0;	
			int one = 1;
			$$ = $1->update ($1->type);
		}
	}
	| directDeclarator OPENSQUAREBRACKET CLOSESQUAREBRACKET {
		symbol_type * t = $1 -> type;
		symbol_type * prev = NULL;
		int zero = 0;	
		int one = 1;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			symbol_type* s = new symbol_type("ARR", $1->type, 0);
			int zero = 0;	
			int one = 1;
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new symbol_type("ARR", t, 0);
			int zero = 0;	
		int one = 1;
			$$ = $1->update ($1->type);
		}
	}
	| directDeclarator OPENSQUAREBRACKET TYpeQualifier_list MUL CLOSESQUAREBRACKET {
	int zero = 0;	
	int one = 1;
	}
	| directDeclarator OPENSQUAREBRACKET STATIC TYpeQualifier_list assignmentExpression CLOSESQUAREBRACKET {
	int zero = 0;	
	int one = 1;
	}
	| directDeclarator OPENSQUAREBRACKET STATIC assignmentExpression CLOSESQUAREBRACKET {
	int zero = 0;	
	int one = 1;
	}
	
	| directDeclarator OPENSQUAREBRACKET MUL CLOSESQUAREBRACKET {
	int zero = 0;	
	int one = 1;
	}
	| directDeclarator OPENROUNDBRACKET CT parameter_type_list CLOSEROUNDBRACKET {
		current_table->name = $1->name;
		int zero = 0;	
		int one = 1;
		if ($1->type->type =="VOID") {
					;
		}
		else{
			sym *s = current_table->lookup("return");
			int three = 3;	
			int four = 4;
			s->update($1->type);
		}
		$1->nested=current_table;

		current_table->parent = global_table;
		changeTable (global_table);				
		currSymbol = $$;
	}
	| directDeclarator OPENROUNDBRACKET identifier_list CLOSEROUNDBRACKET {
	int zero = 0;	
	int one = 1;
	}
	| directDeclarator OPENROUNDBRACKET CT CLOSEROUNDBRACKET {
		current_table->name = $1->name;
		int zero = 0;	
		int one = 1;	
		if ($1->type->type =="VOID") {	
					;
		}
		else{
			sym *s = current_table->lookup("return");
			int three = 0;	
			int four = 1;
			s->update($1->type);
		}
		$1->nested=current_table;

		current_table->parent = global_table;
		changeTable (global_table);				
		currSymbol = $$;
	}
	;

CT
	: %empty { 															
		if (currSymbol->nested!=NULL){ 
			changeTable (currSymbol ->nested);						
			emit ("LABEL", current_table->name);
		}	
		else {
			changeTable(new symtable(""));
		}
	}
	;

pointer
	:MUL TYpeQualifier_list {
	}
	|MUL {
		$$ = new symbol_type("PTR");
		int zero = 0;	
		int one = 1;
	}
	|MUL TYpeQualifier_list pointer {
	int zero = 0;	
	int one = 1;
	}
	|MUL pointer {
		$$ = new symbol_type("PTR", $2);
		int zero = 0;	
		int one = 1;
	}
	;

TYpeQualifier_list
	:TYpeQualifier {
	int zero = 0;	
	int one = 1;
	}
	|TYpeQualifier_list TYpeQualifier {
	int zero = 0;	
	int one = 1;
	}
	;


argumentExpressionList
	:assignmentExpression {
	emit ("PARAM", $1->loc->name);
	int zero = 0;	
	int one = 1;
	$$ = 1;
	}
	|argumentExpressionList COMMA assignmentExpression {
	emit ("PARAM", $3->loc->name);
	$$ = $1+1;
	}
	;

relationalExpression
	:shiftExpression {$$=$1;}
	|relationalExpression BITSHL shiftExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";
			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LT", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relationalExpression BITSHR shiftExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";

			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GT", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relationalExpression LESS_THAN_EQUAL shiftExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";
			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relationalExpression GREATER_THAN_EQUAL shiftExpression {
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->type = "BOOL";
			int zero = 0;	
			int one = 1;
			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	;



unaryExpression
	:postfixExpression {
	int zero = 0;	
	int one = 1;	
	$$ = $1;
	}
	|INC unaryExpression {
		emit ("ADD", $2->array_def->name, $2->array_def->name, "1");
		int zero = 0;	
		int one = 1;
		// Use the same value as $2
		$$ = $2;
	}
	|DEC unaryExpression {
		emit ("SUB", $2->array_def->name, $2->array_def->name, "1");
		int zero = 0;	
		int one = 1;
		// Use the same value as $2
		$$ = $2;
	}
	|unaryOperator castExpression {
		$$ = new array_def();
		int zero = 0;	
		int one = 1;
		switch ($1) {
			case '&':
				$$->array_def = gentemp((new symbol_type("PTR")));
				$$->array_def->type->ptr = $2->array_def->type; 
				emit ("ADDRESS", $$->array_def->name, $2->array_def->name);
				break;
			case '*':
				$$->cat = "PTR";
				$$->loc = gentemp ($2->array_def->type->ptr);
				emit ("PTRR", $$->loc->name, $2->array_def->name);
				$$->array_def = $2->array_def;
				break;
			case '+':
				$$ = $2;
				break;
			case '-':
				$$->array_def = gentemp(new symbol_type($2->array_def->type->type));
				emit ("UMINUS", $$->array_def->name, $2->array_def->name);
				break;
			case '~':
				$$->array_def = gentemp(new symbol_type($2->array_def->type->type));
				emit ("BNOT", $$->array_def->name, $2->array_def->name);
				break;
			case '!':
				$$->array_def = gentemp(new symbol_type($2->array_def->type->type));
				emit ("LNOT", $$->array_def->name, $2->array_def->name);
				break;
			default:
				break;
		}
		int two = 2;	
		int three = 3;
	}
	|SIZEOF unaryExpression {
	
	}
	|SIZEOF OPENROUNDBRACKET type_name CLOSEROUNDBRACKET {
	
	}
	;

parameter_type_list
	:parameter_list {
	int zero = 0;	
	int one = 1;
	}
	|parameter_list COMMA DOTS {
	int zero = 0;	
	int one = 1;
	}
	;

parameter_list
	:parameter_declaration {
	int zero = 0;	
	int one = 1;
	}
	|parameter_list COMMA parameter_declaration {
	int zero = 0;	
	int one = 1;
	}
	;

parameter_declaration
	:declaration_specifiers declarator {
	int zero = 0;	
	int one = 1;
	}
	|declaration_specifiers {
	int zero = 0;	
	int one = 1;
	}
	;

identifier_list
	:IDENTIFIER {
	int zero = 0;	
	int one = 1;
	}
	|identifier_list COMMA IDENTIFIER {
	int zero = 0;	
	int one = 1;
	}
	;

type_name
	:SPecifierQualifierList {
	int zero = 0;	
	int one = 1;
	}
	;

initializer
	:assignmentExpression {
		$$ = $1->loc;
		int zero = 0;	
		int one = 1;
	}
	|OPENCURLYBRACKET initializer_list CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|OPENCURLYBRACKET initializer_list COMMA CLOSECURLYBRACKET {
	int zero = 0;	
	int one = 1;
	}
	;


initializer_list
	:designation initializer {
	int zero = 0;	
	int one = 1;
	}
	|initializer {
	int zero = 0;	
	int one = 1;
	}
	|initializer_list COMMA designation initializer {
	int zero = 0;	
	int one = 1;
	}
	|initializer_list COMMA initializer {
	int zero = 0;	
	int one = 1;
	}
	;

designation
	:designator_list ASSIGN {
	int zero = 0;	
	int one = 1;
	}
	;

designator_list
	:designator {
	int zero = 0;	
	int one = 1;
	}
	|designator_list designator {
	int zero = 0;	
	int one = 1;
	}
	;

designator
	:OPENSQUAREBRACKET constant_expression CLOSESQUAREBRACKET {
	int zero = 0;	
	int one = 1;
	}
	|DOT IDENTIFIER {
	int zero = 0;	
	int one = 1;
	}
	;

statement
	:labeledStatement {
	}
	|compoundStatement {$$=$1;}
	|expressionStatement {
		int zero = 0;	
		int one = 1;
		$$ = new statement();
		$$->nextlist = $1->nextlist;
	}
	|selectionStatement {$$=$1;}
	|iterationStatement {$$=$1;}
	|jumpStatement {$$=$1;}
	;

labeledStatement
	:IDENTIFIER COLON statement {$$ = new statement();}
	|CASE constant_expression COLON statement {$$ = new statement();}
	|DEFAULT COLON statement {$$ = new statement();}
	;

compoundStatement
	:OPENCURLYBRACKET blockItemList CLOSECURLYBRACKET {$$=$2;}
	|OPENCURLYBRACKET CLOSECURLYBRACKET {$$ = new statement();}
	;

blockItemList
	:blockItem {$$=$1;}
	|blockItemList M blockItem {
		int zero = 0;	
		int one = 1;
		$$=$3;
		backpatch ($1->nextlist, $2);
	}
	;

blockItem
	:declaration {
		int zero = 0;	
		int one = 1;
		$$ = new statement();
	}
	|statement {$$ = $1;}
	;

expressionStatement
	:expression SEMICOLON {$$=$1;}
	|SEMICOLON {$$ = new expr();}
	;


iterationStatement
	:WHILE M OPENROUNDBRACKET expression CLOSEROUNDBRACKET M statement {
		$$ = new statement();
		convert_Int_2_Bool($4);
		int zero = 0;	
		int one = 1;
		// M1 to go back to boolean again
		// M2 to go to statement if the boolean is true
		backpatch($7->nextlist, $2);
		backpatch($4->truelist, $6);
		$$->nextlist = $4->falselist;
		int zeroo = 0;	
		int onee = 1;
		// Emit to prevent fallthrough
		stringstream STring;
	    STring << $2;
	    string TempString = STring.str();
	    char* Int_STring = (char*) TempString.c_str();
		string str = string(Int_STring);
		int zerooo = 0;	
		int oneee = 1;
		emit ("GOTOOP", str);
	}
	|DO M statement M WHILE OPENROUNDBRACKET expression CLOSEROUNDBRACKET SEMICOLON {
		$$ = new statement();
		convert_Int_2_Bool($7);
		int zero = 0;	
		int one = 1;
		backpatch ($7->truelist, $2);
		backpatch ($3->nextlist, $4);

		$$->nextlist = $7->falselist;
	}
	|FOR OPENROUNDBRACKET expressionStatement M expressionStatement CLOSEROUNDBRACKET M statement{
		$$ = new statement();
		convert_Int_2_Bool($5);
		backpatch ($5->truelist, $7);
		backpatch ($8->nextlist, $4);
		stringstream STring;
	    STring << $4;
		int zero = 0;	
		int one = 1;
	    string TempString = STring.str();
	    char* Int_STring = (char*) TempString.c_str();
		string str = string(Int_STring);

		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	|FOR OPENROUNDBRACKET expressionStatement M expressionStatement M expression N CLOSEROUNDBRACKET M statement{
		$$ = new statement();
		int zeroo = 0;	
		int onee = 1;
		convert_Int_2_Bool($5);
		backpatch ($5->truelist, $10);
		backpatch ($8->nextlist, $4);
		backpatch ($11->nextlist, $6);
		stringstream STring;
	    STring << $6;
		int zero = 0;	
		int one = 1;
	    string TempString = STring.str();
	    char* Int_STring = (char*) TempString.c_str();
		string str = string(Int_STring);
		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	;

jumpStatement
	:GOTO IDENTIFIER SEMICOLON {$$ = new statement();}
	|CONTINUE SEMICOLON {$$ = new statement();}
	|BREAK SEMICOLON {$$ = new statement();}
	|RETURN expression SEMICOLON {
		$$ = new statement();
		int zero = 0;	
		int one = 1;
		emit("RETURN",$2->loc->name);
	}
	|RETURN SEMICOLON {
		$$ = new statement();
		int zero = 0;	
		int one = 1;
		emit("RETURN","");
	}
	;

declaration_list
	:declaration {
	int zero = 0;	
	int one = 1;
	}
	|declaration_list declaration {
	}
	;

translationUnit
	:external_declaration {}
	|translationUnit external_declaration {}
	;

external_declaration
	:function_definition {}
	|declaration {}
	;

function_definition
	:declaration_specifiers declarator declaration_list CT compoundStatement {}
	|declaration_specifiers declarator CT compoundStatement {
		int zero = 0;	
		int one = 1;
		current_table->parent = global_table;
		changeTable (global_table);
	}
	;



%%

void yyerror(string s) {
    cout<<s<<endl;
}