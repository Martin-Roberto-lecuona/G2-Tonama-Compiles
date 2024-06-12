#include "assembler.h"

void operacion(FILE * fp, tNodoArbol* raiz){

  printf("info arbol: %s",raiz->info);
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
      //sprintf(raiz->dato, "@aux%d", cantAux);

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
  fprintf(fp,".MODEL LARGE\n.386\n.STACK 200h\n\nMAXTEXTSIZE equ 100\n\n.DATA\n\n");

  generarInstruccionesAssembler(raiz);
}
