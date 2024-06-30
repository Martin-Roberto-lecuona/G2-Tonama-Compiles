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
int evaluarOr();

void recorrerArbolAssembler(t_arbol *p, FILE *f);
void recorrerTablaSimbolos(FILE *file);

int cantAux=0;

typedef struct{
  int flagOr;
  int flagElse;
}t_condition;

typedef struct{
  t_condition list[10];
  int tope;
}t_list_cond;

typedef struct{
  int flagOr;
}t_iteracion;

typedef struct{
  t_iteracion list[10];
  int tope;
}t_list_iter;

t_list_iter listIter = {{{0}}, -1};
t_list_cond listCond = {{{0, 0}}, -1};

typedef struct {
    char *comparador;
    char *operacion;
    char *invertido;
} t_salto;

const t_salto compYSalto[] = {
    {">", "JA", "JNA"},
    {">=", "JAE", "JNAE"},
    {"<", "JB", "JNB"},
    {"<=", "JBE", "JNBE"},
    {"==", "JE", "JNE"},
    {"<>", "JNE", "JE"},
};

#endif