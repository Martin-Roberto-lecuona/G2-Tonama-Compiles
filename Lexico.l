%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;
int flag = 0;
int yyerror(void);
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud);
%}

%option noyywrap  
%option yylineno 

DIGITO		[0-9]
LETRA		[a-zA-Z]
COMILLA     ["]
COMILLA_I    [“]
COMILLA_D    [”]

BLANCO      [ \t\n\r]
COMA        [,]

CTE		    {DIGITO}+
FLOT        ({DIGITO}*"."{DIGITO}+|{DIGITO}+"."{DIGITO}*)
ID			{LETRA}({LETRA}|{DIGITO})*
COMENT     "*-"((("-"[^*])?)|[^-])*"-*"


OP_ASIG   	":""="
OP_SUMA		"+"
OP_MULT      "*"
OP_REST		"-"
OP_DIVI      "/"
OP_MENOR    "<"
OP_MAYOR    ">"
OP_MENOR_IGUAL ">="
OP_MAYOR_IGUAL "<="
OP_IGUAL      "=="
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
"mientras"|"while"      {printf("\nMientras: %s\n", yytext);return MIENTRAS;}
"sino"|"else"           {printf("\nSino: %s\n", yytext);return SINO;}

{COMA}                  {printf("\nComa: %s\n", yytext);return COMA;}
{CTE}   {
            if(strlen(yytext) > 100){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            char sizeString[50];
            sprintf(sizeString, "%d", strlen(yytext));
            saveSymbol(yytext,"","",sizeString);
            printf("\nConstante: %s\n", yytext);
            return CTE;
        }
{FLOT}			        { saveSymbol(yytext,"",yytext,"");
                      printf("\nFlotante: %s\n", yytext);return FLOT;}
{ID}			        { saveSymbol(yytext,"","_","");
                    printf("\nIdentificador: %s\n", yytext);return ID;}
{COMILLA}.*{COMILLA}|{COMILLA_I}.*{COMILLA_D} {
            if(strlen(yytext) > 100){
                printf( "ERROR LEXICO : supera el maximo de caracteres: %s\n", yytext ); 
                exit (0);
            }
            char sizeString[50];
            sprintf(sizeString, "%d", strlen(yytext));
            saveSymbol(yytext,"","_",sizeString);
            printf("\nCadena: %s\n", yytext);
            return CADENA;
        }
{OP_SUMA}		        {printf("\nSuma: %s\n", yytext);return OP_SUMA;}
{OP_ASIG}			        {printf("\nAsignacion: %s\n", yytext);return OP_ASIG;}
{OP_MULT}		        {printf("\nMultiplicacion: %s\n", yytext);return OP_MULT;}
{OP_REST}		        {printf("\nResta: %s\n", yytext);return OP_REST;}
{OP_DIVI}		        {printf("\nDivision: %s\n", yytext);return OP_DIVI;}
{OP_MAYOR}		        {printf("\nMayor: %s\n", yytext);return OP_MENOR;}
{OP_MENOR}		        {printf("\nMenor: %s\n", yytext);return OP_MAYOR;}
{OP_MAYOR_IGUAL}		        {printf("\nMayor igual: %s\n", yytext);return OP_MAYOR_IGUAL;}
{OP_MENOR_IGUAL}		        {printf("\nMenor igual: %s\n", yytext);return OP_MENOR_IGUAL;}
{OP_IGUAL}		        {printf("\nIgual: %s\n", yytext);return OP_IGUAL;}
{PARENTE_I}			        {printf("\nParAbre: %s\n", yytext);return PARENTE_I;}
{PARENTE_D}			        {printf("\nParCierra: %s\n", yytext);return PARENTE_D;}
{LLAVE_I}			        {printf("\nLLaveAbre: %s\n", yytext);return LLAVE_I;}
{LLAVE_D}			        {printf("\nLLaveCierra: %s\n", yytext);return LLAVE_D;}
{DOS_PUNT}                    {printf("\nDos puntos: %s\n", yytext);return DOS_PUNT;}
{BLANCO}
{COMENT}             {printf("\nComentario: %s\n", yytext);}
.			            { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%

void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud) {
   if(flag == 0){
      remove("symbol-table.txt");
   }
   FILE* file = fopen("symbol-table.txt", "a+");
      if (file == NULL) {
          perror("Error al abrir el archivo");
          exit(1);
      }
      if(flag == 0 ){
         fprintf(file,"%-50s|%-30s|%-30s|%-30s\n","NOMBRE","TIPODATO","VALOR","LONGITUD");
         fprintf(file,"-------------------------------------------------------------------------------------------------------------------------\n");
         flag = 1;
       }

      fprintf(file,"_%-49s|%-30s|%-30s|%-30s\n", nombre, tipoDato, valor, longitud);
      fclose(file);
}