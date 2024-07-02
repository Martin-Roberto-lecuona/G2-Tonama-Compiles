#include "assembler.h"

int escribirInstruccionesEnASM(FILE *fpFinal, char *nameFile) {
  FILE *file = fopen(nameFile, "r");
  char buffer[100];
  if (file == NULL) {
    printf("Error al abrir el archivo %s", nameFile);
    return 1;
  }

  while (fgets(buffer, sizeof(buffer), file)) {
    fprintf(fpFinal, "\t%s", buffer);
  }

  fclose(file);
}

void operacion(FILE *fp, tNodoArbol *raiz) {

  if (strcmp(raiz->info, "=") == 0) {

    if (strcmp(raiz->izq->tipoDato, STR) == 0) {
      // saca parentesis
      raiz->der->info++;
      raiz->der->info[strlen(raiz->der->info) - 1] = 0;
      //
      fprintf(fp, "; Limpiar antes de copiar\n");
      fprintf(fp, "LEA DI, %s\n", raiz->izq->info);
      fprintf(fp, "MOV CX, 100\n");
      fprintf(fp, "XOR AL, AL\n");
      fprintf(fp, "REP STOSB\n");
      fprintf(fp, ";Copiar\n");
      fprintf(fp, "LEA SI, str_%s\n", raiz->der->info);
      fprintf(fp, "LEA DI, %s\n", raiz->izq->info);
      fprintf(fp, "MOV CX, %d\n", strlen(raiz->der->info) + 1);
      fprintf(fp, "REP MOVSB\n");
    } else {
      fprintf(fp, "fld %s\n", raiz->der->info);
      fprintf(fp, "fstp %s\n", raiz->izq->info);
    }

  } else {
    fprintf(fp, "fld %s\n", raiz->izq->info);
    fprintf(fp, "fld %s\n", raiz->der->info);
    fprintf(fp, "%s\n", obtenerInstruccionAritmetica(raiz->info));
    fprintf(fp, "fstp @aux%d\n", pedirAux());

    // Guardo en el arbol el dato del resultado, si uso un aux
    sprintf(raiz->info, "@aux%d", cantAux);

  }
}

int esHoja(tNodoArbol *raiz) {
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

  return strcmp(operador, "+") == 0 || strcmp(operador, "-") == 0
      || strcmp(operador, "*") == 0 || strcmp(operador, "/") == 0
      || strcmp(operador, "=") == 0;
}

