%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "error_handler.cpp"
#include "semantic_analyzer.hpp"

static int lbl;



SemanticAnalyzer* sem_analyzer = new SemanticAnalyzer;

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char* var_name);
nodeType *conInt(int value);
nodeType *conChar(char* value);
nodeType *conFloat(float value);
nodeType *conBool(bool value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void addScope();
void removeScope();
int sym[26];	/* symbol table */



%}

// %code requires{
// 	#include "semantic_analyzer.hpp"
// }

%union {
int iValue; 	/* integer value */
float fValue;
bool boolean;
char sIndex;	/* symbol table index */
char* var_name;
nodeType *nPtr;	/* node pointer */
dataTypeEnum data_type;
};

%token <boolean> TRUEFALSE
%token <iValue> INTEGER 
%token <fValue> FLOAT
%token <var_name> VARIABLE STRING
%token DO WHILE FOR IF PRINT T_CONST SWITCH CASE DEFAULT
%token OPLSEQ OMINEQ ODIVEQ OMULEQ	//+= -= /= *=
%token <iValue> T_INT T_FLOAT T_STRING T_BOOL
%nonassoc IFX
%nonassoc ELSE
%left OGE OLE OEQ ONE '>' '<' OOR OAND
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS OPLSPLS OMINMIN ONOT
%type <nPtr> stmt expr stmt_list exp1 exp2 switch_statement num_exp switch_block con_expr
%type <data_type> type
%type <boolean> const 


%%

program:
	function { exit(0); }
	;
function:
		function stmt 					{ ex($2); freeNode($2); }
	| /* NULL */
	;

stmt:
	';'									{ $$ = opr(';', 2, NULL, NULL); }	
	| exp1 ';'							{ $$ = $1; }

	| DO '{' stmt '}' WHILE '(' expr ')' ';'
										{ $$ = opr(DO, 2, $7, $3);}

	| WHILE '(' expr ')'  stmt 			{ $$ = opr(WHILE, 2, $3, $5); }

	| FOR '(' exp1 ';' exp1 ';' exp2 ')' stmt
										{ $$ = opr(FOR, 4, $3, $5, $7, $9 ); }

	| IF '(' expr ')'  stmt %prec IFX	{ $$ = opr(IF, 2, $3, $5); }
	| IF '(' expr ')'  stmt ELSE stmt 	{ $$ = opr(IF, 3, $3, $5, $7); }
	| switch_statement					{ $$ = $1; }
	| PRINT expr ';'					{ $$ = opr(PRINT, 1, $2); }
	| '{' stmt_list '}' 				{ $$ = $2; }
	| 	error ';'						{ sem_analyzer->syntaxError = true;$$ = NULL; yyerrok; }
	;


switch_statement:
	SWITCH '(' num_exp ')' '{' switch_block '}' 
						{ $$ = opr(SWITCH, 2 , $3, $6); }
	;

switch_block:
	  CASE con_expr ':' stmt switch_block{ $$ = opr(CASE, 3, $2, $4, $5); }
	| DEFAULT	':' stmt				{ $$ = opr(DEFAULT,1, $3); }
	| /* NULL */						{ $$ = opr(';',2, NULL, NULL); }
	;

num_exp:								  /* if not numerical expression throw an error */
	  exp2								{ /*TODO: check if numerical expression*/$$ = $1;}
	;

exp1:
		const type VARIABLE				{ sem_analyzer->insertSymbol($3, $2, $1); $$ = opr(EQDEC, 2, id($3), conInt(0));  }
	|	const type VARIABLE '=' expr 	{ sem_analyzer->insertSymbol($3, $2, $1); $$ = opr(EQDEC, 2, id($3), $5); 
										}
	|	exp2 							{ $$ = $1; }
	;

exp2:
		VARIABLE '=' expr 				{
											// sem_analyzer->assignmentValidity($1, $3);
											$$ = opr(EQ, 2, id($1), $3);
										}
	|	VARIABLE OPLSEQ expr 			{ $$ = opr(PLSEQ, 2, id($1), $3);}
	|	VARIABLE OMINEQ expr 			{ $$ = opr(MINEQ, 2, id($1), $3);}
	|	VARIABLE OMULEQ expr 			{ $$ = opr(MULEQ, 2, id($1), $3);}
	|	VARIABLE ODIVEQ expr 			{ $$ = opr(DIVEQ, 2, id($1), $3);}
	|	expr 							{ $$ = $1; }
	;

const: 
	T_CONST			{ $$ = true; }
	| /* NULL */	{ $$ = false; }
	;

stmt_list:
	stmt 					{ $$ = $1; }
	| stmt_list stmt 		{ $$ = opr(';', 2, $1, $2); }
	;

