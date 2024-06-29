#include "tsimbolos.h"

void createSymbolTableInFile() {
  FILE *file = fopen(SIMBOL_FILE_NAME, "w");
  if (file == NULL) {
    perror("Error al abrir el archivo");
    exit(1);
  }
  fprintf(file, "Error de compilacion");
  fclose(file);
}

void saveSymbolTableFile() {

  FILE *file = fopen(SIMBOL_FILE_NAME, "w+");
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
  fprintf(file,"%-49s|%-30s|%-30s|%-30s\n","@aux",INT,"0","" );
  fprintf(file,"%-49s|%-30s|%-30s|%-30s\n","@res",FLOAT,"0","" );

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
  int pos = 0, 
      i = 0, 
      tam = sizeof(filas) / sizeof(filas[0]);
  
  while (strcmp(filas[i].nombre, nombre) != 0 && i < tam) {
    int index = strcspn(filas[i].nombre,"_");
    if(index == 0 && strcmp(filas[i].nombre+1, nombre) == 0)
      break;

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
  char real_val[100];
  strcpy(real_val, valor+1);
  saveSymbol(valor, "ENTERO", real_val, "");
}

void saveSymbolFloat(const char *valor) {
  char val[strlen(valor)];

  char real_val[100];
  strcpy(real_val, valor+1);

  strcpy(val, real_val);
  char *punto = strchr(val, '@');
  if (punto != NULL) {
    *punto = '.'; // Reemplazar el @ por .
  }
  saveSymbol(valor, "FLOTANTE", val, "");
}

void saveSymbolCadena(char *valor) {
  char symbol[100];
  strcpy(symbol, "_");
  strcat(symbol, valor);

  int i=0;
  while (symbol[i]){
    if (symbol[i]==' ') 
        symbol[i]='_';
    i++;
  }

  char largo[10];
  sprintf(largo, "%d", strlen(valor));
  saveSymbol(symbol, "CADENA", valor, largo);
}