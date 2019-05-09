%{
#include <stdlib.h>
#include "clite.h"
#include "y.tab.h"
#include <string>
#include "error_codes.h"

void yyerror(std::string);
void addScope();
void removeScope();
std::string getErrorMessage(int error_code);
// SemanticAnalyzer* sem_analyzer;
%}
%option yylineno
digit [0-9]
integer [1-9][0-9]*
endMC	"*/"

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

"bool"						{
							return T_BOOL;
							}
"true"|"false"				{ 
							string val(yytext);
							yylval.boolean = val == "true";
							cout<<yylval.boolean<<endl;
							return TRUEFALSE;
							}			


"for"						{return FOR; addScope();}
"do"						return DO;
"while"						return WHILE;
"switch"					return SWITCH;
"case"						return CASE;
":"							return *yytext;
"default"					return DEFAULT;
"if"						return IF;
"else"						return ELSE;
"print"						return PRINT;

{integer}"."{digit}*        {
							yylval.fValue = atof(yytext);
							return FLOAT;
							}


\"[^\"\n]*\" 		            {
							    yylval.var_name = (char*) malloc(yyleng + 1);
							    strcpy(yylval.var_name, yytext);
							    return STRING;
							    }


\"[^\"\n]*$                    {
                                yyerror(getErrorMessage(UNTERMINATED_STRING));
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


"{"							{ addScope();	return *yytext;}
"}"							{ removeScope(); cout<<"scope has ended"<<endl;	return *yytext;}

[-!()<>=+*/;.]				{
							return *yytext;
							}

">="						return OGE;
"<="						return OLE;
"=="						return OEQ;
"!="						return ONE;

"||"						return OOR;
"&&"						return OAND;

"+="						return OPLSEQ;
"-="						return OMINEQ;
"/="						return ODIVEQ;
"*="						return OMULEQ;

[ \t\n]+					;	/* ignore whitespace */

"//".*						{};
"/*"[^*/]*"*/"				{};

.							{
                            yyerror("Unknown character");
                            printf("value :%s:", yytext);
                            }

%%

int yywrap(void) {
	return 1;
}