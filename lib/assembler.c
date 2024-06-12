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
  fprintf(fp,"include macros2.asm\n");
  fprintf(fp,"include number.asm\n\n");
  fprintf(fp,".MODEL LARGE\n");
  fprintf(fp,".386\n");
  fprintf(fp,".STACK 200h\n");
  //fprintf(fp,"MAXTEXTSIZE equ 100\n");
  fprintf(fp,".DATA\n\n");


  fprintf(fp,".CODE\n");
  fprintf(fp, "MOV DS,AX\n");
  fprintf(fp, "MOV es,ax\n");
  fprintf(fp, "FINIT\n");
  fprintf(fp, "FFREE\n\n");

  generarInstruccionesAssembler(raiz);
  escribirInstruccionesEnASM(fp, "instruccionesAssembler.txt");

  fprintf(fp, "\n\nffree\n");
  fprintf(fp,"mov ax, 4c00h\n");
  fprintf(fp,"int 21h\n");
  fprintf(fp,"end");


}
