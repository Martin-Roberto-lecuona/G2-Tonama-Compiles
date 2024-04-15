// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#define MAX_FILAS 1024
int yystopparser=0;
FILE  *yyin;
  int yyerror();
  int yylex();
char *yytext;


int pos = -1;

typedef struct{
    char nombre[100];
    char tipoDato[15];
    char valor[50];
    char longitud[5];
}t_fila;
t_fila filas[MAX_FILAS];
int filaActual=0;
void saveInFile();
int findSymbol(char* nombre);
void updateTipoDatoSymbol(int pos, char* tipoDato);
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud);
%}

%token CTE
%token FLOT
%token ID
%token OP_ASIG
%token OP_SUMA
%token OP_MULT
%token OP_REST
%token OP_DIVI
%token PARENTE_I
%token PARENTE_D
%token CADENA
%token SI
%token MIENTRAS
%token SINO
%token OP_MAYOR
%token OP_MENOR
%token OP_MAYOR_IGUAL
%token OP_MENOR_IGUAL
%token OP_IGUAL
%token LLAVE_I
%token LLAVE_D
%token ESCRIBIR
%token LEER
%token OR
%token AND
%token NOT
%token INIT
%token DOS_PUNT
%token TIPO_DATO
%token COMA


%%
proyecto : 
	bloque {printf(" FIN\n");}
	;
bloque:
	sentencia {printf(" sentencia es bloque\n");}
	| bloque sentencia {printf(" bloque sentencia es bloque\n");}
	;

sentencia:
	asignacion
	| iteracion 
	| seleccion
	| ESCRIBIR PARENTE_I CADENA PARENTE_D
	| ESCRIBIR PARENTE_I ID PARENTE_D
	| LEER PARENTE_I ID PARENTE_D
	| INIT LLAVE_I declaraciones LLAVE_D
	| INIT LLAVE_I LLAVE_D
	;

asignacion:
	ID {
		pos = findSymbol(yytext); 
		if (pos==-1) {
			saveSymbol(yytext,"","_","");
			pos = filaActual-1;
		}  
	}
	OP_ASIG asignable{printf("    ID = asignable es ASIGNACION\n");}
	;

asignable:
	expresion {printf("    ID = Expresion es ASIGNABLE\n");}
	| CADENA {
		printf("    ID = CADENA es ASIGNABLE\n"); 
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		char largo[10];
		sprintf(largo,"%d", strlen(yytext));
		saveSymbol(symbol,"",yytext,largo);
		updateTipoDatoSymbol(pos,"CADENA");
		}
	;

seleccion:
	SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D SINO LLAVE_I bloque LLAVE_D {printf("SI (condicion) bloque sino bloque = seleccion\n");}
	| SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("SI (condicion) bloque = seleccion\n");}
	;
iteracion:
	MIENTRAS PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("mientras (condicion) bloque = iteracion\n");}
	;
compuertas:
	AND
	|OR
	;
comparador:
	OP_MAYOR
	| OP_MENOR
	| OP_MAYOR_IGUAL
	| OP_MENOR_IGUAL
	| OP_IGUAL
	;

condicion:
	comparacion {printf("comparacion = condicion\n");}
	|condicion compuertas comparacion {printf("condicion compuerta comparacion = condicion\n");}
	;
comparacion:
	expresion comparador expresion {printf("expresion comparador expresion = comparacion\n");}
	|NOT comparacion {printf("NOT comparacion = comparacion\n");}
	| PARENTE_I comparacion PARENTE_D {printf("(comparacion) = comparacion\n");}
	| factor {printf("factor = comparacion\n");}
	;

expresion:
	termino {printf("Termino es Expresion\n");}
	|expresion OP_SUMA termino {printf("Expresion+Termino es Expresion\n");}
	|expresion OP_REST termino {printf("Expresion-Termino es Expresion\n");}
	;

termino:
	factor {printf("Factor es Termino\n");}
	|termino OP_MULT factor {printf("Termino*Factor es Termino\n");}
	|termino OP_DIVI factor {printf("Termino/Factor es Termino\n");}
	;

factor:
	ID {printf("    ID es Factor \n");}
	| CTE {
		printf("    CTE es Factor\n");
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		saveSymbol(symbol,"",yytext,"");
		updateTipoDatoSymbol(pos,"ENTERO");
		}
	| FLOT {printf("    FLOT es Factor\n");
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		saveSymbol(symbol,"", yytext,"");
		updateTipoDatoSymbol(pos,"FLOTANTE");
		}
	;
declaraciones:
	variables DOS_PUNT TIPO_DATO declaraciones
	| variables DOS_PUNT TIPO_DATO
	;

variables:
	ID COMA variables
	| ID
	;
%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        yyparse();
    }
	saveInFile();
	fclose(yyin);
    return 0;
}
int yyerror(void)
{
	printf("Error Sintactico\n");
	exit (1);
}

void saveInFile(){

    FILE* file = fopen("symbol-table2.txt", "w");
    if (file == NULL) {
        perror("Error al abrir el archivo");
        exit(1);
    }
	fprintf(file,"%-50s|%-30s|%-30s|%-30s\n","NOMBRE","TIPODATO","VALOR","LONGITUD");
	fprintf(file,"-------------------------------------------------------------------------------------------------------------------------\n");

	for(int i=0; i <sizeof(filas) / sizeof(filas[0]); i++){
		if(strlen(filas[i].nombre)==0)
			break;
    	fprintf(file,"%-49s|%-30s|%-30s|%-30s\n", filas[i].nombre, filas[i].tipoDato, filas[i].valor, filas[i].longitud);
	}
    fclose(file);
}
int findSymbol(char* nombre){
	int pos = 0, i=0, tam = sizeof(filas) / sizeof(filas[0]);
	while (strcmp(filas[i].nombre,nombre)!=0 && i<tam ){
		i++;
		pos = i;
	}
	return i>=tam ? -1 : pos;
}
void updateTipoDatoSymbol(int pos, char* tipoDato){
	if (pos==-1)
		return;
	strcpy(filas[pos].tipoDato,tipoDato);
}
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud) {
    
	strcpy(filas[filaActual].nombre,nombre);
    strcpy(filas[filaActual].tipoDato,tipoDato);
    strcpy(filas[filaActual].valor,valor);
    strcpy(filas[filaActual].longitud,longitud);
    filaActual++;
}