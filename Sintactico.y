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
FILE  *treeFile;
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

typedef struct s_nodo{
    char* info;
    struct s_nodo *izq;
    struct s_nodo *der;
}tNodoArbol;

typedef tNodoArbol *t_arbol;

t_fila filas[MAX_FILAS];
int filaActual=0;
void saveInFile();
int findSymbol(char* nombre);
void updateTipoDatoSymbol(int pos, char* tipoDato);
void updateTipoDatoSymbolInit(char* tipoDato);
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud);
void saveSymbolCte(const char* valor);
void saveSymbolCadena(const char* valor);
void appendTreeFile(char *cad);
void createTreeFile();
void closeTreeFile();
void linkTreeFile(char *nodeValue, char *leftValue, char *rightValue);
void crearArbol(t_arbol *pa);
void saveArbolFile(t_arbol *p);

tNodoArbol* crearHoja( char* terminal);
tNodoArbol* crearHojaStr( char* terminal);
tNodoArbol* crearNodo(char* terminal, t_arbol* arbol, tNodoArbol* NoTerminalIzq,  tNodoArbol* NoTerminalDer);
void recorrer(t_arbol *arbol);

tNodoArbol* expresionPtr ;
tNodoArbol* terminoPtr;
tNodoArbol* factorPtr;
tNodoArbol* asignacionPtr;
tNodoArbol* asignablePtr;

t_arbol arbol;

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
%token CORCH_I         
%token CORCH_D         
%token ESCRIBIR
%token LEER
%token OR
%token AND
%token NOT
%token INIT
%token DOS_PUNT
%token TIPO_DATO
%token COMA
%token BUSC_Y_REMP
%token APLIC_DESC

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
	| buscarYreemplazar
	| aplicarDescuento
	;
aplicarDescuento:
	APLIC_DESC PARENTE_I factorFlotante COMA CORCH_I listaNum CORCH_D COMA factorCte PARENTE_D
	;

listaNum:
	listaNum COMA factorTodoFloat 
	| factorTodoFloat
	;
buscarYreemplazar:
	BUSC_Y_REMP PARENTE_I factorString COMA factorString COMA factorString PARENTE_D
	;

factorString:
	ID {printf("\tID es factorString \n");}
	| CADENA {
		printf("\nCADENA es factorString\n");
		saveSymbolCadena(yytext);}
	;
factorFlotante:
	ID {printf("\tID es factorFlotante \n");}
	| FLOT {
		printf("\tFlotante es factorFlotante\n");
		saveSymbolCte(yytext);
		}
	;
factorCte:
	ID {printf("\tID es factorCte \n");}
	| CTE {
		printf("\tCTE es factorCte\n");
		saveSymbolCte(yytext);
		}
	;
factorTodoFloat:
	factorFlotante 
	| CTE {
		printf("\tCTE es factorTodoFloat\n");
		saveSymbolCte(yytext);
		}
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
	| TIPO_DATO ID {
		pos = findSymbol(yytext); 
		if (pos==-1) {
			saveSymbol(yytext,"","_","");
			pos = filaActual-1;
		}  
	}
	OP_ASIG asignable{printf("\tID = asignable es ASIGNACION\n"); asignablePtr = crearNodo("asignacion",&arbol, crearHoja("id"), asignablePtr);}
	;

