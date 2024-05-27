#ifndef ARBOL_H
#define ARBOL_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>


typedef struct s_nodo {
  char *info;
  struct s_nodo *izq;
  struct s_nodo *der;
  int uniqueId;
} tNodoArbol;

typedef tNodoArbol *t_arbol;

typedef struct p_nodo
{
  tNodoArbol* dato;
  struct p_nodo* psig;
} t_nodo;

typedef t_nodo* t_pila;

void crearArbol(t_arbol *pa);

void saveArbolFile(t_arbol *p);

tNodoArbol *crearHoja(char *terminal);

tNodoArbol *crearHojaStr(char *terminal);

tNodoArbol *crearNodo(char *terminal,
                      t_arbol *arbol,
                      tNodoArbol *NoTerminalIzq,
                      tNodoArbol *NoTerminalDer);

tNodoArbol *asignarHijosNodo(tNodoArbol *Padre,
                      t_arbol *arbol,
                      tNodoArbol *NoTerminalIzq,
                      tNodoArbol *NoTerminalDer);

void recorrer(t_arbol *p, FILE *treeFile);

void mostrarRelacion(t_arbol *p, FILE *treeFile);

int apilarDinamica(t_pila *PP, tNodoArbol* pd);
tNodoArbol * desapilarDinamica(t_pila *pp);

tNodoArbol *asignacionPtr;
tNodoArbol *expresionPtr;
tNodoArbol *terminoPtr;
tNodoArbol *factorPtr;
tNodoArbol *asignablePtr;
tNodoArbol *bloquePtr;
tNodoArbol *bloqueInternoPtr;
tNodoArbol *sentenciaPtr;
tNodoArbol *initPtr;
tNodoArbol *declaracionesPtr;
tNodoArbol *variablesPtr;
tNodoArbol *variablesPtrAux;
tNodoArbol *comparadorPtr;
tNodoArbol *compuertasPtr;
tNodoArbol *condicionPtr;
tNodoArbol *comparacionPtr;
tNodoArbol *seleccionPtr;
tNodoArbol *sinoPtr;
tNodoArbol *iteracionPtr;

t_arbol arbol;
t_pila pila;
t_pila pilaCondicion;
t_pila pilaBloqueInterno;
int uniqueIdMain = 0;

#endif