char *obtenerInstruccionAritmetica(const char *operador) {
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
    listCond.tope++;
    listCond.list[listCond.tope].cantSaltos++;
    if (raiz->der->der != NULL) {
      listCond.list[listCond.tope].flagElse = 1;
    }
    if (strcmp(raiz->izq->info, "OR") == 0) {
      listCond.list[listCond.tope].flagOr = 1;
    }
  } else if (strcmp(raiz->info, "NOT") == 0) { 
    listCond.list[listCond.tope].flagNot = 1; 
  } else if (strcmp(raiz->info, "WHILE") == 0) {
    listIter.tope++;
    listIter.list[listIter.tope].cantSaltos++;
    fprintf(fp, "BeginWhile%d_%d:\n", listIter.tope,listIter.list[listIter.tope].cantSaltos);
    if (strcmp(raiz->izq->info, "OR") == 0) {
      listIter.list[listIter.tope].flagOr = 1;
    }
  }
  ///RECORRO IZQUIERDA
  recorrerArbolParaAssembler(fp, raiz->izq);

  if (strcmp(raiz->info, "if") == 0) {
    fprintf(fp, "BeginIf%d_%d:\n", listCond.tope,listCond.list[listCond.tope].cantSaltos);
  } else if (strcmp(raiz->info, "WHILE") == 0) {
    fprintf(fp, "While%d_%d:\n", listIter.tope,listIter.list[listIter.tope].cantSaltos);
  } else if (strcmp(raiz->info, "CUERPO") == 0 && listCond.tope != -1
      && listCond.list[listCond.tope].flagElse == 1) {
    fprintf(fp, "JMP EndIf%d_%d\n", listCond.tope,listCond.list[listCond.tope].cantSaltos);
    fprintf(fp, "BeginElse%d_%d:\n", listCond.tope,listCond.list[listCond.tope].cantSaltos);
  }
  ///RECORRO DERECHA
  recorrerArbolParaAssembler(fp, raiz->der);

  if (strcmp(raiz->info, "CUERPO") == 0) {
    if (listCond.tope != -1) {
      fprintf(fp, "EndIf%d_%d:\n", listCond.tope,listCond.list[listCond.tope].cantSaltos);
    }
  }
  if(strcmp(raiz->info, "CUERPOW") == 0){
    if (listIter.tope != -1) {
      fprintf(fp, "JMP BeginWhile%d_%d\n", listIter.tope,listIter.list[listIter.tope].cantSaltos);
      fprintf(fp, "EndWhile%d_%d:\n", listIter.tope,listIter.list[listIter.tope].cantSaltos);
    }
  }

  if (esHoja(raiz->izq) && esHoja(raiz->der)) {
    if (esAritmetica(raiz->info)) {
      operacion(fp, raiz);
    } else if (strcmp(raiz->info, PUT_STR) == 0) {
      fprintf(fp, "xor dx, dx   ; Limpiar DX \nxor ax, ax  ; Limpiar AX\n");
      if (strcmp(raiz->der->tipoDato, STR) == 0) {
        if (raiz->der->info[0] == '(') {
          raiz->der->info++;
          raiz->der->info[strlen(raiz->der->info) - 1] = 0;
          fprintf(fp, "displayString str_%s\n", raiz->der->info);
        } else {
          fprintf(fp, "displayString %s\n", raiz->der->info);
        }
      } else if (strcmp(raiz->der->tipoDato, INT) == 0) {
        fprintf(fp, "DisplayInteger %s\n", raiz->der->info);
      } else {
        fprintf(fp, "DisplayFloat %s,3\n", raiz->der->info);
      }
      fprintf(fp, "newLine 1\n");
    } else if (esComparacion(raiz)) {
      generarComparacion(fp, raiz);
    } else if (strcmp(raiz->info, GET_STR) == 0) {
      if (strcmp(raiz->der->tipoDato, INT) == 0) {
        fprintf(fp, "GetInteger %s\n", raiz->der->info);
      } else if (strcmp(raiz->der->tipoDato, FLOAT) == 0) {
        fprintf(fp, "GetFloat %s\n", raiz->der->info);
      } else if (strcmp(raiz->der->tipoDato, STR) == 0) {
        fprintf(fp, "getString  %s\n", raiz->der->info);
      }
    }
    free(raiz->izq);
    free(raiz->der);
    raiz->izq = NULL;
    raiz->der = NULL;
  }
  if (strcmp(raiz->info, "if") == 0) {
    listCond.list[listCond.tope].flagElse = 0;
    // listCond.list[listCond.tope].flagOr = 1;
    listCond.tope--;
  }
  if (strcmp(raiz->info, "WHILE") == 0) {
    listIter.list[listIter.tope].flagOr = 0;
    listIter.tope--;
  }
}

int esComparacion(tNodoArbol *raiz) {
  return strcmp(raiz->info, ">") == 0 || strcmp(raiz->info, ">=") == 0
      || strcmp(raiz->info, "<") == 0 || strcmp(raiz->info, "<=") == 0
      || strcmp(raiz->info, "==") == 0 || strcmp(raiz->info, "!=") == 0;
}

void generarComparacion(FILE *fp, tNodoArbol *raiz) {
  fprintf(fp, "; Comparacion\n");
  fprintf(fp, "fld %s\n", raiz->der->info);
  fprintf(fp, "fld %s\n", raiz->izq->info);
  fprintf(fp, "fcom\n");
  fprintf(fp, "fstsw ax\n");
  fprintf(fp, "sahf\n");
  fprintf(fp, "; fin Comparacion\n");

  generarSalto(fp, raiz->info);

}

