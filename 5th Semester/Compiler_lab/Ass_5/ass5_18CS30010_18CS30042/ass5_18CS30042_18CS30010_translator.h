#ifndef TRANSLATE
#define TRANSLATE
#include <bits/stdc++.h>

using namespace std;

#define CHAR_BYTE_SIZE 		    1
#define INT_BYTE_SIZE  		    4
#define DOUBLE_BYTE_SIZE		8
#define POINTER_BYTE_SIZE		4

extern  char* yytext;
extern  int yyparse();

// Declaring the classes
class symbol_type;					// Symbol type class
class sym;						// Element of symbol table
class symtable;					// Symbol Table
class quad;						// Element of quad array
class quadArray;				// QuadArray

// Variables to be exported to the cxx file
extern symtable* current_table;						// Current Symbbol Table
extern symtable* global_table;				// Global Symbbol Table
extern quadArray qArr;							// Quadarray object
extern sym* currSymbol;					// A pointer pointing to the symbol read just now


// Class definitions

// Symbol type class
class symbol_type {
public:
	symbol_type(string name, symbol_type* ptr = NULL, int width = 1); // Initialiser for the class
	string type;				
	symbol_type* ptr;				
	int width;					
};

// Quad Class - Element of quadArray
class quad {
public:
	string oper_1;					// Operator of the expression
	string answer;						// Result of the expression
	string quad_1;					// Argument 1 of the expression
	string quad_2;					// Argument 2 of the expression

	// Print Quad Function
	void print ();

	// Constructors with default operation
	quad (string res, string argA, string operation = "EQUAL", string argB = "");			
	quad (string res, int argA, string operation = "EQUAL", string argB = "");				
	quad (string res, float argA, string operation = "EQUAL", string argB = "");			
};

// Array of Quads
class quadArray {
public:
	vector <quad> qArray;		             

	// Print all the Quads
	void print ();								
};


class sym {
public:
	string name;				// Name of the symbol
	symbol_type *type;				// Type of the Symbol - Pointer
	string initial_value;		// Symbol initial valus (if any)
	int size;					// Size of the symbol
	int offset;					// Offset of symbol
	symtable* nested;				// Pointer to nested symbol table

	sym (string name, string t="INTEGER", symbol_type* ptr = NULL, int width = 0); //constructor declaration
	sym* update(symbol_type * t); 	// A method to update different fields of an existing entry.
	sym* link_to_symbolTable(symtable* t);
};

// Symbol Table Class
class symtable {
public:
	string name;				
	int count;					
	list<sym> current_table; 			
	symtable* parent;				

	symtable (string name="NULL");							// Constructor
	sym* lookup (string name);								
	void print();					            			// Print the symbol table
	void update();						        			
};


struct statement {
	list<int> nextlist;				// Nextlist for statement
};

//Attributes for array
struct array_def {
	string cat;
	sym* loc;					
	sym* array_def;					// Pointer to symbol table
	symbol_type* type;				
};


//Attributes for expressions
struct expr {
	string type; 							

	sym* loc;								

	// Valid for bool type
	list<int> truelist;						// Truelist 
	list<int> falselist;					// Falselist

	// Valid for statement expression
	list<int> nextlist;
};


void emit(string op, string answer, string argA="", string argB = "");    
void emit(string op, string answer, int argA, string argB = "");		  
void emit(string op, string answer, float argA, string argB = "");        


sym* conv (sym*, string);							// TAC 
bool typecheck(sym* &s1, sym* &s2);					// Checks if two symbols have same type
bool typecheck(symbol_type* t1, symbol_type* t2);			//checks if two symbol_type objects have same type


void backpatch (list <int> lst, int i);
list<int> makelist (int i);							        // Make a new list of integer
list<int> merge (list<int> &lst1, list <int> &lst2);		// Merge two lists into a single list

expr* convert_Int_2_Bool (expr*);				// convert any expression (int) to bool
expr* convert_Bool_2_Int (expr*);				// convert bool to expression (int)

void changeTable (symtable* newtable);               //for changing the current sybol table
int nextinstr();									// Returns the next instruction number

sym* gentemp (symbol_type* t, string init = "");		// Generate a temporary variable and insert it in current symbol table

int size_type (symbol_type*);							// Calculate the size of any symbol type 
string print_type(symbol_type*);						// for recursive printing of type of symbol

#endif