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
#define TAM_ID 31

#define VAL_INIT(x) (strcmp(x, "String") == 0 ? "$" : "0")


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

typedef struct s_nodo{
    char* info;
    struct s_nodo *izq;
    struct s_nodo *der;
	int uniqueId;
}tNodoArbol;

typedef tNodoArbol *t_arbol;

t_fila filas[MAX_FILAS];
int filaActual=0;
char auxIdName[TAM_ID];
int uniqueIdMain = 0;

void createSymbolTableInFile();
void saveSymbolTableFile();
int findSymbol(char* nombre);
void updateTipoDatoSymbol(int pos, char* tipoDato);
void updateTipoDatoSymbolInit(char* tipoDato);
void saveSymbol(const char* nombre,const char* tipoDato,const char* valor,const char* longitud);
void saveSymbolCte(const char* valor);
void saveSymbolCadena(const char* valor);
void saveSymbolFloat(const char* valor);
void clearString(char* cad, int tam);


void createTreeFile();
void mostrarRelacion(t_arbol *p, FILE  *treeFile);
void crearArbol(t_arbol *pa);
void saveArbolFile(t_arbol *p);

tNodoArbol* crearHoja( char* terminal);
tNodoArbol* crearHojaStr( char* terminal);
tNodoArbol* crearNodo(char* terminal, t_arbol* arbol, tNodoArbol* NoTerminalIzq,  tNodoArbol* NoTerminalDer);
void recorrer(t_arbol *p, FILE  *treeFile);

tNodoArbol* asignacionPtr;
tNodoArbol* expresionPtr ;
tNodoArbol* terminoPtr;
tNodoArbol* factorPtr;
tNodoArbol* asignablePtr;

tNodoArbol* bloquePtr;

tNodoArbol* sentenciaPtr;

tNodoArbol* initPtr;
tNodoArbol* declaracionesPtr;
tNodoArbol* variablesPtr;

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
	bloque {printf("\tFIN\n"); }
	;
bloque:
	sentencia {printf("\nBloque -> sentencia\n"); bloquePtr = sentenciaPtr; }
	| bloque sentencia {printf("\tBloque -> sentencia es bloque\n"); 
						uniqueIdMain++;
						bloquePtr = crearNodo("Bloque",&arbol, bloquePtr, sentenciaPtr);
						}
	;

sentencia:
	asignacion {printf("\tsentencia -> asignacion\n"); 
				sentenciaPtr = crearNodo("Sentencia",&arbol, asignacionPtr, NULL);
				}
	| iteracion {printf("\tsentencia -> iteracion\n");}
	| seleccion {printf("\tsentencia -> seleccion\n");}
	| ESCRIBIR PARENTE_I CADENA PARENTE_D {printf("\tsentencia -> escribir ( cadena )\n");}
	| ESCRIBIR PARENTE_I ID PARENTE_D
	| LEER PARENTE_I ID PARENTE_D
	| INIT LLAVE_I declaraciones LLAVE_D {
								printf("\tsentencia -> init { declaraciones }\n"); 
								uniqueIdMain++;
								sentenciaPtr = crearNodo("init", &arbol,declaracionesPtr,NULL); 
								 }
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
	ID {printf("\tfactorString -> ID \n");}
	| CADENA {
		printf("\nCADENA es factorString\n");
		saveSymbolCadena(yytext);}
	;
factorFlotante:
	ID {printf("\tID es factorFlotante \n");}
	| FLOT {
		printf("\tFlotante es factorFlotante\n");
		saveSymbolFloat(yytext);
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
			printf("Error: %s no declarado\n", yytext);
			exit(-1);
		} 
		strcpy(auxIdName,yytext);
	}
	OP_ASIG asignable{
					printf("\tasignacion -> = asignable\n"); 
					
					asignablePtr = crearNodo("=",&arbol, crearHoja(auxIdName), asignablePtr);
					asignacionPtr = asignablePtr;
					clearString(auxIdName, TAM_ID);
					}
	;

asignable:
	expresion {printf("\tExpresion es ASIGNABLE\n"); asignablePtr = expresionPtr;}
	| CADENA {
		printf("\tID = CADENA es ASIGNABLE\n"); 
		saveSymbolCadena(yytext);
		updateTipoDatoSymbol(pos,STR);
		// borrar ultimo y primero 
		char* cadena = yytext;
		cadena++;
		cadena[strlen(cadena) - 1] = '\0';
		// asignablePtr = crearNodo("=*",&arbol,crearHoja(cadena), asignablePtr);
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
	AND {printf("\tcompuertas -> AND\n");}
	|OR {printf("\tcompuertas -> OR\n");}
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
	ID {printf("\tID es Factor \n");
		factorPtr = crearHoja(yytext);
		}
	| CTE {
		printf("\tCTE es Factor\n");
		saveSymbolCte(yytext);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(yytext);
		}
	| OP_REST CTE {
		printf("\t-CTE es Factor\n");
		char symbol[12] = "-";
		strcat(symbol, yytext);
		saveSymbolCte(symbol);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(symbol);
		}
	| FLOT {printf("\tFLOT es Factor\n");
		saveSymbolFloat(yytext);
		updateTipoDatoSymbol(pos,FLOAT);
		factorPtr = crearHoja(yytext);
		}
	| PARENTE_I expresion PARENTE_D {printf("\t(exp_logica) es Factor\n");}
	;

declaraciones:
	declaraciones variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tdeclaraciones -> declaraciones variables : TipoDato\n");
			uniqueIdMain++;
			declaracionesPtr = crearNodo("=", &arbol, variablesPtr, crearHoja(VAL_INIT(yytext)));
			declaracionesPtr = crearNodo("init", &arbol,declaracionesPtr,NULL);
		}
	| variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tdeclaraciones -> variables : TipoDato\n");
			// declaracionesPtr = crearNodo("=", &arbol, variablesPtr, crearHoja(VAL_INIT(yytext)));
			// declaracionesPtr = crearNodo("init", &arbol,declaracionesPtr,NULL);
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
			printf("\tvariable-> id \n");
			variablesPtr = crearHoja(yytext);
		}
	
	| variables COMA ID {
							pos = findSymbol(yytext); 
								if (pos==-1) {
									saveSymbol(yytext,"","_","");
									pos = filaActual-1;
								}
							allPosInit[posInit]=pos;
							posInit++;  
							printf("\tvariable-> variable , id \n");
							variablesPtr = crearNodo("=", &arbol,crearHoja(yytext), variablesPtr);
							uniqueIdMain++;
						}
	;
