%{
#include <stdlib.h>
#include "clite.h"
#include "y.tab.h"
#include <string>
void yyerror(std::string);
%}

digit [0-9]
integer [1-9][0-9]*

%%

"int"						{
							return T_INT;
							}

"float"						{
							return T_FLOAT;
							}
"string"					{
							return T_STRING;
							}

"const"						{
							return T_CONST;
							}

"for"						return FOR;
"do"						return DO;
"while"						return WHILE;
"if"						return IF;
"else"						return ELSE;
"print"						return PRINT;

{integer}"."[0-9]*          {
							yylval.fValue = atof(yytext);
							return FLOAT;
							}

"\""[a-zA-Z0-9]*"\""		{
							yylval.var_name = (char*) malloc(yyleng + 1);
							strcpy(yylval.var_name, yytext);
							return STRING;
							}

[a-zA-Z][a-zA-Z0-9]*		{
							yylval.var_name = (char*) malloc(yyleng + 1);
							strcpy(yylval.var_name, yytext);
							return VARIABLE;
							}

0							{
							yylval.iValue = atoi(yytext);
							return INTEGER;
							}

{integer} 					{
							yylval.iValue = atoi(yytext);
							return INTEGER;
							}

[-()<>=+*/;{}.]				{
							return *yytext;
							}

">="						return	GE;
"<="						return	LE;
"=="						return	EQ;
"!="						return	NE;

[ \t\n]+					;	/* ignore whitespace */

.							yyerror("Unknown character");

%%

int yywrap(void) {
	return 1;
}