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

void crearArbol(t_arbol *pa);

void saveArbolFile(t_arbol *p);

tNodoArbol *crearHoja(char *terminal);

tNodoArbol *crearHojaStr(char *terminal);

tNodoArbol *crearNodo(char *terminal,
                      t_arbol *arbol,
                      tNodoArbol *NoTerminalIzq,
                      tNodoArbol *NoTerminalDer);

void recorrer(t_arbol *p, FILE *treeFile);

void mostrarRelacion(t_arbol *p, FILE *treeFile);

tNodoArbol *asignacionPtr;
tNodoArbol *expresionPtr;
tNodoArbol *terminoPtr;
tNodoArbol *factorPtr;
tNodoArbol *asignablePtr;
tNodoArbol *bloquePtr;
tNodoArbol *sentenciaPtr;
tNodoArbol *initPtr;
tNodoArbol *declaracionesPtr;
tNodoArbol *variablesPtr;
t_arbol arbol;
int uniqueIdMain = 0;


#endif