// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#define MAX_FILAS 1024
#define FLOAT "FLOTANTE"
#define INT "ENTERO"
#define STR "CADENA"


int yystopparser=0;
FILE  *yyin;
int yyerror();
int yylex();
char *yytext;

int pos = -1;
int allPosInit[50]={-1};
int posInit=0;

extern char lastID[31];
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
void updateTipoDatoSymbolInit(char* tipoDato);
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
	bloque {printf("\tFIN\n");}
	;
bloque:
	sentencia {printf("\tsentencia es bloque\n");}
	| bloque sentencia {printf("\tbloque sentencia es bloque\n");}
	;

sentencia:
	asignacion
	| iteracion 
	| seleccion
	| ESCRIBIR PARENTE_I CADENA PARENTE_D
	| ESCRIBIR PARENTE_I ID PARENTE_D
	| LEER PARENTE_I ID PARENTE_D
	| INIT LLAVE_I declaraciones LLAVE_D {printf("\tinit { declaraciones } es SENTENCIA\n");}
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
	OP_ASIG asignable{printf("\tID = asignable es ASIGNACION\n");}
	;

asignable:
	expresion {printf("\tID = Expresion es ASIGNABLE\n");}
	| CADENA {
		printf("\tID = CADENA es ASIGNABLE\n"); 
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		char largo[10];
		sprintf(largo,"%d", strlen(yytext));
		saveSymbol(symbol,"",yytext,largo);
		updateTipoDatoSymbol(pos,STR);
		}
	;

seleccion:
	SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D SINO LLAVE_I bloque LLAVE_D {printf("\tSI (condicion) bloque sino bloque = seleccion\n");}
	| SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("\tSI (condicion) bloque = seleccion\n");}
	;
iteracion:
	MIENTRAS PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("\tmientras (condicion) bloque = iteracion\n");}
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
	comparacion {printf("\tcomparacion = condicion\n");}
	|condicion compuertas comparacion {printf("\tcondicion compuerta comparacion = condicion\n");}
	;
comparacion:
	expresion comparador expresion {printf("\texpresion comparador expresion = comparacion\n");}
	|NOT comparacion {printf("\tNOT comparacion = comparacion\n");}
	| PARENTE_I comparacion PARENTE_D {printf("\t(comparacion) = comparacion\n");}
	| factor {printf("\tfactor = comparacion\n");}
	;

expresion:
	termino {printf("\tTermino es Expresion\n");}
	|expresion OP_SUMA termino {printf("\tExpresion+Termino es Expresion\n");}
	|expresion OP_REST termino {printf("\tExpresion-Termino es Expresion\n");}
	;

termino:
	factor {printf("\tFactor es Termino\n");}
	|termino OP_MULT factor {printf("\tTermino*Factor es Termino\n");}
	|termino OP_DIVI factor {printf("\tTermino/Factor es Termino\n");}
	;

factor:
	ID {printf("\tID es Factor \n");}
	| CTE {
		printf("\tCTE es Factor\n");
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		saveSymbol(symbol,"",yytext,"");
		updateTipoDatoSymbol(pos,INT);
		}
	| FLOT {printf("\tFLOT es Factor\n");
		char symbol[100];
		strcpy(symbol, "_"); 
		strcat(symbol, yytext);
		saveSymbol(symbol,"", yytext,"");
		updateTipoDatoSymbol(pos,FLOAT);
		}
	;
declaraciones:
	declaraciones variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tvariable : tipo dato declaracion es DECLARACION\n");
		}
	| variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tvariable : tipo dato es DECLARACION\n");
		}
	;

variables:
	ID { 
			pos = findSymbol(yytext); 
			if (pos==-1) {
				saveSymbol(yytext,"","_","");
				pos = filaActual-1;
			}
			allPosInit[posInit]=pos;
			posInit++;  
			printf("\tid es VARIABLE \n");
		}
	
	| variables COMA ID {
							pos = findSymbol(yytext); 
								if (pos==-1) {
									saveSymbol(yytext,"","_","");
									pos = filaActual-1;
								}
								allPosInit[posInit]=pos;
								posInit++;  
							printf("\tid, variables es VARIABLES\n");
						}
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

    FILE* file = fopen("symbol-table.txt", "w");
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
	if(strlen(filas[pos].tipoDato)!= 0 && strcmp(filas[pos].tipoDato, tipoDato)!= 0){
		printf("\nError semantico: El símbolo %s ya fue declarado con un tipo de dato distinto.\n", filas[pos].tipoDato);
		exit(-1) ;
	}
	else
		strcpy(filas[pos].tipoDato,tipoDato);
}
void updateTipoDatoSymbolInit( char* tipoDato){
	char tipoAux[10];

	if(strcmp("Int",tipoDato)==0)
		strcpy(tipoAux,INT);
	else if(strcmp("Float",tipoDato)==0)
		strcpy(tipoAux,FLOAT);
	else if(strcmp("String",tipoDato)==0)
		strcpy(tipoAux,STR);
	
	for (int i =0; i < posInit ;i++ ){
		updateTipoDatoSymbol(allPosInit[i],tipoAux);
		allPosInit[i]=-1;
	}
}
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud) {
    
	strcpy(filas[filaActual].nombre,nombre);
    strcpy(filas[filaActual].tipoDato,tipoDato);
    strcpy(filas[filaActual].valor,valor);
    strcpy(filas[filaActual].longitud,longitud);
    filaActual++;
}