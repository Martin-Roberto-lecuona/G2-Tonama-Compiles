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
COMILLAI        [“]
COMILLAD        [”]
ASCI            [,.áéíóú0-9a-zA-Z_!"#$%&/()=@“” ]
BLANCO          [ \t\n\r]
COMA            [,]

CTE		        {DIGITO}+
FLOT            ({DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*)
ID			    {LETRA}({LETRA}|{DIGITO})*
CADENA          {COMILLA}{ASCI}*{COMILLA}
CADENAID        {COMILLAI}{ASCI}*{COMILLAD}
COMENT          "*-"{ASCI}*"-*"
OP_AS   		":""="
OP_SUM		        "+"
OP_MUL                  "*"
OP_RES		        "-"
OP_DIV                  "/"
OP_MENOR         "<"
OP_MAYOR         ">"
PA			"("
PC			")"
LA          "{"
LC          "}"
DP          ":"

%%

"Float"|"Int"|"String"        {printf("\nTipo de dato : %s\n", yytext);return TDD;}
AND             {printf("\nComparacion AND : %s\n", yytext);return AND;}
OR              {printf("\nComparacion OR : %s\n", yytext);return OR;}
NOT             {printf("\nNegacion NOT : %s\n", yytext);return NOT;}
escribir        {printf("\nEscribir : %s\n", yytext);return ESCRIBIR;}
leer            {printf("\nEscribir : %s\n", yytext);return LEER;}
init            {printf("\nInit : %s\n", yytext);return INIT;}
"si"|"if"       {printf("\nSi: %s\n", yytext);return SI;}
mientras        {printf("\nMientras: %s\n", yytext);return MIENTRAS;}
sino            {printf("\nSino: %s\n", yytext);return SINO;}

{COMA}          {printf("\nComa: %s\n", yytext);return COMA;}
{CTE}			{printf("\nConstante: %s\n", yytext);return CTE;}
{FLOT}			{printf("\nFlotante: %s\n", yytext);return FLOT;}
{ID}			{printf("\nIdentificador: %s\n", yytext);return ID;}
{CADENA}		{printf("\nCADENA: %s\n", yytext);return CADENA;}
{CADENAID}		{printf("\nCADENA: %s\n", yytext);return CADENA;}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{OP_MAYOR}		{printf("\nMayor: %s\n", yytext);return OP_MENOR;}
{OP_MENOR}		{printf("\nMenor: %s\n", yytext);return OP_MAYOR;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
{LA}			{printf("\nLLaveAbre: %s\n", yytext);return LA;}
{LC}			{printf("\nLLaveCierra: %s\n", yytext);return LC;}
{DP}            {printf("\nDos puntos: %s\n", yytext);return DP;}
{BLANCO}
{COMENT}        {printf("\nComentario: %s\n", yytext);}
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