void generarSalto(FILE *fp, char *comparador) {
  char *salto = obtenerInstruccionComparacion(comparador);
  char destinoSalto[50];
  if (listCond.tope != -1 && listCond.list[listCond.tope].flagOr == 1) {
    strcpy(destinoSalto, "BeginIf");
    listCond.list[listCond.tope].flagOr = 0;
  } else if (listIter.tope != -1 && listIter.list[listIter.tope].flagOr == 1) {
    strcpy(destinoSalto, "BeginWhile");
    listCond.list[listCond.tope].flagOr = 0;
  } else {
    if (listCond.tope != -1 && listCond.list[listCond.tope].flagElse == 1) {
      strcpy(destinoSalto, "BeginElse");
    } else if (listCond.tope != -1) {
      strcpy(destinoSalto, "EndIf");
    } else if (listIter.tope != -1) {
      strcpy(destinoSalto, "EndWhile");
    }
  }
  fprintf(fp, "; Salto\n");
  fprintf(fp,
          "%s %s%d_%d\n",
          salto,
          destinoSalto,
          (listCond.tope != -1) ? listCond.tope : listIter.tope,
          (listCond.tope != -1) ? listCond.list[listCond.tope].cantSaltos : listIter.list[listIter.tope].cantSaltos
          );
}

int evaluarOr() {
  if (listCond.tope != -1) {
    if (listCond.list[listCond.tope].flagNot == 1)
      return 1;
    return listCond.list[listCond.tope].flagOr;
  } else if (listIter.tope != -1) {
    return listIter.list[listIter.tope].flagOr;
  } 
  return 0;
}

char *obtenerInstruccionComparacion(const char *comparador) {
  for (int i = 0; i < sizeof(compYSalto) / sizeof(compYSalto[0]); i++) {
    if (strcmp(compYSalto[i].comparador, comparador) == 0) {
      return evaluarOr() ? compYSalto[i].operacion : compYSalto[i].invertido;
    }
  }
  return "JMP";
}

int generarInstruccionesAssembler(tNodoArbol *raiz) {
  FILE *fp = fopen(ASM_FILE_CODE, "wt+");
  if (fp == NULL) {
    printf("Error al abrir el archivo instrucciones");
    return 1;
  }
  recorrerArbolParaAssembler(fp, raiz);
  fclose(fp);
  return 0;
}

void generarAssembler(tNodoArbol *raiz) {
  FILE *fp = fopen(ASM_FILE, "w");
  if (!fp) {
    printf("Error al guardar el archivo assembler.\n");
    exit(1);
  }
  generarInstruccionesAssembler(raiz);
  char header[] =
      "include macros2.asm\ninclude number.asm\n.MODEL LARGE\n.386\n.STACK 200h\n.DATA\n\n";
  fprintf(fp, header);

  recorrerTablaSimbolos(fp);
  char iniCode[] =
      ".CODE\n\nSTART:\n\tMOV AX,@DATA\n\tMOV DS,AX\n\tMOV ES,AX\n\tFINIT\n";
  fprintf(fp, iniCode);
  // fprintf(fp, "FFREE\n\n");

  escribirInstruccionesEnASM(fp, ASM_FILE_CODE);

  char finCode[] =
      "END_PROG:\n\tffree; Liberar registros de la FPU\n\tmov ax, 4C00h\n\tint 21h\nEND START";
  fprintf(fp, finCode);
  // fprintf(fp, "\n\nffree\n");
}


//------------- Tabla simbolos ------------------------

void getFila(char line[256], t_fila *fila) {
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

void recorrerTablaSimbolos(FILE *file) {
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
    getFila(line, &fila);
    if (fila.valor[0] != '_' && strcmp(fila.tipoDato, STR) == 0) {
      fprintf(file,
              "\tstr%s db \"%s\",\"$\", %d dup(?) \n",
              fila.nombre,
              fila.valor,
              strlen(fila.valor));
    } else if (fila.valor[0] != '_') {
      fprintf(file, "\t%s dd %s\n", fila.nombre, fila.valor);
    } else if (fila.valor[0] == '_' && strcmp(fila.tipoDato, STR) == 0) {
      fprintf(file, "\t%s db 100 dup(?) \n", fila.nombre);
    } else {
      fprintf(file, "\t%s dd ?\n", fila.nombre);
    }

  }
  for (int i = 1; i <= cantAux; i++) {
    fprintf(file, "\t@aux%d dd %s\n", i, "0");
  }

  fclose(fileSimbol);
}