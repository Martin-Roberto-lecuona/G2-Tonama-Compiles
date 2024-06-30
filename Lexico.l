%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"
#define MAX_FILAS 1024
#define MIN_INT -2147483648
#define MAX_INT 2147483647
#define MIN_FLOAT -2147483648.f
#define MAX_FLOAT 2147483647.f

FILE  *yyin;
int yylval;
char *yyltext;

int flag = 0;
int yyerror(void);

char lastID[31];

int validateInteger(int Value);
int validateFloat(float Value);

%}

%option noyywrap  
%option yylineno 

DIGITO		[0-9]
LETRA		[a-zA-Z]
COMILLA     ["]
COMILLA_I   [“]
COMILLA_D   [”]

BLANCO      [ \t\n\r]
COMA        [,]

CTE		    {DIGITO}+
FLOT        ({DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*)
ID			{LETRA}({LETRA}|{DIGITO})*
COMENT      "*-"((("-"[^*])?)|[^-])*"-*"



OP_ASIG   	        ":""="
OP_ASIG2   	        "="
OP_SUMA		        "+"
OP_MULT             "*"
OP_REST		        "-"
OP_DIVI             "/"
OP_MENOR            "<"
OP_MAYOR            ">"
OP_MENOR_IGUAL      ">="
OP_MAYOR_IGUAL      "<="
OP_IGUAL            "=="
OP_DISTINTO         "!="

PARENTE_I			"("
PARENTE_D			")"
LLAVE_I             "{"
LLAVE_D             "}"
CORCH_I             "["
CORCH_D             "]"
DOS_PUNT            ":"



%%
"Float"|"Int"|"String"|"float"|"int" {printf("\nTipo de dato : %s\n", yytext);return TIPO_DATO;}
AND                     {printf("\nComparacion AND : %s\n", yytext);return AND;}
OR                      {printf("\nComparacion OR : %s\n", yytext);return OR;}
NOT                     {printf("\nNegacion NOT : %s\n", yytext);return NOT;}
escribir                {printf("\nEscribir : %s\n", yytext);return ESCRIBIR;}
leer                    {printf("\nEscribir : %s\n", yytext);return LEER;}
init                    {printf("\nInit : %s\n", yytext);return INIT;}
"si"|"if"               {printf("\nSi: %s\n", yytext);return SI;}
"mientras"|"while"      {printf("\nMientras: %s\n", yytext);return MIENTRAS;}
"sino"|"else"           {printf("\nSino: %s\n", yytext);return SINO;}
"buscoYReemplazo"       {printf("\nBusco y reemplazo: %s\n", yytext);return BUSC_Y_REMP;}
"aplicarDescuento"      {printf("\nAplicar Descuento: %s\n", yytext);return APLIC_DESC;}

{COMA}                  {printf("\nComa: %s\n", yytext);return COMA;}
{CTE}   {
            if(strlen(yytext) > 10){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            if(validateInteger(atoi(yytext))){
                printf("\nConstante: %s\n", yytext);
                return CTE;
            }
            exit(-1);
        }
{FLOT}	{ 
           if(strlen(yytext) > 10){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            if(validateFloat(atof(yytext))){
                printf("\nFlotante: %s\n", yytext);
                return FLOT;
            }
            exit(-1);
        }

{ID}    { 
            if(strlen(yytext) > 30){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            strcpy(lastID,yytext);
            printf("\nIdentificador: %s\n", yytext);return ID;
        }
{COMILLA}[^"]*{COMILLA}|{COMILLA_I}.*{COMILLA_D} {
           if(strlen(yytext) > 100){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            printf("\nCadena: %s\n", yytext);
            return CADENA;
        }
{OP_SUMA}		        {printf("\nSuma: %s\n", yytext);return OP_SUMA;}
{OP_ASIG}|{OP_ASIG2}	{printf("\nAsignacion: %s\n", yytext);return OP_ASIG;}
{OP_MULT}		        {printf("\nMultiplicacion: %s\n", yytext);return OP_MULT;}
{OP_REST}		        {printf("\nResta: %s\n", yytext);return OP_REST;}
{OP_DIVI}		        {printf("\nDivision: %s\n", yytext);return OP_DIVI;}
{OP_MAYOR}		        {printf("\nMayor: %s\n", yytext);return OP_MAYOR;}
{OP_MENOR}		        {printf("\nMenor: %s\n", yytext);return OP_MENOR;}
{OP_MAYOR_IGUAL}		{printf("\nMayor igual: %s\n", yytext);return OP_MAYOR_IGUAL;}
{OP_MENOR_IGUAL}		{printf("\nMenor igual: %s\n", yytext);return OP_MENOR_IGUAL;}
{OP_IGUAL}		        {printf("\nIgual: %s\n", yytext);return OP_IGUAL;}
{OP_DISTINTO}		        {printf("\nDistinto: %s\n", yytext);return OP_DISTINTO;}
{PARENTE_I}			    {printf("\nParAbre: %s\n", yytext);return PARENTE_I;}
{PARENTE_D}			    {printf("\nParCierra: %s\n", yytext);return PARENTE_D;}
{LLAVE_I}			    {printf("\nLLaveAbre: %s\n", yytext);return LLAVE_I;}
{LLAVE_D}			    {printf("\nLLaveCierra: %s\n", yytext);return LLAVE_D;}
{CORCH_I}			    {printf("\nCorcheteAbre: %s\n", yytext);return CORCH_I;}
{CORCH_D}			    {printf("\nCorcheteCierra: %s\n", yytext);return CORCH_D;}
{DOS_PUNT}              {printf("\nDos puntos: %s\n", yytext);return DOS_PUNT;}
{COMENT}                {printf("\nComentario: %s\n", yytext);}
{BLANCO}
.			            {printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%
int validateInteger(int value) {
    if(value <= (int)MAX_INT && value >= (int)MIN_INT) 
        return 1;  
        
    fprintf(stderr, "LEXICAL ERROR (line %d): Integer constant out of range (Allowed range: from %d to %d) -> \%d\n", yylineno, (int)MIN_INT, (int)MAX_INT, value);
    return 0;
}

int validateFloat(float value) {
	if(value > (float)MAX_FLOAT || value < (float)MIN_FLOAT) {
		fprintf(stderr, "LEXICAL ERROR (line %d): Float constant out of range (Allowed range: from %f to %f) -> \%f\n", yylineno, (float)MIN_FLOAT, (float)MAX_FLOAT, atof(yytext));
		return 0;
	}
	return 1;
}