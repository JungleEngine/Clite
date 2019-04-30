%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "clite.h"
#include "sym.hpp"

static int lbl;

struct symbol{
	char* var_name;
	int var_type;
	int constant;
	// TODO: Add value if needed.
	
	struct symbol* next;	
};

typedef struct symbol symbol;
symbol* symbol_table;


/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char* var_name);
nodeType *con(int value);
nodeType *conChar(char* value);
nodeType *flo(float value);
symbol* insertSymbol(char const* symbol_name, int symbol_type, int constant);
void print_symTable();
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int sym[26];	/* symbol table */



%}


%union {
int iValue; 	/* integer value */
float fValue;
int boolean;
char sIndex;	/* symbol table index */
char* var_name;
nodeType *nPtr;	/* node pointer */
};

%token <iValue> INTEGER 
%token <fValue> FLOAT
%token <var_name> VARIABLE STRING
%token WHILE IF PRINT T_CONST
%token <iValue> T_INT T_FLOAT T_STRING
%nonassoc IFX
%nonassoc ELSE
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%type <nPtr> stmt expr stmt_list 
%type <iValue> type
%type <boolean> const


%%

program:
	function { exit(0); }
	;
function:
		function stmt { mp_test(1); ex($2); freeNode($2); }
	| /* NULL */
	;

stmt:
	';'									{ $$ = opr(';', 2, NULL, NULL); }
	| expr  ';'							{ $$ = $1; }
	| const type VARIABLE ';'			{ $$ = opr('=', 2, id($3), con(0)); insertSymbol($3, $2, $1);}
	| PRINT expr ';'					{ $$ = opr(PRINT, 1, $2); }
	| const type VARIABLE '=' expr ';'	{ $$ = opr('=', 2, id($3), $5); insertSymbol($3, $2, $1);}
	| VARIABLE '=' expr ';'				{ $$ = opr('=', 2, id($1), $3); }
	| WHILE '(' expr ')'  stmt 			{ $$ = opr(WHILE, 2, $3, $5); }
	| IF '(' expr ')'  stmt %prec IFX	{ $$ = opr(IF, 2, $3, $5); }
	| IF '(' expr ')'  stmt ELSE stmt 	{ $$ = opr(IF, 3, $3, $5, $7); }
	| '{' stmt_list '}' 				{ $$ = $2; }
	  ;

const: 
	T_CONST			{ $$ = 1; }
	| /* NULL */	{ $$ = 0; }
	;

stmt_list:
	stmt 					{ $$ = $1; }
	| stmt_list stmt 		{ $$ = opr(';', 2, $1, $2); }
 	;

expr:
	INTEGER 				{ $$ = con($1); }
	| VARIABLE 				{ $$ = id($1); }
	| STRING    			{ $$ = conChar($1); }
	| FLOAT                 { $$ = flo($1); }
	| '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
	| expr '+' expr 		{ $$ = opr('+', 2, $1, $3); }
	| expr '-' expr 		{ $$ = opr('-', 2, $1, $3); }
	| expr '*' expr 		{ $$ = opr('*', 2, $1, $3); }
	| expr '/' expr 		{ $$ = opr('/', 2, $1, $3); }
	| expr '<' expr 		{ $$ = opr('<', 2, $1, $3); }
	| expr '>' expr 		{ $$ = opr('>', 2, $1, $3); }
	| expr GE expr 			{ $$ = opr(GE, 2, $1, $3); }
	| expr LE expr 			{ $$ = opr(LE, 2, $1, $3); }
	| expr NE expr 			{ $$ = opr(NE, 2, $1, $3); }
	| expr EQ expr 			{ $$ = opr(EQ, 2, $1, $3); }
	| '(' expr ')' 			{ $$ = $2; }
	;

type:
	T_INT             {$$ = 0;}
	| T_FLOAT         {$$ = 1;}
	| T_STRING        {$$ = 2;}
	;

%%


#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

symbol* insertSymbol(char const* symbol_name, int symbol_type, int constant){
	printf(" Symbol type:%d \n", symbol_type);
	symbol* ptr = (symbol*) malloc(sizeof(symbol));
	ptr->var_name = (char*) malloc(strlen(symbol_name) + 1);
	strcpy(ptr->var_name, symbol_name);
	ptr->var_type = symbol_type;
	ptr->constant = constant;
	ptr->next = (struct symbol* ) symbol_table;
	symbol_table = ptr;
	print_symTable();
	return ptr;
}

nodeType *con(int value) {
	nodeType *p;
	/* allocate node */
	// if ((p = malloc(sizeof(nodeType))) == NULL)
	p = new nodeType();
	if(p == NULL)
	yyerror("out of memory");
	/* copy information */
	p->type = typeCon;
	p->con.value = value;
	return p;
}

