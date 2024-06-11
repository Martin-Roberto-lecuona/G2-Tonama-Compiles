#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol.h"

int pedirAux(char* tipo);
char* obtenerInstruccionAritmetica(const char *operador);
int esAritmetica(const char *operador);
void  recorrerArbolParaAssembler(FILE * fp, tNodoArbol* raiz);
void generarAssembler(tNodoArbol* raiz);
int generarInstruccionesAssembler(tNodoArbol* raiz);

int cantAux=0;
#endif