#ifndef ASSEMBLER_H
#define ASSEMBLER_H
#include "arbol.h"
#include "tsimbolos.h"
#define ASM_FILE "C:/DOS/Final.asm"
#define ASM_FILE_CODE "instruccionesAssembler.txt"
#define PUT_STR "PUT"
#define GET_STR "GET"

int escribirInstruccionesEnASM(FILE* fpFinal, char * nameFile);
void operacion(FILE * fp, tNodoArbol* raiz);
int pedirAux();
char* obtenerInstruccionAritmetica(const char *operador);
int esAritmetica(const char *operador);
void  recorrerArbolParaAssembler(FILE * fp, tNodoArbol* raiz);
void generarAssembler(tNodoArbol* raiz);
int generarInstruccionesAssembler(tNodoArbol* raiz);
void generarComparacion(FILE * fp, tNodoArbol* raiz);
int esComparacion(tNodoArbol* raiz);
void generarSalto(FILE * fp, char* comparador);
char* obtenerInstruccionComparacion(const char *comparador);

void recorrerArbolAssembler(t_arbol *p, FILE *f);
void recorrerTablaSimbolos(FILE *file);

int ifCounter = 0;
int cantAux=0;
int flagOR = 0;
int elseCounter = 0;
int flagElse = 0;

typedef struct{
  int flagOr;
  int flagElse;
}t_condition;

typedef struct{
  t_condition list[10];
  int tope;
}t_list_cond;

t_list_cond listCond = {{{0, 0}}, -1};
#endif