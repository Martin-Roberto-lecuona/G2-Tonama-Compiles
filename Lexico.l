%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]
COMILLA         ["]
ASCI            [0-9a-zA-Z_!"#$%&/()=@ ]
BLANCO          [ \t\n\r]

CTE		        {DIGITO}+
FLOT            ({DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*)
ID			{LETRA}({LETRA}|{DIGITO})*
CADENA          {COMILLA}{ASCI}*{COMILLA}
OP_AS   		":""="
OP_SUM		        "+"
OP_MUL                  "*"
OP_RES		        "-"
OP_DIV                  "/"
PA			"("
PC			")"

%%

{CTE}			{printf("\nConstante: %s\n", yytext);return CTE;}
{FLOT}			{printf("\nFlotante: %s\n", yytext);return FLOT;}
{ID}			{printf("\nIdentificador: %s\n", yytext);return ID;}
{CADENA}			{printf("\nCADENA: %s\n", yytext);return CADENA;}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
{BLANCO}
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