nodeType *conChar(char* value) {
	nodeType *p;
	/* allocate node */
	// if ((p = malloc(sizeof(nodeType))) == NULL)
	p = new nodeType();
	if(!p) yyerror("out of memory");

	/* copy information */
	p->type = typeChar;
	p->con_char.value = (char*) malloc(strlen(value) + 1);
	strcpy(p->con_char.value, value);
	return p;
}

nodeType *flo(float value) {
	nodeType *p;
	/* allocate node */
	p = new nodeType();
	if(!p) yyerror("out of memory");
	/* copy information */
	p->type = typeFloat;
	p->flo.value = value;
	return p;
}

nodeType *id(char* var_name) {

	nodeType *p;
	/* allocate node */
	// if ((p = malloc(sizeof(nodeType))) == NULL)
	p = new nodeType();
	if(p == NULL)
	yyerror("out of memory");
	/* copy information */
	p->type = typeId;
	// p->id.var_name = (char*) malloc(strlen(var_name) + 1);
	p->id.var_name = new char;
	strcpy(p->id.var_name, var_name);
	return p;
}

nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	int i;

	/* allocate node */
	p = new nodeType();
	if(p == NULL)
	yyerror("out of memory");
	p->opr.op = new nodeType*;
	if(p->opr.op == NULL)
	yyerror("out of memory");

	/* copy information */
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops); // iterate over operands to store them in the operand array
	for (i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);
	return p;
}

void freeNode(nodeType *p) {
	int i;

	if (!p) return;

	if (p->type == typeOpr) {
		for (i = 0; i < p->opr.nops; i++)
			freeNode(p->opr.op[i]);
		free(p->opr.op);
	}
	free (p);
}


int ex(nodeType *p) {
	int lbl1, lbl2;
	if (!p) return 0;
	switch (p->type) {
	case typeCon:
		printf("\tpush\t%d\n", p->con.value);
		break;
	case typeId:
		printf("\tpush\t%s\n", p->id.var_name);
		break;
	case typeOpr:
		switch (p->opr.oper) {
		case WHILE:
			printf("L%03d:\n", lbl1 = lbl++);
			ex(p->opr.op[0]);
			printf("\tjz\tL%03d\n", lbl2 = lbl++);
			ex(p->opr.op[1]);
			printf("\tjmp\tL%03d\n", lbl1);
			printf("L%03d:\n", lbl2);
			break;
		case IF:
			ex(p->opr.op[0]);
			if (p->opr.nops > 2) {
				/* if else */
				printf("\tjz\tL%03d\n", lbl1 = lbl++);
				ex(p->opr.op[1]);
				printf("\tjmp\tL%03d\n", lbl2 = lbl++);
				printf("L%03d:\n", lbl1);
				ex(p->opr.op[2]);
				printf("L%03d:\n", lbl2);
			} else {
				/* if */
				printf("\tjz\tL%03d\n", lbl1 = lbl++);
				ex(p->opr.op[1]);
				printf("L%03d:\n", lbl1);
			}
			break;
		case PRINT:
			ex(p->opr.op[0]);
			printf("\tprint\n");
			break;
		case '=':
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case UMINUS:
			ex(p->opr.op[0]);
			printf("\tneg\n");
			break;
		default:
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			switch (p->opr.oper) {
			case '+':
				printf("\tadd\n"); break;
			case '-':
				printf("\tsub\n"); break;
			case '*':
				printf("\tmul\n"); break;
			case '/':
				printf("\tdiv\n"); break;
			case '<':
				printf("\tcompLT\n"); break;
			case '>':
				printf("\tcompGT\n"); break;
			case GE:
				printf("\tcompGE\n"); break;
			case LE:
				printf("\tcompLE\n"); break;
			case NE:
				printf("\tcompNE\n"); break;
			case EQ:
				printf("\tcompEQ\n"); break;
			}
		}
	}
	return 0;
}

void print_symTable() {
	printf("----------------------SYMBOL TABLE----------------------\n");
	symbol* ptr;
	for(ptr = symbol_table; ptr != (symbol*) 0; ptr = (symbol*) ptr->next){

		dataTypeEnum dt = (dataTypeEnum)ptr->var_type;
		char* data_type;
		char* is_const;
		if(ptr->constant == 1) {
			is_const = "constant";
		}
		else {
			is_const = "";
		}
		switch(dt){
			case t_int:
			data_type = "int";
			break;
			case t_float:
			data_type = "float";
			break;
			case t_string:
			data_type = "string";
			break;
		}
		printf(" Symbol { name: %s || Type: %s %s \n", ptr->var_name,is_const, data_type);
	}
	printf("----------------------SYMBOL TABLE----------------------\n");
}

void yyerror(char *s) {
	fprintf(stdout, "%s\n", s);
}
int main(void) {
	yyparse();
	return 0;
}