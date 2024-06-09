#include "assembler.h"

int generarInstrucciones(tNodoArbol* raiz){
  FILE * fp = fopen("instruccionesAssembler.txt", "wt+");
  if (fp == NULL) {
    printf("Error al abrir el archivo instrucciones");
    return 1;
  }
  //recorrerArbolParaAssembler(fp, raiz);
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

  generarInstrucciones(raiz);
}