expr:
	  con_expr 							{ $$ = $1; }
	| VARIABLE 							{ $$ = id($1); }
	| VARIABLE OPLSPLS 					{ $$ = opr(PLSPLS, 1, $1);}
	| VARIABLE OMINMIN 					{ $$ = opr(MINMIN, 1, $1);}
	| '-' expr %prec UMINUS 			{ $$ = opr(UMINUS, 1, $2); }
	| '!' expr %prec ONOT 				{ $$ = opr(NOT, 1, $2); }
	| expr '+' expr 					{ $$ = opr(PLS, 2, $1, $3); }
	| expr '-' expr 					{ $$ = opr(MIN, 2, $1, $3); }
	| expr '*' expr 					{ $$ = opr(MUL, 2, $1, $3); }
	| expr '/' expr 					{ $$ = opr(DIV, 2, $1, $3); }
	| expr '<' expr 					{ $$ = opr(LT, 2, $1, $3); }
	| expr '>' expr 					{ $$ = opr(GT, 2, $1, $3); }
	| expr OGE expr 					{ $$ = opr(GTEQ, 2, $1, $3); }
	| expr OLE expr 					{ $$ = opr(LTEQ, 2, $1, $3); }
	| expr ONE expr 					{ $$ = opr(NTEQ, 2, $1, $3); }
	| expr OEQ expr 					{ $$ = opr(EQEQ, 2, $1, $3); }
	| expr OOR expr 					{ $$ = opr(OR, 2, $1, $3); }
	| expr OAND expr 					{ $$ = opr(AND, 2, $1, $3); }
	| '(' expr ')' 						{ $$ = $2; }
	;

con_expr:
	  INTEGER 							{ $$ = conInt($1); }
	| STRING    						{ $$ = conChar($1); }
	| FLOAT 							{ $$ = conFloat($1); }
	| TRUEFALSE							{ $$ = conBool($1); }
	;

type:
	  T_INT				{$$ = t_int;}
	| T_FLOAT			{$$ = t_float;}
	| T_STRING			{$$ = t_string;}
	| T_BOOL 			{$$ = t_bool;}
	;

%%


#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *conInt(int value) {
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

nodeType *conFloat(float value) {
	nodeType *p;
	/* allocate node */
	p = new nodeType();
	if(!p) yyerror("out of memory");
	/* copy information */
	p->type = typeFloat;
	p->flo.value = value;
	return p;
}
nodeType *conBool(bool value) {
	nodeType *p;
	/* allocate node */
	p = new nodeType();
	if(!p) yyerror("out of memory");
	/* copy information */
	p->type = typeBool;
	p->boolean.value = value;
	return p;
}
nodeType *id(char* var_name ) {
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
	p->opr.op = new nodeType*[nops];
	if(p->opr.op == NULL)
	yyerror("out of memory");

	/* copy information */
	p->type = typeOpr;
	p->opr.type = oper;
	p->opr.nops = nops;
	va_start(ap, nops); // iterate over operands to store them in the operand array
	for (i = 0; i < nops; i++)
		p->opr.op[i] = va_arg(ap, nodeType*);
	va_end(ap);

	if(oper <= MULEQ){
		sem_analyzer->operationValidity(p->opr);
	}


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
		switch (p->opr.type) {
		case WHILE:
			printf("L%03d:\n", lbl1 = lbl++);
			ex(p->opr.op[0]);
			printf("\tjz\tL%03d\n", lbl2 = lbl++);
			ex(p->opr.op[1]);
			printf("\tjmp\tL%03d\n", lbl1);
			printf("L%03d:\n", lbl2);
			break;
		case DO:
			cout<<"DO while detected:"<<endl;
			// cout<<p->opr.op[0]<<endl;
			// cout<<p->opr.op[1]<<endl;
			break;
		case FOR:
			cout<<"FOR loop detected:"<<endl;
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
		case EQ:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case EQDEC:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case PLSEQ:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case MINEQ:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case DIVEQ:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case MULEQ:
			ex(p->opr.op[1]);
			printf("\tpop\t%s\n", p->opr.op[0]->id.var_name);
			break;
		case UMINUS:
			ex(p->opr.op[0]);
			printf("\tneg\n");
			break;
		case PLSPLS:
			printf("\tplus plus\n"); break;
		case MINMIN:
			printf("\tminus minus\n"); break;
		case NOT:
			printf("\tnot\n"); break;
		case OR:
			printf("\tor\n"); break;
		case AND:
			printf("\tand\n"); break;
		default:
			ex(p->opr.op[0]);
			ex(p->opr.op[1]);
			switch (p->opr.type) {
			case PLS:
				printf("\tadd\n"); break;
			case MIN:
				printf("\tsub\n"); break;
			case MUL:
				printf("\tmul\n"); break;
			case DIV:
				printf("\tdiv\n"); break;
			case LT:
				printf("\tcompLT\n"); break;
			case GT:
				printf("\tcompGT\n"); break;
			case GTEQ:
				printf("\tcompGE\n"); break;
			case LTEQ:
				printf("\tcompLE\n"); break;
			case NTEQ:
				printf("\tcompNE\n"); break;
			case EQEQ:
				printf("\tcompEQ\n"); break;
			default:
				printf("unrecognized operation please check the enum and stuff");	
			}
		}
	}
	return 0;
}

void yyerror(string s) {
    extern int yylineno;
	fprintf(stdout, "%s at line:%d\n", s.c_str(), yylineno);
}


void addScope(){
	printf("Adding new scope\n");
	sem_analyzer->addScope();
}

void removeScope(){
	printf("Removing scope\n");
	sem_analyzer->removeScope();
}

int main(void) {
	yyparse();
	return 0;
}
