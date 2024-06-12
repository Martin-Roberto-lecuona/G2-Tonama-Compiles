#include "assembler.h"

int escribirInstruccionesEnASM(FILE* fpFinal, char * nameFile){
  FILE * file = fopen( nameFile, "r");
  char buffer[100];
  if (file == NULL) {
    printf("Error al abrir el archivo %s", nameFile);
    return 1;
  }

  while(fgets(buffer, sizeof(buffer), file)) {
    fprintf(fpFinal, "%s", buffer);
  }

  fclose(file);
}

void operacion(FILE * fp, tNodoArbol* raiz){

  printf("info arbol: %s\n",raiz->info);
  if(esAritmetica(raiz->info)){
    if(strcmp(raiz->info, "=")==0){
/*
      if(strcmp(raiz->tipo, "Cte_String")==0){
        asignacionString = 1;
        fprintf(fp, "MOV si, OFFSET   %s\n", raiz->hijoDer);
        fprintf(fp, "MOV di, OFFSET  %s\n", raiz->hijoIzq);
        fprintf(fp, "CALL asignString\n");
      }else{

        fprintf(fp, "f%sld %s\n", cargaEntero(raiz->hijoDer), raiz->hijoDer->dato);
        fprintf(fp, "f%sstp %s\n", cargaEntero(raiz->hijoIzq), raiz->hijoIzq->dato);
      }*/
      fprintf(fp, "fld %s\n", raiz->der->info);
      fprintf(fp, "fistp %s\n", raiz->izq->info);
    } else{
      fprintf(fp, "fld %s\n", raiz->izq->info);
      fprintf(fp, "fld %s\n", raiz->der->info);
      fprintf(fp, "%s\n", obtenerInstruccionAritmetica(raiz->info));
      fprintf(fp, "fstp @aux%d\n", pedirAux(raiz->info));

      // Guardo en el arbol el dato del resultado, si uso un aux
      sprintf(raiz->info, "@aux%d", cantAux);

    }
  }
}

int esHoja(tNodoArbol* raiz) {
  if (raiz == NULL) {
    return 0;
  }
  return raiz->izq == NULL && raiz->der == NULL;
}

int pedirAux(char* tipo) {
  cantAux++;
  /*
  char aux[15];
  sprintf(aux, "@aux%d", cantAux);
  armarTS(tipo, aux);
  */
  return cantAux;
}

int esAritmetica(const char *operador) {

  return strcmp(operador, "+") == 0 ||
      strcmp(operador, "-") == 0 ||
      strcmp(operador, "*") == 0 ||
      strcmp(operador, "/") == 0 ||
      strcmp(operador, "=") == 0;
}

char* obtenerInstruccionAritmetica(const char *operador) {
  if (strcmp(operador, "+") == 0)
    return "fadd";
  if (strcmp(operador, "-") == 0)
    return "fsub";
  if (strcmp(operador, "*") == 0)
    return "fmul";
  if (strcmp(operador, "/") == 0)
    return "fdiv";
}

void  recorrerArbolParaAssembler(FILE * fp, tNodoArbol* raiz){
  if(raiz == NULL)
    return;
  recorrerArbolParaAssembler(fp, raiz->izq);
  recorrerArbolParaAssembler(fp, raiz->der);

  if(esHoja(raiz->izq) && esHoja(raiz->der)){
    operacion(fp, raiz);

    free(raiz->izq);
    free(raiz->der);
    raiz->izq = NULL;
    raiz->der = NULL;
  }

}

int generarInstruccionesAssembler(tNodoArbol* raiz){
  FILE * fp = fopen("instruccionesAssembler.txt", "wt+");
  if (fp == NULL) {
    printf("Error al abrir el archivo instrucciones");
    return 1;
  }
  recorrerArbolParaAssembler(fp, raiz->izq);
  fclose(fp);
  return 0;
}

void generarAssembler(tNodoArbol* raiz){
  FILE *fp = fopen("Final.asm", "w");
  if(!fp)
  {
    printf("Error al guardar el archivo assembler.\n");
    exit(1);
  }
  generarInstruccionesAssembler(raiz);

  fprintf(fp,"include macros2.asm\n");
  fprintf(fp,"include number.asm\n\n");
  fprintf(fp,".MODEL LARGE\n");
  fprintf(fp,".386\n");
  fprintf(fp,".STACK 200h\n");
  //fprintf(fp,"MAXTEXTSIZE equ 100\n");
  fprintf(fp,".DATA\n\n");

  recorrerTablaSimbolos(fp);

  fprintf(fp,"\n\n.CODE\n");
  fprintf(fp, "MOV DS,AX\n");
  fprintf(fp, "MOV es,ax\n");
  fprintf(fp, "FINIT\n");
  fprintf(fp, "FFREE\n\n");


  escribirInstruccionesEnASM(fp, "instruccionesAssembler.txt");

  fprintf(fp, "\n\nffree\n");
  fprintf(fp,"mov ax, 4c00h\n");
  fprintf(fp,"int 21h\n");
  fprintf(fp,"end");
}


//------------- Tabla simbolos ------------------------

void getFila(char line[256], t_fila *fila){
  line[strcspn(line, "\n")] = 0;

  char *token = strtok(line, "|");
  if (token != NULL) strncpy(fila->nombre, token, sizeof(fila->nombre));

  token = strtok(NULL, "|");
  if (token != NULL) strncpy(fila->tipoDato, token, sizeof(fila->tipoDato));

  token = strtok(NULL, "|");
  if (token != NULL) strncpy(fila->valor, token, sizeof(fila->valor));

  token = strtok(NULL, "|");
  if (token != NULL) strncpy(fila->longitud, token, sizeof(fila->longitud));

  fila->nombre[strcspn(fila->nombre, " ")] = '\0';
  fila->tipoDato[strcspn(fila->tipoDato, " ")] = '\0';
  fila->valor[strcspn(fila->valor, " ")] = '\0';
  fila->longitud[strcspn(fila->longitud, " ")] = '\0';
}

void recorrerTablaSimbolos(FILE *file){
  FILE *fileSimbol = fopen(SIMBOL_FILE_NAME, "r");
  fseek(fileSimbol, 0, SEEK_SET);
  if (fileSimbol == NULL) {
    perror("Error al abrir el archivo");
    exit(1);
  }
  t_fila fila;
  char line[256];

  // Saltar las primeras dos líneas (encabezado y separador)
  fgets(line, sizeof(line), fileSimbol);
  fgets(line, sizeof(line), fileSimbol);
  while (fgets(line, sizeof(line), fileSimbol)) {
    getFila(line,&fila);
    if(strcmp(fila.valor, "_") == 0 )
      fprintf(file,"%s dd ?\n", fila.nombre);
    else
      fprintf(file,"%s dd %s\n", fila.nombre,fila.valor);
  }
  for(int i=1; i <= cantAux; i++){
    fprintf(file,"@aux%d dd %s\n", i, "0");
  }

  fclose(fileSimbol);
}