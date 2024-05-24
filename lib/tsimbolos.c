#include "tsimbolos.h"

void createSymbolTableInFile() {
  FILE *file = fopen("symbol-table.txt", "w");
  if (file == NULL) {
    perror("Error al abrir el archivo");
    exit(1);
  }
  fprintf(file, "Error de compilacion");
  fclose(file);
}

void saveSymbolTableFile() {

  FILE *file = fopen("symbol-table.txt", "w+");
  if (file == NULL) {
    perror("Error al abrir el archivo");
    exit(1);
  }
  fprintf(file,
          "%-50s|%-30s|%-30s|%-30s\n",
          "NOMBRE",
          "TIPODATO",
          "VALOR",
          "LONGITUD");
  fprintf(file,
          "-------------------------------------------------------------------------------------------------------------------------\n");

  for (int i = 0; i < sizeof(filas) / sizeof(filas[0]); i++) {
    if (strlen(filas[i].nombre) == 0)
      break;
    fprintf(file,
            "%-49s|%-30s|%-30s|%-30s\n",
            filas[i].nombre,
            filas[i].tipoDato,
            filas[i].valor,
            filas[i].longitud);
  }
  fclose(file);
}

int findSymbol(char *nombre) {
  int pos = 0, i = 0, tam = sizeof(filas) / sizeof(filas[0]);
  while (strcmp(filas[i].nombre, nombre) != 0 && i < tam) {
    i++;
    pos = i;
  }
  return i >= tam ? -1 : pos;
}

void updateTipoDatoSymbol(int pos, char *tipoDato) {
  if (pos == -1)
    return;
  if (strlen(filas[pos].tipoDato) != 0
      && strcmp(filas[pos].tipoDato, tipoDato) != 0) {
    printf("\nError semantico: El símbolo %s. Se esperaba %s no un %s \n",
           filas[pos].nombre,
           filas[pos].tipoDato,
           tipoDato);
    exit(-1);
  } else
    strcpy(filas[pos].tipoDato, tipoDato);
}

void updateTipoDatoSymbolInit(char *tipoDato) {
  char tipoAux[10];

  if (strcmp("Int", tipoDato) == 0)
    strcpy(tipoAux, INT);
  else if (strcmp("Float", tipoDato) == 0)
    strcpy(tipoAux, FLOAT);
  else if (strcmp("String", tipoDato) == 0)
    strcpy(tipoAux, STR);

  for (int i = 0; i < posInit; i++) {
    updateTipoDatoSymbol(allPosInit[i], tipoAux);
    allPosInit[i] = -1;
  }
}

void saveSymbol(const char *nombre,
                const char *tipoDato,
                const char *valor,
                const char *longitud) {

  strcpy(filas[filaActual].nombre, nombre);
  strcpy(filas[filaActual].tipoDato, tipoDato);
  strcpy(filas[filaActual].valor, valor);
  strcpy(filas[filaActual].longitud, longitud);
  filaActual++;
}

void saveSymbolCte(const char *valor) {
  char symbol[100];
  strcpy(symbol, "_");
  strcat(symbol, valor);
  saveSymbol(symbol, "ENTERO", valor, "");
}

void saveSymbolFloat(const char *valor) {
  char symbol[100];
  strcpy(symbol, "_");
  strcat(symbol, valor);
  saveSymbol(symbol, "FLOTANTE", valor, "");
}

void saveSymbolCadena(const char *valor) {
  char symbol[100];
  strcpy(symbol, "_");
  strcat(symbol, valor);
  char largo[10];
  sprintf(largo, "%d", strlen(valor));
  saveSymbol(symbol, "CADENA", valor, largo);
}