asignable:
	expresion {printf("\tExpresion es ASIGNABLE\n"); asignablePtr = expresionPtr;}
	| CADENA {
		printf("\tID = CADENA es ASIGNABLE\n"); 
		saveSymbolCadena(yytext);
		updateTipoDatoSymbol(pos,STR);
		}
	| buscarYreemplazar {
		printf("\tbuscarYreemplazar es ASIGNABLE\n"); 
		updateTipoDatoSymbol(pos,INT);
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
	AND {printf("\tAND = compuertas\n");}
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
	comparacion comparador factor {printf("\texpresion comparador expresion = comparacion\n");}
	| NOT factor {printf("\tNOT comparacion = comparacion\n");}
	| PARENTE_I comparacion comparador factor PARENTE_D {printf("\t(comparacion) = comparacion\n");}
	| factor {printf("\tfactor = comparacion\n");}
	;

expresion:
	termino {printf("\tTermino es Expresion\n"); expresionPtr = terminoPtr;}
	|expresion OP_SUMA termino {printf("\tExpresion+Termino es Expresion\n");expresionPtr = crearNodo("+",&arbol,expresionPtr, terminoPtr);}
	|expresion OP_REST termino {printf("\tExpresion-Termino es Expresion\n");expresionPtr = crearNodo("-",&arbol,expresionPtr, terminoPtr);}
	;

termino:
	factor {printf("\tFactor es Termino\n"); terminoPtr = factorPtr; }
	|termino OP_MULT factor {printf("\tTermino*Factor es Termino\n");terminoPtr = crearNodo("*",&arbol,terminoPtr, factorPtr);}
	|termino OP_DIVI factor {printf("\tTermino/Factor es Termino\n");terminoPtr = crearNodo("/",&arbol,terminoPtr, factorPtr);}
	;

factor:
	ID {printf("\tID es Factor \n");factorPtr = crearHoja(yytext);}
	| CTE {
		printf("\tCTE es Factor\n");
		saveSymbolCte(yytext);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(yytext);
		}
	| OP_REST CTE {
		printf("\t-CTE es Factor\n");
		char symbol[12];
		strcpy(symbol, "-"); 
		strcat(symbol, yytext);
		saveSymbolCte(symbol);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(symbol);
		}
	| FLOT {printf("\tFLOT es Factor\n");
		saveSymbolCte(yytext);
		updateTipoDatoSymbol(pos,FLOAT);
		factorPtr = crearHoja(yytext);
		}
	| PARENTE_I expresion PARENTE_D {printf("\t(exp_logica) es Factor\n");}
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
	expresionPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    terminoPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    factorPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    asignacionPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    asignablePtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));

    crearArbol(&arbol);
    createTreeFile();
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        yyparse();
    }
	saveInFile();
	saveArbolFile(&arbol);
	fclose(yyin);
	closeTreeFile();
    return 0;
}
int yyerror(void)
{
	printf("Error Sintactico\n");
	exit (1);
}

void createTreeFile(){
    treeFile = fopen("tree.dot", "w+");
    if (treeFile == NULL) {
	perror("Error al abrir el archivo");
	exit(1);
    }
    fprintf(treeFile,"digraph ejemplo1{\n");
}

void closeTreeFile(){
	fprintf(treeFile,"}");
	fclose(treeFile);
}

void appendTreeFile(char *cad){
      fprintf(treeFile,"\"%s\";\n",cad);
}

void linkTreeFile(char *nodeValue, char *leftValue, char *rightValue){
	fprintf(treeFile,"\"%s\";\n",nodeValue);
	fprintf(treeFile,"\"%s\" -> \"%s\";\n",nodeValue,leftValue);
	fprintf(treeFile,"\"%s\" -> \"%s\";\n",nodeValue,rightValue);
}

void saveInFile(){

    FILE* file = fopen("symbol-table.txt", "w+");
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

void saveSymbolCte(const char* valor){
	char symbol[100];
	strcpy(symbol, "_"); 
	strcat(symbol, valor);
	saveSymbol(symbol,"",valor,"");
}
void saveSymbolCadena(const char* valor){
	char symbol[100];
	strcpy(symbol, "_"); 
	strcat(symbol, valor);
	char largo[10];
	sprintf(largo,"%d", strlen(valor));
	saveSymbol(symbol,"",valor,largo);
}

void crearArbol(t_arbol *pa)
{
    *pa = NULL;
}

tNodoArbol* crearHoja(char* terminal){
    printf("crearHoja new: %s \n", terminal);
	tNodoArbol* nuevo = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    nuevo->info = malloc(strlen(terminal)+1);
    memcpy(nuevo->info, terminal, strlen(terminal)+1);
    nuevo->der= NULL;
    nuevo->izq= NULL;
    printf("FIN crearHoja\n");
    appendTreeFile(terminal);
    return nuevo;
}

tNodoArbol* crearNodo(char* terminal, t_arbol* arbol, tNodoArbol* NoTerminalIzq,  tNodoArbol* NoTerminalDer){
    printf("crearNodo\n");
    tNodoArbol* nodo = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    nodo->info = malloc(strlen(terminal)+1);
    memcpy(nodo->info, terminal, strlen(terminal)+1);
    nodo->der= NoTerminalDer;
    nodo->izq= NoTerminalIzq;
    *arbol = nodo;
    printf("FIN crearNodo\n");
    linkTreeFile(terminal, NoTerminalIzq->info, NoTerminalDer->info);
    return nodo;
}

void recorrer(t_arbol *p)
{
    if(!*p)
    {
        return;
    }
    recorrer(&(*p)->izq);
    printf("%s\n", (*p)->info);
    recorrer(&(*p)->der);
}
void saveArbolFile(t_arbol *p){
    printf("Recorrer: \n");
    recorrer(p);
}