%%


int main(int argc, char *argv[])
{
    asignacionPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
	expresionPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    terminoPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    factorPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    asignablePtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
	bloquePtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));
	sentenciaPtr = (tNodoArbol*)malloc(sizeof(tNodoArbol));

    crearArbol(&arbol);
    createTreeFile();
	createSymbolTableInFile();
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        yyparse();
    }
	saveSymbolTableFile();
	saveArbolFile(&arbol);
	fclose(yyin);
    return 0;
}
int yyerror(void)
{
	printf("Error Sintactico\n");
	exit (1);
}
void createSymbolTableInFile(){
	FILE* file = fopen("symbol-table.txt", "w");
    if (file == NULL) {
        perror("Error al abrir el archivo");
        exit(1);
    }
	fprintf(file,"Error de compilacion");
    fclose(file);
}
void createTreeFile(){
    FILE* treeFile = fopen("tree.dot", "w");
    if (treeFile == NULL) {
		perror("Error al abrir el archivo");
		exit(1);
    }
    fprintf(treeFile,"Error de compilacion\n");
	fclose(treeFile);
}

void saveSymbolTableFile(){

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
		printf("\nError semantico: El símbolo %s. Se esperaba %s no un %s \n", filas[pos].nombre, filas[pos].tipoDato, tipoDato);
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
	saveSymbol(symbol,"ENTERO",valor,"");
}
void saveSymbolFloat(const char* valor){
	char symbol[100];
	strcpy(symbol, "_"); 
	strcat(symbol, valor);
	saveSymbol(symbol,"FLOTANTE",valor,"");
}
void saveSymbolCadena(const char* valor){
	char symbol[100];
	strcpy(symbol, "_"); 
	strcat(symbol, valor);
	char largo[10];
	sprintf(largo,"%d", strlen(valor));
	saveSymbol(symbol,"CADENA",valor,largo);
}

void crearArbol(t_arbol *pa)
{
    *pa = NULL;
}

tNodoArbol* crearHoja(char* terminal){
    /* printf("crearHoja new: %s \n", terminal); */
	tNodoArbol* nuevo = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    nuevo->info = malloc(strlen(terminal)+1);
    memcpy(nuevo->info, terminal, strlen(terminal)+1);
    nuevo->der= NULL;
    nuevo->izq= NULL;
	nuevo->uniqueId=uniqueIdMain;
    /* printf("FIN crearHoja\n"); */
    return nuevo;
}

tNodoArbol* crearNodo(char* terminal, t_arbol* arbol, tNodoArbol* NoTerminalIzq,  tNodoArbol* NoTerminalDer){
    /* printf("crearNodo\n"); */
    tNodoArbol* nodo = (tNodoArbol*)malloc(sizeof(tNodoArbol));
    nodo->info = malloc(strlen(terminal)+1);
    memcpy(nodo->info, terminal, strlen(terminal)+1);
    nodo->der= NoTerminalDer;
    nodo->izq= NoTerminalIzq;
    *arbol = nodo;
	nodo->uniqueId=uniqueIdMain;
    /* printf("FIN crearNodo\n"); */
    return nodo;
}

void recorrer(t_arbol *p, FILE  *treeFile){
    if(!*p)
    {
        return;
    }
    recorrer(&(*p)->izq,treeFile);
	mostrarRelacion(p,treeFile);
    recorrer(&(*p)->der,treeFile);
}
void mostrarRelacion(t_arbol *p, FILE  *treeFile){

	if ((*p)->izq){
		fprintf(treeFile,"\"%s_%d\" -> \"%s_%d\";\n",
													(*p)->info,
													(*p)->uniqueId,
													(*p)->izq->info,
													(*p)->izq->uniqueId);
	}
	if ((*p)->der){
		fprintf(treeFile,"\"%s_%d\" -> \"%s_%d\";\n",
													(*p)->info,
													(*p)->uniqueId,
													(*p)->der->info,
													(*p)->der->uniqueId);
	}
}
void saveArbolFile(t_arbol *p){
    FILE  *treeFile = fopen("tree.dot", "w");
    if (treeFile == NULL) {
		perror("Error al abrir el archivo");
		exit(1);
    }
    fprintf(treeFile,"digraph programa{\n");
    recorrer(p,treeFile);
	fprintf(treeFile,"}");
	fclose(treeFile);
}

void clearString(char* cad, int tam){
	memset(cad, 0, tam);
}