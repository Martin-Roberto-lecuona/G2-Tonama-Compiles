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
#define MAX_CAD 100


#define VAL_INIT(x) (strcmp(x, "String") == 0 ? "($)" : "0")

int yystopparser=0;
FILE  *yyin;
int yyerror();
int yylex();
char *yytext;
extern char lastID[31];
char auxIdName[TAM_ID];
char auxCadVal[MAX_CAD];
void clearString(char* cad, int tam);
char* trimComillas(char* cad);
int tamListaDesc = 0;
int banderaAsignacionInt = 0;

char BusyRem_bus[MAX_CAD];
char BusyRem_cad[MAX_CAD];
char BusyRem_rem[MAX_CAD];

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
	| INIT LLAVE_I declaraciones LLAVE_D bloque { printf("\tproyecto -> init { declaraciones } bloque FIN\n");}
	| INIT LLAVE_I LLAVE_D bloque {printf("\tproyecto -> init {} bloque FIN\n");}
	;
bloque:
	sentencia {
				printf("\nBloque -> sentencia\n"); 
				bloquePtr = sentenciaPtr; 
			}
	| bloque sentencia {printf("\tBloque -> sentencia es bloque\n");
						uniqueIdMain++;
						bloquePtr = crearNodo("Bloque",&arbol, bloquePtr, sentenciaPtr);
						}
	;
bloqueInterno:
	sentencia {
				printf("\tBloqueInterno -> sentencia\n"); 
				bloqueInternoPtr = sentenciaPtr; 
			}
	| bloqueInterno sentencia {printf("\tBloqueInterno -> sentencia es bloque\n");
						uniqueIdMain++;
						bloqueInternoPtr = crearNodo("BloqueI",&arbol, bloqueInternoPtr, sentenciaPtr);
						}
	;
	
sentencia:
	asignacion {	printf("\tsentencia -> asignacion\n");
					sentenciaPtr = crearNodo("Sentencia",&arbol, asignacionPtr, NULL);
				}
	| iteracion {	printf("\tsentencia -> iteracion\n");
	            	uniqueIdMain++;
	            	sentenciaPtr = crearNodo("Sentencia", &arbol,iteracionPtr,NULL);
	            }
	| seleccionSi {	printf("\tsentencia -> seleccion\n");
	              	uniqueIdMain++;
					condicionPtr = desapilarDinamica(&pilaCondicion);
	             	sentenciaPtr = crearNodo("if",&arbol, condicionPtr, crearNodo("CUERPO", &arbol, desapilarDinamica(&pilaBloqueInterno), NULL));				
					}
	| seleccionSi seleccionSino { printf("\tsentencia -> seleccionSino\n");
	   					uniqueIdMain++;
					   condicionPtr = desapilarDinamica(&pilaCondicion);
					   sinoPtr = crearNodo("else", &arbol, desapilarDinamica(&pilaBloqueInterno), NULL);
					   sentenciaPtr = crearNodo("if",&arbol, condicionPtr, crearNodo("CUERPO", &arbol, desapilarDinamica(&pilaBloqueInterno), sinoPtr));
	   }
	| ESCRIBIR PARENTE_I CADENA
								{
									strcpy(auxCadVal,yytext);
								} 
	PARENTE_D {
		printf("\tsentencia -> escribir ( cadena )\n");
		uniqueIdMain++;
	    sentenciaPtr = crearNodo("PUT", &arbol,crearHoja("STDOUT"),crearHoja(trimComillas(auxCadVal)));
		}
	| ESCRIBIR PARENTE_I ID {
								strcpy(auxCadVal,yytext);
							} 
	PARENTE_D{
		printf("\tsentencia -> escribir ( ID )\n");
		uniqueIdMain++;
	    sentenciaPtr = crearNodo("PUT", &arbol,crearHoja("STDOUT"),crearHoja(auxCadVal));
	}
	| LEER PARENTE_I ID {
							pos = findSymbol(yytext);
							if (pos==-1) {
								printf("Error: %s no declarado\n", yytext);
								exit(-1);
							}
							strcpy(auxCadVal,yytext);
						} PARENTE_D {
							printf("\tsentencia -> leer ( ID )\n");
							uniqueIdMain++;
							sentenciaPtr = crearNodo("GET", &arbol,crearHoja("STDIN"),crearHoja(auxCadVal)); 
						} 
	| buscarYreemplazar {sentenciaPtr = buscarYreemplazarPtr;}
	| aplicarDescuento {sentenciaPtr = crearNodo("AplicarDescuento", &arbol,descuentoPtr,NULL);}
	;
