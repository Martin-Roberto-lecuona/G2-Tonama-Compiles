#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol.h"
#include "tsimbolos.h"
#define ASM_FILE "Final.asm"
#define ASM_FILE_CODE "instruccionesAssembler.txt"

int escribirInstruccionesEnASM(FILE* fpFinal, char * nameFile);
void operacion(FILE * fp, tNodoArbol* raiz);
int pedirAux(char* tipo);
char* obtenerInstruccionAritmetica(const char *operador);
int esAritmetica(const char *operador);
void  recorrerArbolParaAssembler(FILE * fp, tNodoArbol* raiz);
void generarAssembler(tNodoArbol* raiz);
int generarInstruccionesAssembler(tNodoArbol* raiz);


void recorrerArbolAssembler(t_arbol *p, FILE *f);
void recorrerTablaSimbolos(FILE *file);


int cantAux=0;
#endif