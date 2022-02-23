    /* cs152-miniL phase2 */
%{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <vector>
#include <sstream>
#include <fstream>
#include <string.h>
#include <stack>
#include <queue>
extern int currpos;
extern int currline;
void yyerror(const char *msg);

// ofstream code;
std::stringstream output;
 
// yoinked from lab 3

//extern int yme = create_temp();
extern int yylex(void);

//char *identToken;
//int numberToken;
//int  count_names = 0;

struct CodeNode{
  std::string code;
  std::string name;
};
enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
  int size;
  std::stack<std::string> index;
  int value;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;

std::stack<std::string> exp_stack;
std::queue<std::string> param_queue;
int param_cnt = 0;

std::string create_temp(){
  static int count = 0;
  return "_temp" + std::to_string(count++);
}

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value, Type t) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value && s->type == t) {
	return true;
    }
  }
  return false;
}
std::string find_index(std::string &value){
  Function *f = get_function();
  std::string top = "-1";
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value && !s->index.empty()) {
        top = s->index.top();
	s->index.pop();
	break;
    }
  }
  return top;
}

void set_index(std::string &name, std::string &index){
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == name) {
        s->index.push(index);
    }
  }
}

int check_type(std::string &value){
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
        if(s->type == 0){
		return 0;
	}
	return 1;
    }
  }
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &name, Type t, int size, int value) {
  Symbol s;
  s.name = name;
  s.type = t;
  s.size = size;
  s.value = value;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("\"%s\"\n", symbol_table[i].declarations[j].name.c_str());
    }
    printf("endfunc\n");
  }
  printf("--------------------\n");
}

%}

%union{
  /* put your types here */
  int ival;
  char* sval;
}

%error-verbose
%locations

%left '+' '-' ADD SUB 
%left '*' '/' '%'  MUT DIV MOD

%start prog_start

%token FUNCTION 
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token FOR
%token BEGINLOOP
%token ENDLOOP
%token CONTINUE
%token BREAK
%token READ
%token WRITE
%token NOT
%token AND
%token OR
%token TRUE
%token FALSE
%token RETURN
%token SUB
%token ADD
%token MULT
%token DIV
%token MOD
%token EQ
%token NEQ
%token LT
%token GT
%token LTE
%token GTE
%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN
%token <ival> NUMBER 
%token <sval> IDENT
%type <sval> declaration
%type <sval> identifiers 
%type <sval> statement
%type <sval> var
%type <sval> expression
%type <sval> mutiplicative_exp
%type <sval> term
%type <sval> ident
/* %start program */

%% 

  /* write your rules here */
prog_start: functions prog_start {/*printf("prog_start -> functions prog_start\n");*/}
	| {/*printf("prog_start -> epsilon\n");*/}
;

functions: function functions {/*printf("functions -> function functions\n");*/}
        | {/*printf("functions -> epsilon\n");*/} 
;

function: FUNCTION IDENT
		{
		std::string func_name = $2;
  		add_function_to_symbol_table(func_name);
		output << "func " << func_name << std::endl;
		} 
	SEMICOLON BEGIN_PARAMS declarations 
	{
	param_cnt = 0;
	while(!param_queue.empty()){
		output << "= " << param_queue.front() << ", " << "$" << param_cnt++ << std::endl;
		param_queue.pop();
	}
	}
	END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
        	{/*printf("functions -> FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
		*/
		output << "endfunc" << std::endl << std::endl;
		}
;

identifiers: ident {/*printf("identifiers -> ident\n");*/
	param_queue.push($1);
	}
	|ident COMMA identifiers{/*printf("identifiers -> ident COMMA identifiers\n");*/
	param_queue.push($1);
	}
;

ident: IDENT {/*printf("ident -> IDENT %s\n", $1);*/}
;

declarations: declaration SEMICOLON  declarations {/*printf("declarations -> declaration SEMICOLON  declarations\n");*/}
	| {/*printf("declarations -> epsilon\n");*/
	/*print_symbol_table();*/
	}
;

