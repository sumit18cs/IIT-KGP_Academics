#include "ass5_18CS30042_18CS30010_translator.h"

using namespace std;
 
symtable* global_table;					// Global Symbbol Table
quadArray q;							// Quad Array
string Type;							// Stores latest type
symtable* current_table;						// Points to current symbol current_table
sym* currSymbol; 					// points to current symbol

void printing(char a, int cnt)
{
	int i;
	for(i=0;i<cnt;i++){
		cout<<a;
	}
	cout<<endl;
}

symbol_type::symbol_type(string name, symbol_type* ptr, int width): 
	type (name), 
	ptr (ptr), 
	width (width) {};

quad::quad (string res, string argA, string operation, string argB):
	answer (res), quad_1(argA), quad_2(argB), oper_1(operation){};

quad::quad (string res, int argA, string operation, string argB):
	answer (res), quad_2(argB), oper_1(operation) {
		quad_1 = to_string(argA);
	}

quad::quad (string res, float argA, string operation, string argB):
	answer (res), quad_2(argB), oper_1(operation) {
		quad_1 = to_string(argA);
	}

void quad::print () {

	if(oper_1 == "GOTOOP")   cout <<	 "goto " << answer; 
	else if (oper_1=="EQUAL")			cout << answer << " = " << quad_1 ;
	else if (oper_1=="ARRR")	 	cout << answer << " = " << quad_1 << "[" << quad_2 << "]";
	else if (oper_1=="PTRL")		cout << "*" << answer	<< " = " << quad_1 ;			
	else if (oper_1=="RETURN") 	cout << "ret " << answer;
	else if (oper_1=="PARAM") 	cout << "param " << answer;
	else if (oper_1=="LABEL")		cout << answer << ": ";
	else if (oper_1=="ARRL")	 	cout << answer << "[" << quad_1 << "]" <<" = " <<  quad_2;
	else if (oper_1=="CALL") 		cout << answer << " = " << "call " << quad_1<< ", " << quad_2;
	else
	{
		map< string, string > op_sym_match = {
			{"MODOP"," % "},
			{"XOR"," ^ "},
			{"INOR"," | "},
			{"BAND"," & "},
			{"LEFTOP"," << "},
			{"RIGHTOP"," >> "},
			{"ADD"," + "},
			{"SUB"," - "},
			{"MULT"," * "},
			{"DIVIDE"," / "},
			{"GE"," >= "},
			{"ADDRESS"," = & "},
			{"PTRR"," = * "},
			{"UMINUS"," = - "},
			{"BNOT"," = ~ "},
			{"EQOP"," == "},
			{"NEOP"," != "},
			{"LT"," < "},
			{"GT"," > "},
			{"LE"," <= "},
			{"LNOT"," = ! "}
		};
		vector<string> binary {"ADD","SUB","MULT","DIVIDE","MODOP","XOR","INOR","BAND","LEFTOP","RIGHTOP"};
		vector<string> unary {"ADDRESS","PTRR","UMINUS","BNOT","LNOT"};
		vector<string> relational {"EQOP","NEOP","LT","GT","LE","GE"};
		

		// Binary Operation
		for(string op : binary )
		{
			if(oper_1 == op)
			{
				cout << answer << " = " << quad_1 << op_sym_match[oper_1] << quad_2;
				goto end;
			}
		}

		//Unary Operators
		for(string op : unary )
		{
			if(oper_1 == op)
			{
				cout<< answer << op_sym_match[oper_1] << quad_1;
				goto end;
			}
		}

		// Relational Operations
		for(string op : relational )
		{
			if(oper_1 == op)
			{
				cout << "if " << quad_1 <<  op_sym_match[oper_1] << quad_2 << " goto " << answer;
				goto end;
			}
		}

		cout << oper_1;			
		
	}
	end: cout << endl;
}

void quadArray::print() {
	printing('#',30);
	cout << "Quad Translation" << endl;
	printing('=',30);

	int cnt = 0;
	for (quad temp : qArray) {
		if (temp.oper_1 != "LABEL") {
			cout << "\t" << setw(4) << cnt << ":\t";
			temp.print();
		}
		else {
			cout << "\n";
			temp.print();
			cout << "\n";
		}
		cnt++;
	}
	printing('=',30);
}

