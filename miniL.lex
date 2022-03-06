   /* cs152-miniL phase2 */
   
%{   
	#include <string.h>
	#include "miniL-parser.hpp"
	int currline = 1;
	int currpos = 1;
%}

   /* some common rules */
DIGIT		[0-9]
ALPHA		[A-Za-z]
ALPHANUM	{ALPHA}|{DIGIT}
VALIDID		{ALPHA}({ALPHANUM}|_+{ALPHANUM})* 
INVALIDSTART	[0-9_][A-Za-z0-9_]*
INVALIDEND	[A-Za-z][A-Za-z0-9_]*_

%%
   /* specific lexer rules in regex */
"function"	{currpos += yyleng; return FUNCTION;}
"beginparams"	{currpos += yyleng; return BEGIN_PARAMS;}
"endparams"	{currpos += yyleng; return END_PARAMS;}
"beginlocals"	{currpos += yyleng; return BEGIN_LOCALS;}
"endlocals"	{currpos += yyleng; return END_LOCALS;}
"beginbody"	{currpos += yyleng; return BEGIN_BODY;}
"endbody"	{currpos += yyleng; return END_BODY;}
"integer"	{currpos += yyleng; return INTEGER;}
"array"		{currpos += yyleng; return ARRAY;}
"of"		{currpos += yyleng; return OF;}
"if"		{currpos += yyleng; return IF;}
"then"		{currpos += yyleng; return THEN;}
"endif"		{currpos += yyleng; return ENDIF;}
"else"		{currpos += yyleng; return ELSE;}
"while"		{currpos += yyleng; return WHILE;}
"do"		{currpos += yyleng; return DO;}
"for"		{currpos += yyleng; return FOR;}
"beginloop"	{currpos += yyleng; return BEGINLOOP;}
"endloop"	{currpos += yyleng; return ENDLOOP;}
"continue"	{currpos += yyleng; return CONTINUE;}
"break"		{currpos += yyleng; return BREAK;}
"read"		{currpos += yyleng; return READ;}
"write"		{currpos += yyleng; return WRITE;}
"not"		{currpos += yyleng; return NOT;}
"and"		{currpos += yyleng; return AND;}
"or"		{currpos += yyleng; return OR;}
"true"		{currpos += yyleng; return TRUE;}
"false"		{currpos += yyleng; return FALSE;}
"return"	{currpos += yyleng; return RETURN;}
"-"		{currpos += yyleng; return SUB;}
"+"		{currpos += yyleng; return ADD;}
"*"		{currpos += yyleng; return MULT;}
"/"		{currpos += yyleng; return DIV;}
"%"		{currpos += yyleng; return MOD;}
"=="		{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return EQ;}
"<>"		{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return NEQ;}
"<"		{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return LT;}
">"		{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return GT;}
"<="            {yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return LTE;}
">="		{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return GTE;}
";"		{currpos += yyleng; return SEMICOLON;}
":"		{currpos += yyleng; return COLON;}
","		{currpos += yyleng; return COMMA;}
";"		{currpos += yyleng; return SEMICOLON;}
":"		{currpos += yyleng; return COLON;}
","		{currpos += yyleng; return COMMA;}
"("		{currpos += yyleng; return L_PAREN;}
")"		{currpos += yyleng; return R_PAREN;}
"["		{currpos += yyleng; return L_SQUARE_BRACKET;}
"]"		{currpos += yyleng; return R_SQUARE_BRACKET;}
":="		{currpos += yyleng; return ASSIGN;}

{DIGIT}+        {currpos += yyleng; yylval.ival = atoi(yytext); return NUMBER;}
[ \t]+		{currpos += yyleng;}
"\n"		{currpos = 1; currline += 1;}		
(##).* 		{currline++; currpos = 1;}

{INVALIDSTART}	{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n" , currline, currpos, yytext); exit(0);} 
{INVALIDEND}	{printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n" , currline, currpos, yytext); exit(0);}
{VALIDID} 	{yyless(yyleng); currpos += yyleng; yylval.sval = strdup(yytext); return IDENT;}
. 		{printf("Error at line %d. column %d: unrecognized symbol \"%s\"\n", currline, currpos, yytext); exit(0);}
%%
	/* C functions used in lexer */
/*
int main(int argc, char ** argv)
{
   yylex();
}
*/
