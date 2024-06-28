#ifndef TSIMBOLOS_H
#define TSIMBOLOS_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define FLOAT "FLOTANTE"
#define INT "ENTERO"
#define STR "CADENA"
#define MAX_FILAS 1024
#define SIMBOL_FILE_NAME "symbol-table.txt"

int pos = -1;
int allPosInit[50]={-1};
int posInit=0;

typedef struct{
  char nombre[100];
  char tipoDato[15];
  char valor[50];
  char longitud[5];
}t_fila;

t_fila filas[MAX_FILAS];
int filaActual=0;


void createSymbolTableInFile();
void saveSymbolTableFile();
int findSymbol(char *nombre);
void updateTipoDatoSymbol(int pos, char *tipoDato);
void updateTipoDatoSymbolInit(char *tipoDato);
void saveSymbol(const char *nombre,
                const char *tipoDato,
                const char *valor,
                const char *longitud);
void saveSymbolCte(const char *valor);
void saveSymbolCadena(char *valor);
void saveSymbolFloat(const char *valor);


#endif