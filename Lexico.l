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

DIGITO		[0-9]
LETRA		[a-zA-Z]
COMILLA     ["]
COMILLA_I    [“]
COMILLA_D    [”]
COMENT_I    "*-"
COMENT_D    "-*"

ASCII        [,.áéíóú0-9a-zA-Z_!"#$%&/(){}=@“”:+/><? \t]
ASCII_PM     [,.áéíóú0-9a-zA-Z_!"#$%&/(){}=@“”:+/><*\- \t]
BLANCO      [ \t\n\r]
CRLF        [\n\r]
COMA        [,]

CTE		    {DIGITO}+
FLOT        ({DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*)
ID			{LETRA}({LETRA}|{DIGITO})*
CADENA      {COMILLA}{ASCII_PM}*{COMILLA}
CADENAID    {COMILLA_I}{ASCII_PM}*{COMILLA_D}

COMENT      ({COMENT_I}({ASCII}|{BLANCO}|{COMILLA})*{COMENT_D})

OP_ASIG   	":""="
OP_SUMA		"+"
OP_MULT      "*"
OP_REST		"-"
OP_DIVI      "/"
OP_MENOR    "<"
OP_MAYOR    ">"
PARENTE_I			"("
PARENTE_D			")"
LLAVE_I          "{"
LLAVE_D          "}"
DOS_PUNT          ":"

%%

"Float"|"Int"|"String"  {printf("\nTipo de dato : %s\n", yytext);return TIPO_DATO;}
AND                     {printf("\nComparacion AND : %s\n", yytext);return AND;}
OR                      {printf("\nComparacion OR : %s\n", yytext);return OR;}
NOT                     {printf("\nNegacion NOT : %s\n", yytext);return NOT;}
escribir                {printf("\nEscribir : %s\n", yytext);return ESCRIBIR;}
leer                    {printf("\nEscribir : %s\n", yytext);return LEER;}
init                    {printf("\nInit : %s\n", yytext);return INIT;}
"si"|"if"               {printf("\nSi: %s\n", yytext);return SI;}
mientras                {printf("\nMientras: %s\n", yytext);return MIENTRAS;}
sino                    {printf("\nSino: %s\n", yytext);return SINO;}

{COMA}                  {printf("\nComa: %s\n", yytext);return COMA;}
{CTE}			        {printf("\nConstante: %s\n", yytext);return CTE;}
{FLOT}			        {printf("\nFlotante: %s\n", yytext);return FLOT;}
{ID}			        {printf("\nIdentificador: %s\n", yytext);return ID;}
{CADENA}		        {printf("\nCADENA: %s\n", yytext);return CADENA;}
{CADENAID}		        {printf("\nCADENA: %s\n", yytext);return CADENA;}
{OP_SUMA}		        {printf("\nSuma: %s\n", yytext);return OP_SUMA;}
{OP_ASIG}			        {printf("\nAsignacion: %s\n", yytext);return OP_ASIG;}
{OP_MULT}		        {printf("\nMultiplicacion: %s\n", yytext);return OP_MULT;}
{OP_REST}		        {printf("\nResta: %s\n", yytext);return OP_REST;}
{OP_DIVI}		        {printf("\nDivision: %s\n", yytext);return OP_DIVI;}
{OP_MAYOR}		        {printf("\nMayor: %s\n", yytext);return OP_MENOR;}
{OP_MENOR}		        {printf("\nMenor: %s\n", yytext);return OP_MAYOR;}
{PARENTE_I}			        {printf("\nParAbre: %s\n", yytext);return PARENTE_I;}
{PARENTE_D}			        {printf("\nParCierra: %s\n", yytext);return PARENTE_D;}
{LLAVE_I}			        {printf("\nLLaveAbre: %s\n", yytext);return LLAVE_I;}
{LLAVE_D}			        {printf("\nLLaveCierra: %s\n", yytext);return LLAVE_D;}
{DOS_PUNT}                    {printf("\nDos puntos: %s\n", yytext);return DOS_PUNT;}
{BLANCO}
{COMENT}                {printf("\nComentario: %s\n", yytext);}
.			            { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}