declaration: identifiers  COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
	{/*printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER %d R_SQUARE_BRACKET OF INTEGER\n", $5);
	*/
	std::string value = $1;
	Type t = Array;
	int size = $5;
	Type T = Integer;
 	if(find(value, t) || find(value, T)){
		std::string error = "symbol \"" + value + "\"is multiply-defined"; 	
		yyerror(strdup(error.c_str()));
	}      
	add_variable_to_symbol_table(value, t,0, 0);
	output << ".[] " << $1 << ", " << $5<< std::endl;
	}
	|identifiers COLON INTEGER 
	{/*printf("declaration->identifiers COLON INTEGER\n");
	*/
	std::string value = $1;
  	Type t = Integer;
	Type T = Array;
        if(find(value, t) || find(value, T)){
                std::string error = "symbol \"" + value + "\"is multiply-defined";
                yyerror(strdup(error.c_str()));
        }
	add_variable_to_symbol_table(value, t, 1, 0);
	output << ". " << value << std:: endl;
	}
; 

statements: statement SEMICOLON statements {/*printf("statements -> statement SEMICOLON statements\n");*/}
	| {/*printf("statements -> epsilon\n");*/}
;

statement: var ASSIGN expression {
	/*printf("statement -> var ASSIGN epression\n");*/
	std::string temp = $1;
	if(check_type(temp) == 0){
		output << "= " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;
		/*free($3);*/
	}
	else if(check_type(temp) == 1){
		std::string index = find_index(temp);
		output  << "[]= " << const_cast<char*>($1) << ", " << index << ", " << const_cast<char*>($3) << std::endl;
		/*free($3);*/
	}
	 
	}
	| IF bool_expression THEN statements ENDIF {/*printf("statement -> IF bool_expression THEN statements ENDIF\n");*/}
	| IF bool_expression THEN statements ELSE statements ENDIF {/*printf("statement -> IF bool_expression THEN statements ELSE statements\n");*/}
	| WHILE bool_expression BEGINLOOP statements ENDLOOP {/*printf("statement -> WHILE bool_expression BEGINLOOP statements ENDLOOP\n");*/}
	| DO BEGINLOOP statements ENDLOOP WHILE bool_expression {/*printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expression\n");*/}
	| READ var var_loop {/*printf("statement -> READ var var_loop\n");*/}
	| WRITE var var_loop {/*printf("statement -> WRITE var var_loop\n");*/
	std::string temp = $2;
	if(check_type(temp) == 0){
		output << ".> " << const_cast<char*>($2) << std::endl;
	}
	else if(check_type(temp) == 1){
        	std::string temp2 = create_temp();
                std::string index = find_index(temp);
                output << ". " << temp2 << std::endl << "=[] " << temp2 << ", " <<  const_cast<char*>($2) << ", " << index << std::endl;
		output << ".> " << temp2 << std::endl;
	}
	}
	| CONTINUE {/*printf("statement -> CONTINUE\n");*/
	std:: string error = "continue statement not within a loop.";
        yyerror(strdup(error.c_str()));
	}
	| RETURN expression {/*printf("statement -> RETURN expression\n");*/
	/*$$.val = $2.val;
	$$.name = $2.name;*/
	output << "ret " << const_cast<char*>($2) << std::endl;
	}
;

expressions: expression {/*printf("expressions -> expression\n");*/
	exp_stack.push($1);
	}
	| expression COMMA expressions {/*printf("expressions -> expression COMMA expressions\n");*/
	exp_stack.push($1);
	}
	| {/*printf("expressions -> epsilon\n");*/}
;

expression: mutiplicative_exp ADD expression {/*printf("expression -> mutiplicative_exp ADD expression\n");*/
	std::string temp = create_temp();
	$$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "+ " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;	
	/*free($1);
	free($3);*/
	}
	| mutiplicative_exp SUB expression {/*printf("expression -> mutiplicative_exp SUB expression\n");*/
 	std::string temp = create_temp();
        $$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "- " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;
	/*free($1);
	free($3);*/
	}
	| mutiplicative_exp {/*printf("expression -> mutiplicative_exp\n");*/
	$$ = $1;
	/*free($1);*/
	/*$$.type = $1.type;*/	
	}
;

