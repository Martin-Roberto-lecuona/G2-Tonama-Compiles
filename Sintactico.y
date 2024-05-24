// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include "lib/arbol.c"
#include "lib/tsimbolos.c"
#include "y.tab.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM_ID 31

#define VAL_INIT(x) (strcmp(x, "String") == 0 ? "($)" : "0")

int yystopparser=0;
FILE  *yyin;
int yyerror();
int yylex();
char *yytext;
extern char lastID[31];
char auxIdName[TAM_ID];
void clearString(char* cad, int tam);

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
					uniqueIdMain++;
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
		char cadena[100] ;
		strcpy(cadena,yytext);
		cadena[0] = '(';
		cadena[strlen(cadena)-1] = ')';
		cadena[strlen(cadena)] = '\0';
		// asignablePtr = crearNodo("CAD =",&arbol,crearHoja(cadena), asignablePtr);
		asignablePtr = crearHoja(cadena);
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
	|comparacion compuertas comparacion {printf("\tcondicion compuerta comparacion = condicion\n");}
	| NOT comparacion
	;
comparacion:
	factor comparador factor {printf("\texpresion comparador expresion = comparacion\n");}
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
			if(variablesPtrAux != NULL){
				declaracionesPtr = crearNodo("init", &arbol, declaracionesPtr, variablesPtr);
				uniqueIdMain++;
				declaracionesPtr = crearNodo("init", &arbol, declaracionesPtr, crearHoja(VAL_INIT(yytext)));
			}
			else {
				declaracionesPtr = crearNodo("init", &arbol, variablesPtr, crearHoja(VAL_INIT(yytext)));
			}
			variablesPtrAux = NULL;
		}
	| variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tdeclaraciones -> variables : TipoDato\n");
			// uniqueIdMain++;
			declaracionesPtr = crearNodo("init", &arbol, variablesPtr, crearHoja(VAL_INIT(yytext)));
			variablesPtrAux = declaracionesPtr;
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

int main(int argc, char *argv[]) {
  asignacionPtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  expresionPtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  terminoPtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  factorPtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  asignablePtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  bloquePtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  sentenciaPtr = (tNodoArbol *) malloc(sizeof(tNodoArbol));

  crearArbol(&arbol);
  createSymbolTableInFile();
  if ((yyin = fopen(argv[1], "rt")) == NULL) {
    printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
  } else {
    yyparse();
  }
  saveSymbolTableFile();
  saveArbolFile(&arbol);
  fclose(yyin);
  return 0;
}

int yyerror(void) {
  printf("Error Sintactico\n");
  exit(1);
}

void clearString(char *cad, int tam) {
  memset(cad, 0, tam);
}