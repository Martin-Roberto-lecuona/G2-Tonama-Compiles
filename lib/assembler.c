#include "assembler.h"

int escribirInstruccionesEnASM(FILE* fpFinal, char * nameFile){
  FILE * file = fopen( nameFile, "r");
  char buffer[100];
  if (file == NULL) {
    printf("Error al abrir el archivo %s", nameFile);
    return 1;
  }

  while(fgets(buffer, sizeof(buffer), file)) {
    fprintf(fpFinal, "\t%s", buffer);
  }

  fclose(file);
}

void operacion(FILE * fp, tNodoArbol* raiz){

  printf("info arbol: %s\n",raiz->info);
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
   /// falta saber como asignar strings
    fprintf(fp, "fld %s\n", raiz->der->info);
    fprintf(fp, "fistp %s\n", raiz->izq->info);
  } else{
    fprintf(fp, "fld %s\n", raiz->izq->info);
    fprintf(fp, "fld %s\n", raiz->der->info);
    fprintf(fp, "%s\n", obtenerInstruccionAritmetica(raiz->info));
    fprintf(fp, "fstp @aux%d\n", pedirAux());

    // Guardo en el arbol el dato del resultado, si uso un aux
    sprintf(raiz->info, "@aux%d", cantAux);

  }
}

int esHoja(tNodoArbol* raiz) {
  if (raiz == NULL) {
    return 0;
  }
  return raiz->izq == NULL && raiz->der == NULL;
}

int pedirAux() {
  cantAux++;
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

void recorrerArbolParaAssembler(FILE *fp, tNodoArbol *raiz) {
  if (raiz == NULL)
    return;

  if (strcmp(raiz->info, "if") == 0) {
    ifCounter++;
  } else if (strcmp(raiz->info, "OR") == 0) {
    flagOR = 1;
  }
  recorrerArbolParaAssembler(fp, raiz->izq);

  if (strcmp(raiz->info, "if") == 0) {
    fprintf(fp, "BeginIf%d\n", ifCounter);
  }

  recorrerArbolParaAssembler(fp, raiz->der);

  if (strcmp(raiz->info, "if") == 0) {
    fprintf(fp, "EndIf%d\n", ifCounter);
  }
  if (esHoja(raiz->izq) && esHoja(raiz->der)) {
    if (esAritmetica(raiz->info)) {
      operacion(fp, raiz);
    } else if (strcmp(raiz->info, PUT_STR) == 0) {
      char info[strlen(raiz->der->info) + 1];
      strcpy(info, raiz->der->info);
      info[0] = ' ';
      info[strlen(raiz->der->info) - 1] = 0;
      fprintf(fp, "mov dx,OFFSET str_%s\n", info + 1);
      fprintf(fp, "mov ah,9\nint 21h\nnewLine 1\n");
    } else if (esComparacion(raiz)) {
      generarComparacion(fp, raiz);
    }
    free(raiz->izq);
    free(raiz->der);
    raiz->izq = NULL;
    raiz->der = NULL;
  }

}

int esComparacion(tNodoArbol* raiz){
  return strcmp(raiz->info, ">") == 0 ||
      strcmp(raiz->info, ">=") == 0 ||
      strcmp(raiz->info, "<") == 0 ||
      strcmp(raiz->info, "<=") == 0 ||
      strcmp(raiz->info, "==") == 0 ||
      strcmp(raiz->info, "<>") == 0;
}

void generarComparacion(FILE * fp, tNodoArbol* raiz){
  fprintf(fp, "fsld %s\n", raiz->der->info);
  fprintf(fp, "fsld %s\n", raiz->izq->info);
  fprintf(fp, "fcom\n");
  fprintf(fp, "fstsw ax\n");
  fprintf(fp, "sahf\n");
  generarSalto(fp, raiz->info);

}

void generarSalto(FILE *fp, char *comparador) {
  char *salto = obtenerInstruccionComparacion(comparador);
  char *destinoSalto;
  if (flagOR) {
    destinoSalto = "BeginIf";
    flagOR = 0;
  } else {
    destinoSalto = "EndIf";
  }
  fprintf(fp, "%s %s%d\n", salto, destinoSalto, ifCounter);
}


char* obtenerInstruccionComparacion(const char *comparador) {

  if(flagOR) {
    if (strcmp(comparador, ">") == 0)
      return "JNBE";
    if (strcmp(comparador, ">=") == 0)
      return "JNB";
    if (strcmp(comparador, "<") == 0)
      return "JNAE";
    if (strcmp(comparador, "<=") == 0)
      return "JNA";
    if (strcmp(comparador, "==") == 0)
      return "JE";
    if (strcmp(comparador, "<>") == 0)
      return "JNE";
  } else {
    if (strcmp(comparador, ">") == 0)
      return "JNA";
    if (strcmp(comparador, ">=") == 0)
      return "JNAE";
    if (strcmp(comparador, "<") == 0)
      return "JNB";
    if (strcmp(comparador, "<=") == 0)
      return "JNBE";
    if (strcmp(comparador, "==") == 0)
      return "JNE";
    if (strcmp(comparador, "<>") == 0)
      return "JE";
  }
}

int generarInstruccionesAssembler(tNodoArbol* raiz){
  FILE * fp = fopen(ASM_FILE_CODE, "wt+");
  if (fp == NULL) {
    printf("Error al abrir el archivo instrucciones");
    return 1;
  }
  recorrerArbolParaAssembler(fp, raiz);
  fclose(fp);
  return 0;
}

void generarAssembler(tNodoArbol* raiz){
  FILE *fp = fopen(ASM_FILE, "w");
  if(!fp)
  {
    printf("Error al guardar el archivo assembler.\n");
    exit(1);
  }
  generarInstruccionesAssembler(raiz);
  char header[]="include macros2.asm\ninclude number.asm\n.MODEL LARGE\n.386\n.STACK 200h\n.DATA\n\n";
  fprintf(fp,header);

  recorrerTablaSimbolos(fp);
  char iniCode[]=".CODE\n\nSTART:\n\tMOV AX,@DATA\n\tMOV DS,AX\n\tMOV ES,AX\n\tFINIT\n";
  fprintf(fp, iniCode);
  // fprintf(fp, "FFREE\n\n");

  escribirInstruccionesEnASM(fp, ASM_FILE_CODE);

  char finCode[]="END_PROG:\n\tmov ax, 4C00h\n\tint 21h\nEND START";
  fprintf(fp,finCode);
  // fprintf(fp, "\n\nffree\n");
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
    if(strcmp(fila.valor, "_") != 0 && strcmp(fila.tipoDato, STR) == 0){
        fprintf(file,"\tstr_%s db \"%s\",\"$\", %d dup(?) \n", fila.valor,fila.valor,strlen(fila.valor) );
    }
    else {
       fprintf(file,"\t%s dd ?\n", fila.nombre);
    }
    
  }
  for(int i=1; i <= cantAux; i++){
    fprintf(file,"\t@aux%d dd %s\n", i, "0");
  }

  fclose(fileSimbol);
}