aplicarDescuento:
	APLIC_DESC {	uniqueIdMain++;
					descuentoPtr=crearNodo("=", &arbol, crearHoja("@res"), crearHoja("0"));
					uniqueIdMain++;
	} PARENTE_I factorFlotante {
					if (atof(yytext)>100.0){
						printf("Error: el monto en aplicarDescuento debe ser menor a 100.0");
						exit (-1);
					}
					factorFlotantePtr=crearNodo("=", &arbol, crearHoja("@mon"), crearHoja(yytext));
					uniqueIdMain++;
	}COMA CORCH_I listaNum CORCH_D COMA factorCte {
					if (atoi(yytext) > tamListaDesc){
						printf("Error semantico: el indice debe ser menor o igual al tamaño de la lista. Indice %d TamLista %d",atoi(yytext),tamListaDesc);
						exit (-1);
					}
					factorCtePtr=crearNodo("=", &arbol, crearHoja("@aux"), crearHoja(yytext));
					uniqueIdMain++;
					tamListaDesc = 0;
	} PARENTE_D {
					factorFlotantePtr = crearNodo("Sentencia", &arbol, factorFlotantePtr, factorCtePtr);
					uniqueIdMain++;
					descuentoPtr = crearNodo("Sentencia", &arbol, descuentoPtr, factorFlotantePtr);
					uniqueIdMain++;
					descuentoPtr= crearNodo("Sentencia", &arbol, descuentoPtr, listaNumPtr);
	}
	| APLIC_DESC PARENTE_I factorFlotante COMA CORCH_I CORCH_D COMA factorCte PARENTE_D { 
						printf ("Error: no se acepta lista vacia en aplicarDescuento");
						exit(-1);
						}
	;

listaNum:
	listaNum COMA factorTodoFloat {listaNumPtr = crearNodo("Bloque", &arbol, listaNumPtr,aplicarDescuentoItem(yytext));uniqueIdMain++;tamListaDesc += 1;}
	| factorTodoFloat {tamListaDesc += 1; listaNumPtr = aplicarDescuentoItem(yytext);uniqueIdMain++;}
	;
buscarYreemplazar:
	BUSC_Y_REMP PARENTE_I factorString {strcpy(BusyRem_bus,yytext);} 
					COMA factorString {strcpy(BusyRem_cad,yytext);} 
					COMA factorString {strcpy(BusyRem_rem,yytext);} 
				PARENTE_D {	buscarYreemplazarPtr = buscarYReemplazar(BusyRem_bus,BusyRem_cad,BusyRem_rem);
							clearString(BusyRem_bus,MAX_CAD);
							clearString(BusyRem_cad,MAX_CAD);
							clearString(BusyRem_rem,MAX_CAD);
						}
	;

factorString:
	ID {printf("\tfactorString -> ID \n");}
	| CADENA {
		printf("\nfactorString -> CADENA\n");
		saveSymbolCadena(yytext);}
	;
factorFlotante:
	ID {printf("\tfactorFlotante -> ID \n");}
	| FLOT {
		printf("\tfactorFlotante -> Flotante\n");
		saveSymbolFloat(yytext);
		}
	;
factorCte:
	ID {printf("\tfactorCte -> ID\n");}
	| CTE {
		printf("\tfactorCte -> CTE\n");
		saveSymbolCte(yytext);
		}
	;
factorTodoFloat:
	factorFlotante
	| CTE {
		printf("\tfactorTodoFloat -> CTE\n");
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
		if (strcmp(filas[pos].tipoDato, INT) == 0)
			banderaAsignacionInt = 1;
		else 
			banderaAsignacionInt = 0;
		
		strcpy(auxIdName,yytext);
	}
	OP_ASIG asignable{
					printf("\tasignacion -> ID = asignable\n");
					uniqueIdMain++;
					asignablePtr = crearNodo("=",&arbol, crearHoja(auxIdName), asignablePtr);
					asignacionPtr = asignablePtr;
					clearString(auxIdName, TAM_ID);
					}
	;

asignable:
	expresion {printf("\tASIGNABLE -> Expresion\n"); asignablePtr = expresionPtr;}
	| CADENA {
		printf("\tASIGNABLE -> ID\n");
		saveSymbolCadena(yytext);
		updateTipoDatoSymbol(pos,STR);
		asignablePtr = crearHoja(trimComillas(yytext));
		}
	| buscarYreemplazar {
		printf("\tASIGNABLE -> buscarYreemplazar\n");
		updateTipoDatoSymbol(pos,INT);
		asignablePtr = buscarYreemplazarPtr;
		}
	;

seleccionSi:
	SI PARENTE_I condicion {apilarDinamica(&pilaCondicion, condicionPtr);} PARENTE_D LLAVE_I bloqueInterno LLAVE_D {
				uniqueIdMain++;
				apilarDinamica(&pilaBloqueInterno, bloqueInternoPtr);
				}
seleccionSino:
	SINO LLAVE_I bloqueInterno LLAVE_D
	      {printf("\tseleccion -> SI (condicion) {bloque} sino {bloque}\n");
	       	uniqueIdMain++;
			apilarDinamica(&pilaBloqueInterno, bloqueInternoPtr);
			}
	;
iteracion:
	MIENTRAS PARENTE_I condicion {apilarDinamica(&pilaCondicion, condicionPtr);} PARENTE_D LLAVE_I bloqueInterno LLAVE_D {
	    printf("\titeracion -> mientras (condicion) {bloque}\n");
	    uniqueIdMain++;
		bloqueInternoPtr = crearNodo("CUERPO",&arbol,bloqueInternoPtr,NULL);
	    iteracionPtr = crearNodo("WHILE",&arbol,desapilarDinamica(&pilaCondicion),bloqueInternoPtr);
	    }
	;