sym::sym (string name, string t, symbol_type* ptr, int width): name(name)  {
	type = new symbol_type (t, ptr, width);
	nested = NULL;
	initial_value = "";
	offset = 0;
	size = size_type(type);
}

sym* sym::update(symbol_type* t) {
	type = t;
	this -> size = size_type(t);
	return this;
}

symtable::symtable (string name): name (name), count(0) {};

void printRow(sym temp)
{
	cout << left << setw(20) << temp.name;
	string stype = print_type(temp.type);
	cout << left << setw(25) << stype;
	cout << left << setw(17) << temp.initial_value;
	cout << left << setw(12) << temp.size;
	cout << left << setw(11) << temp.offset;
	cout << left;
}

void symtable::print() {
	list<symtable*> tablelist;
	printing('#',115);
	cout << "Symbol Table: " << setfill (' ') << left << setw(50)  << this -> name ;
	cout << right << setw(25) << "Parent: ";
	
	if (this->parent==NULL){
		cout << "null" ;
		
	}
	else{ 
		cout << this -> parent->name;
	}
	cout << endl;
	printing('=',100);
	
	cout << setfill (' ') << left << setw(20) << "Name";
	cout << left << setw(25) << "Type";
	cout << left << setw(20) << "Initial Value";
	cout << left << setw(12) << "Size";
	cout << left << setw(12) << "Offset";
	cout << left << "Nested" << endl;
	printing('-',100);
	
	for (auto it = current_table.begin(); it!=current_table.end(); it++) {

		printRow(*it);
		if (it->nested == NULL) {
			cout << "null" <<  endl;	
		}
		else {
			cout << it->nested->name <<  endl;
			tablelist.push_back (it->nested);
		}
	}
	printing('-',115);
	cout << endl;

	for (auto it = tablelist.begin(); it != tablelist.end(); ++it) 
	    	(*it)->print();
}

void symtable::update() {
	list<symtable*> tablelist;
	int off;
	for (list <sym>::iterator it = current_table.begin(); it!=current_table.end(); it++) {
		if (it!=current_table.begin()) {
			it->offset = off;
			off = it->offset + it->size;
			
		}
		else {
			it->offset = 0;
			off = it->size;
		}
		if (it->nested!=NULL) tablelist.push_back (it->nested);
	}
	for (auto it = tablelist.begin(); it != tablelist.end(); ++it)
	    (*it)->update();
}

sym* symtable::lookup (string name) {
	sym* s;
	auto it = current_table.begin();
	for (; it!=current_table.end(); it++)
		if (it->name == name ) break;

	if (it!=current_table.end() )
		return &(*it);
	
	else {
		// Add new symbol
		s =  new sym (name), current_table.push_back (*s);
		return &current_table.back();
	}
}


void emit(string op, string answer, string argA, string argB) {
	q.qArray.push_back(*(new quad(answer,argA,op,argB)));
}
void emit(string op, string answer, int argA, string argB) {
	q.qArray.push_back(*(new quad(answer,argA,op,argB)));
}
void emit(string op, string answer, float argA, string argB) {
	q.qArray.push_back(*(new quad(answer,argA,op,argB)));
}


sym* conv (sym* s, string t) {
	sym* temp = gentemp(new symbol_type(t));
	if(false){
		cout<<"Not possible";
	}

	else if (s->type->type=="DOUBLE" ) {
		if (t=="INTEGER") {
			emit ("EQUAL", temp->name, "double2int(" + s->name + ")");
			return temp;
		}
		else if (t=="CHAR") {
			emit ("EQUAL", temp->name, "double2char(" + s->name + ")");
			return temp;
		}
		return s;
	}
	else if (s->type->type=="INTEGER" ) {
		if (t=="DOUBLE") {
			emit ("EQUAL", temp->name, "int2double(" + s->name + ")");
			return temp;
		}
		else if (t=="CHAR") {
			emit ("EQUAL", temp->name, "int2char(" + s->name + ")");
			return temp;
		}
		return s;
	}
	else if (s->type->type=="CHAR") {
		if (t=="INTEGER") {
				emit ("EQUAL", temp->name, "char2int(" + s->name + ")");
				return temp;
			}
		if (t=="DOUBLE") {
				emit ("EQUAL", temp->name, "char2double(" + s->name + ")");
				return temp;
			}
		return s;
	}
	return s;
}


