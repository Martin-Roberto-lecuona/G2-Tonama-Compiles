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
    }*/

    if ( strcmp( raiz->izq->tipoDato, STR) == 0){
      // saca parentesis
        raiz->der->info++;
        raiz->der->info[strlen(raiz->der->info)-1]=0;
      //
    //   ; Limpiar c antes de copiar "chau"
    // LEA DI, c
    // MOV CX, 100
    // XOR AL, AL
    // REP STOSB
      fprintf(fp,"; Limpiar antes de copiar\n");
      fprintf(fp,"LEA DI, %s\n",raiz->izq->info);
      fprintf(fp,"MOV CX, 100\n");
      fprintf(fp,"XOR AL, AL\n");
      fprintf(fp,"REP STOSB\n");
      fprintf(fp,";Copiar\n");
      fprintf(fp,"LEA SI, str_%s\n",raiz->der->info);
      fprintf(fp,"LEA DI, %s\n",raiz->izq->info);
      fprintf(fp,"MOV CX, %d\n",strlen(raiz->der->info)+1);
      fprintf(fp,"REP MOVSB\n");
      // hacer que funcione esto de asignar str
    }else{
      fprintf(fp, "fld %s\n", raiz->der->info);
      fprintf(fp, "fistp %s\n", raiz->izq->info);
    }
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
  }else if(strcmp(raiz->info, "else") == 0){
      elseCounter++;
  }
  recorrerArbolParaAssembler(fp, raiz->izq);

  if (strcmp(raiz->info, "if") == 0) {
    fprintf(fp, "BeginIf%d:\n", ifCounter);
  }
  else if (strcmp(raiz->info, "else") == 0) {
    fprintf(fp, "JMP EndIf%d\n", ifCounter+1);
    fprintf(fp, "EndIf%d:\n", ifCounter);
    ifCounter++;
  }

  recorrerArbolParaAssembler(fp, raiz->der);

  if (strcmp(raiz->info, "else") == 0) {
    fprintf(fp, "EndIf%d:\n", ifCounter);
    elseCounter++;
  }
  printf("elseCounter = %d\n",elseCounter);
  if (esHoja(raiz->izq) && esHoja(raiz->der)) {
    if (esAritmetica(raiz->info)) {
      operacion(fp, raiz);
    } else if (strcmp(raiz->info, PUT_STR) == 0) {
      fprintf(fp,"xor dx, dx   ; Limpiar DX \nxor ax, ax  ; Limpiar AX\n");
      if(raiz->der->info[0] == '('){
        raiz->der->info++;
        raiz->der->info[strlen(raiz->der->info)-1]=0;
        fprintf(fp, "displayString str_%s\n", raiz->der->info);
      }
      else{
        fprintf(fp, "displayString %s\n", raiz->der->info);
      }
      fprintf(fp, "newLine 1\n");
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
  fprintf(fp, "; Comparacion\n");
  fprintf(fp, "MOV AH, 0\n");
  fprintf(fp, "sahf\n");
  fprintf(fp, "fld %s\n", raiz->izq->info);
  fprintf(fp, "fld %s\n", raiz->der->info);
  fprintf(fp, "fcomp\n");
  fprintf(fp, "fstsw ax\n");
  fprintf(fp, "sahf\n");
  // fprintf(fp, "and ah, 45h  ; Mantener solo los bits relevantes\n");
  fprintf(fp, "; fin Comparacion\n");

  generarSalto(fp, raiz->info);

}

void generarSalto(FILE *fp, char *comparador) {
  char *salto = obtenerInstruccionComparacion(comparador);
  char destinoSalto[50];
  if (flagOR) {
    strcpy(destinoSalto,"BeginIf");
    flagOR = 0;
  } 
  printf("elseCounter = %d",elseCounter);
  if(elseCounter >= 1) {
    elseCounter--;
    strcpy(destinoSalto,"BeginElse");
  }
  else {
    strcpy(destinoSalto,"EndIf");
  }
  fprintf(fp, "; Salto\n");
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

  char finCode[]="END_PROG:\n\tffree; Liberar registros de la FPU\n\tmov ax, 4C00h\n\tint 21h\nEND START";
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
  fila->valor[strcspn(fila->nombre, " ")] = '\0';
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
      fprintf(file,"\tstr%s db \"%s\",\"$\", %d dup(?) \n", fila.nombre,fila.valor,strlen(fila.valor) );
    }
    else if(strcmp(fila.valor, "_") != 0){
      fprintf(file,"\t%s dd %s\n", fila.nombre,fila.valor);
    }
    else if (strcmp(fila.tipoDato, STR) == 0){
      fprintf(file,"\t%s db 100 dup(?) \n", fila.nombre );
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