compuertas:
	AND {printf("\tcompuertas -> AND\n"); compuertasPtr = crearHoja("AND");}
	|OR {printf("\tcompuertas -> OR\n"); compuertasPtr = crearHoja("OR");}
	;
comparador:
	OP_MAYOR { comparadorPtr = crearHoja(">");}
	| OP_MENOR { comparadorPtr = crearHoja("<");}
	| OP_MAYOR_IGUAL { comparadorPtr = crearHoja(">=");}
	| OP_MENOR_IGUAL { comparadorPtr = crearHoja("<=");}
	| OP_IGUAL { comparadorPtr = crearHoja("==");}
	;

condicion:
	comparacion {printf("\tcondicion -> comparacion\n"); condicionPtr = comparacionPtr;}
	|comparacion compuertas comparacion {
		printf("\tcondicion -> condicion compuerta comparacion\n");
		condicionPtr = crearNodo(compuertasPtr->info, &arbol, desapilarDinamica(&pila), desapilarDinamica(&pila));
		}
	| NOT comparacion {condicionPtr = crearNodo("NOT", &arbol, comparacionPtr , NULL);}
	;
comparacion:
	factor comparador factor {
				printf("\tcomparacion -> expresion comparador expresion\n");
				uniqueIdMain++;
				comparacionPtr = crearNodo(comparadorPtr->info, &arbol,  desapilarDinamica(&pila), desapilarDinamica(&pila));
				apilarDinamica(&pila, comparacionPtr);
	}
	;

expresion:
	termino {printf("\tExpresion -> Termino\n"); expresionPtr = terminoPtr;}
	|expresion OP_SUMA termino {printf("\tExpresion -> Expresion + Termino \n");
								expresionPtr = crearNodo("+",&arbol,expresionPtr, terminoPtr);
								desapilarDinamica(&pilaExpresion);}
	|expresion OP_REST termino {printf("\tExpresion -> Expresion - Termino \n");
								expresionPtr = crearNodo("-",&arbol,expresionPtr, terminoPtr);
								desapilarDinamica(&pilaExpresion);}
	;

termino:
	factor {printf("\tTermino -> Factor\n"); terminoPtr = factorPtr; }
	|termino OP_MULT factor {printf("\tTermino -> Termino * Factor\n");
							terminoPtr = crearNodo("*",&arbol,terminoPtr, factorPtr); 
							desapilarDinamica(&pilaExpresion);
							}
	|termino OP_DIVI factor {printf("\tTermino -> Termino / Factor\n");
							terminoPtr = crearNodo("/",&arbol,terminoPtr, factorPtr);
							desapilarDinamica(&pilaExpresion);
							}
	;

factor:
	ID {printf("\tFactor -> ID\n");
		factorPtr = crearHoja(yytext);
		apilarDinamica(&pila, factorPtr);
		apilarDinamica(&pilaExpresion,factorPtr);
		if (banderaAsignacionInt == 1 && strcmp(filas[findSymbol(yytext)].tipoDato, FLOAT) == 0 ){
			printf("\tError: No se puede asignar un flotante a un entero\n");
			exit(-1);
		}
		}
	| CTE {
		printf("\tFactor -> CTE\n");
		saveSymbolCte(yytext);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(yytext);
		apilarDinamica(&pila, factorPtr);
		apilarDinamica(&pilaExpresion,factorPtr);
		}
	| OP_REST CTE {
		printf("\tFactor -> -CTE\n");
		char symbol[12] = "-";
		strcat(symbol, yytext);
		saveSymbolCte(symbol);
		updateTipoDatoSymbol(pos,INT);
		factorPtr = crearHoja(symbol);
		}
	| FLOT {printf("\tFactor -> FLOT\n");
		saveSymbolFloat(yytext);
		updateTipoDatoSymbol(pos,FLOAT);
		factorPtr = crearHoja(yytext);
		if (banderaAsignacionInt == 1){
			printf("\tError: No se puede asignar un flotante a un entero\n");
			exit(-1);
		}
		}
	| PARENTE_I expresion PARENTE_D {	printf("\tFactor -> (exp_logica)\n");
										desapilarDinamica(&pilaExpresion);
										uniqueIdMain++;
										factorPtr = expresionPtr;
										terminoPtr = crearHoja((desapilarDinamica(&pilaExpresion))->info);
										}
	;

declaraciones:
	declaraciones variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tdeclaraciones -> declaraciones variables : TipoDato\n");
		}
	| variables DOS_PUNT TIPO_DATO {
			updateTipoDatoSymbolInit(yytext);
			printf("\tdeclaraciones -> variables : TipoDato\n");
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
						}
	;
%%

int main(int argc, char *argv[]) {


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
char* trimComillas(char* cad){
	char* cadena = malloc(strlen(cad) + 1);
	if(cadena == NULL) {
		return NULL;
	}
	strcpy(cadena,cad);
	cadena[0] = '(';
	cadena[strlen(cadena)-1] = ')';
	cadena[strlen(cadena)] = '\0';
	return cadena;
}