bool typecheck(sym*& s1, sym*& s2){ 	// Check if the symbols have same type or not
	symbol_type* type1 = s1->type;
	symbol_type* type2 = s2->type;
	if ( typecheck (type1, type2) ) return true;
	else if (s1 = conv (s1, type2->type) ) return true;
	else if (s2 = conv (s2, type1->type) ) return true;
	return false;
}

bool typecheck(symbol_type* t1, symbol_type* t2){ 	// Check if the symbol types are same or not
	
	if(t1 == NULL && t2 == NULL)
		return true;
	
		if (t1==NULL) return false;
		if (t2==NULL) return false;
		if (t1->type != t2->type) return false;
		return typecheck(t1->ptr, t2->ptr);
}

void backpatch (list <int> l, int addr) {
	string str = to_string(addr);
	for (auto it= l.begin(); it!=l.end(); it++) {
		q.qArray[*it].answer = str;
	}
}


list<int> makelist (int i) {
	list<int> l(1,i);
	return l;
}
list<int> merge (list<int> &a, list <int> &b) {
	a.merge(b);
	return a;
}

expr* convert_Int_2_Bool (expr* e) {	// Convert any expression to bool
	if (e->type!="BOOL") {
		e->falselist = makelist (nextinstr());
		emit ("EQOP", "", e->loc->name, "0");
		e->truelist = makelist (nextinstr());
		emit ("GOTOOP", "");
	}
}

expr* convert_Bool_2_Int (expr* e) {	// Convert any expression to bool
	if (e->type=="BOOL") {
		e->loc = gentemp(new symbol_type("INTEGER"));
		backpatch (e->truelist, nextinstr());
		emit ("EQUAL", e->loc->name, "true");
		string str = to_string(nextinstr()+1);
		emit ("GOTOOP", str);
		backpatch (e->falselist, nextinstr());
		emit ("EQUAL", e->loc->name, "false");
	}
}

void changeTable (symtable* newtable) {	// Change current symbol current_table
	current_table = newtable;
} 


int nextinstr() {
	return q.qArray.size();
}

sym* gentemp (symbol_type* t, string init) {
	char n[10];
	sprintf(n, "t%02d", current_table->count++);
	sym* s = new sym (n);
	s->type = t;
	s->size=size_type(t);
	s-> initial_value = init;
	current_table->current_table.push_back ( *s);
	return &current_table->current_table.back();
}

int size_type (symbol_type* t){
	if(t->type=="VOID")	return 0;
	else if(t->type=="CHAR") return CHAR_BYTE_SIZE;
	else if(t->type=="PTR") return POINTER_BYTE_SIZE;
	else if(t->type=="ARR") return t->width * size_type (t->ptr);
	else if(t->type=="INTEGER")return INT_BYTE_SIZE;
	else if(t->type=="DOUBLE") return  DOUBLE_BYTE_SIZE;
	else if(t->type=="FUNC") return 0;
}


string print_type (symbol_type* t){
	if (t==NULL) return "null";
	if(t->type=="VOID")	return "void";
	else if(t->type=="DOUBLE") return "double";
	else if(t->type=="PTR") return "ptr("+ print_type(t->ptr)+")";
	else if(t->type=="CHAR") return "char";
	else if(t->type=="INTEGER") return "integer";
	else if(t->type=="ARR") {
		string str = to_string(t->width);
		return "arr(" + str + ", "+ print_type (t->ptr) + ")";
	}
	else if(t->type=="FUNC") return "function";
	else return "_";
}

int  main (int argc, char* argv[])
{
	global_table = new symtable("Global");
	current_table = global_table;

	yyparse();

	global_table->update();
	global_table->print();
	q.print();
};