mutiplicative_exp: term MULT mutiplicative_exp {/*printf("mutiplicative_exp -> term MULT mutiplicative_exp\n");*/
	
	std::string temp = create_temp();
	$$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "* " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;
	/*free($3);*/
	}
	| term DIV mutiplicative_exp {/*printf("mutiplicative_exp -> term DIV mutiplicative_exp\n");*/
	std::string temp = create_temp();
        $$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "/ " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;
	/*free($3);*/
	}
	| term MOD mutiplicative_exp {/*printf("mutiplicative_exp -> term MOD mutiplicative_exp\n");*/
	std::string temp = create_temp();
        $$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "% " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl;
	/*free($3);*/
	}
	| term {/*printf("mutiplicative_exp -> term\n");*/
	$$ = $1;
	/*$$.type = $1.type;*/
	} 
;

bool_expression: NOT bool_expression {/*printf("bool_expression -> NOT bool_expression\n");*/}
	| expression comp expression {/*printf("bool_expression -> expression comp expression\n");*/}
;

comp: EQ {/*printf("comp -> EQ\n");*/}
	| NEQ {/*printf("comp -> NEQ\n");*/}
	| LT {/*printf("comp -> LT\n");*/}
	| GT {/*printf("comp -> GT\n");*/}
	| LTE {/*printf("comp -> LTE\n");*/}
	| GTE {/*printf("comp -> GTE\n");*/}
;

term: var {/*printf("term -> var\n");*/
	std::string temp = $1;
        if(check_type(temp) == 1){
		std::string temp2 = create_temp();
		std::string index = find_index(temp);
		output << ". " << temp2 << std::endl << "=[] " << temp2 << ", " <<  const_cast<char*>($1) << ", " << index << std::endl;
		$$ = strdup(temp2.c_str());
	}
	else{ $$ = $1;}
	}
	| NUMBER {/*printf("term -> NUMBER %d\n", $1);*/
	/*$$ = $1;*/
	std::string temp = create_temp();
        $$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "= " << temp  << ", " << $1 << std::endl;	 
	}
	| L_PAREN expression R_PAREN {/*printf("term -> L_PAREN expression R_PAREN\n");*/
	$$ = $2;
	}
	| ident L_PAREN expressions R_PAREN {/*printf("term -> ident L_PAREN expressions R_PAREN\n");*/
	/* need to consider params and stuff*/
	while(!exp_stack.empty()){
		output << "param " << exp_stack.top() << std::endl;
		exp_stack.pop();
	}
	std::string temp = create_temp();
	output << ". " << temp << std::endl << "call " << const_cast<char*>($1) << ", " << temp << std::endl;	 
	$$ = strdup(temp.c_str());
	}
;

var: ident {/*printf("var -> ident\n");*/
        std::string value = $1;
	if(!find(value, Integer) && !find(value, Array)){
                std::string error = "Error: Used variable \"" + value + "\" ident was not previously defined";
		yyerror(strdup(error.c_str()));
        }
	int type = check_type(value);
	if(type == 1 && find(value, Array)){
		std::string error2 = "Error: used array variable \"" + value + "\" is missing a specified index.";
		yyerror(strdup(error2.c_str()));
	}
	$$ = $1;
	}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {/*printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");*/
	std::string value = $1;
        if(!find(value, Integer) && !find(value, Array)){
                std:: string error = "Error: Used variable \"" + value + "\" ident[] was not previously defined";
                yyerror(strdup(error.c_str()));
        }
        int type = check_type(value);
        if(type == 0){
                yyerror("Symbol is of type int");
        }
	/*
	std::string temp = create_temp();
	$$ = strdup(temp.c_str());
	output << ". " << temp << std::endl << "=[] " << temp << ", " << const_cast<char*>($1) << ", " << const_cast<char*>($3) << std::endl; 
	*/
	std::string index = $3;
	set_index(value, index);
	$$ = $1;
	/*free($3);*/
	}
;

var_loop: COMMA var var_loop {/*printf("var_loop -> COMMA var var_loop\n");*/}
	| {/*printf("var_loop -> epsilon\n");*/}
;
%% 
int main(int argc, char **argv) {
   yyparse();
   std::cout << output.str() << std::endl;
   //print_symbol_table();
   /*
   std::ofstream file;
   file.open("function.mil");
   file << output.str();
   file.close();
   */
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
   printf("** %s at line %d, column %d\n", msg, currline, currpos);
   exit(1);
}
