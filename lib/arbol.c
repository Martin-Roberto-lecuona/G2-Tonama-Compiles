#include "arbol.h"

void saveArbolFile(t_arbol *p) {
  FILE *treeFile = fopen("intermediate-code.dot", "w");
  if (treeFile == NULL) {
    perror("Error al abrir el archivo");
    exit(1);
  }
  fprintf(treeFile, "digraph programa{\n");
  recorrer(p, treeFile);
  fprintf(treeFile, "}");
  fclose(treeFile);
}


tNodoArbol *crearNodo(char *terminal,
                      t_arbol *arbol,
                      tNodoArbol *NoTerminalIzq,
                      tNodoArbol *NoTerminalDer) {
  /* printf("crearNodo\n"); */
  tNodoArbol *nodo = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  nodo->info = malloc(strlen(terminal) + 1);
  memcpy(nodo->info, terminal, strlen(terminal) + 1);
  nodo->der = NoTerminalDer;
  nodo->izq = NoTerminalIzq;
  *arbol = nodo;
  nodo->uniqueId = uniqueIdMain;
  /* printf("FIN crearNodo\n"); */
  return nodo;
}

void recorrer(t_arbol *p, FILE *treeFile) {
  if (!*p) {
    return;
  }
  recorrer(&(*p)->izq, treeFile);
  mostrarRelacion(p, treeFile);
  recorrer(&(*p)->der, treeFile);
}


tNodoArbol *crearHoja(char *terminal) {
  /* printf("crearHoja new: %s \n", terminal); */
  tNodoArbol *nuevo = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  nuevo->info = malloc(strlen(terminal) + 1);
  memcpy(nuevo->info, terminal, strlen(terminal) + 1);
  nuevo->der = NULL;
  nuevo->izq = NULL;
  nuevo->uniqueId = uniqueIdMain;
  /* printf("FIN crearHoja\n"); */
  return nuevo;
}

void crearArbol(t_arbol *pa) {
  *pa = NULL;
}

void mostrarRelacion(t_arbol *p, FILE *treeFile) {

  if ((*p)->izq) {
    fprintf(treeFile, "\"%s_%d\" -> \"%s_%d\";\n",
            (*p)->info,
            (*p)->uniqueId,
            (*p)->izq->info,
            (*p)->izq->uniqueId);
  }
  if ((*p)->der) {
    fprintf(treeFile, "\"%s_%d\" -> \"%s_%d\";\n",
            (*p)->info,
            (*p)->uniqueId,
            (*p)->der->info,
            (*p)->der->uniqueId);
  }
}

int apilarDinamica(t_pila *PP, tNodoArbol* pd)
{
  t_nodo *pnue= (t_nodo *)malloc(sizeof(t_nodo));
  if(!pnue)
    return 0;

  pnue->dato = pd;
  pnue->psig = *PP;
  *PP=pnue;
  return 1;

}

tNodoArbol * desapilarDinamica(t_pila *pp)
{
  t_nodo *aux;

  if(*pp==NULL)
    return 0;

  aux = *pp;
  tNodoArbol * pd = aux->dato; //== (*pp)->dato
  *pp = aux->psig;
  free(aux);
  return pd;
}

tNodoArbol *asignarHijosNodo(tNodoArbol *Padre,
                      t_arbol *arbol,
                      tNodoArbol *NoTerminalIzq,
                      tNodoArbol *NoTerminalDer) {

  Padre->der = NoTerminalDer;
  Padre->izq = NoTerminalIzq;
  /* printf("FIN crearNodo\n"); */
  return Padre;
}

tNodoArbol *aplicarDescuentoItem(char *item){
  tNodoArbol *auxDecPtr = crearNodo("-", &arbol, crearHoja("@aux"), crearHoja("1"));
  uniqueIdMain++;
  tNodoArbol *itemSubstractPtr = crearNodo("-", &arbol, crearHoja(item), crearHoja("@mon"));
  uniqueIdMain++;
  tNodoArbol *auxIgual = crearNodo("=", &arbol, crearHoja("@res"), itemSubstractPtr);
  uniqueIdMain++;
  tNodoArbol *sPtr = crearNodo("S", &arbol, auxIgual, crearNodo("=", &arbol, crearHoja("@aux"),auxDecPtr));
  uniqueIdMain++;
  tNodoArbol *elsePtr = crearNodo("=", &arbol, crearHoja("@res"), crearNodo("/", &arbol, crearNodo("*", &arbol, crearHoja(item), crearHoja("@mon")), crearHoja("100")));
  elsePtr = crearNodo("else", &arbol, elsePtr, NULL );
  uniqueIdMain++;
  tNodoArbol *cuerpoPtr = crearNodo("CUERPO", &arbol, sPtr,elsePtr);
  return crearNodo("IF", &arbol, crearNodo(">", &arbol, crearHoja("@aux"), crearHoja("0")), cuerpoPtr);
}



/****************************************************************************************************/
/*
  BASADO EN EL SIGUIENTE CODIGO C 
        int byr (char b[], char cad[],char r[] ){
          char temp[1000];

          int i, j, k, lenB, lenR, lenCad;

          lenB = strlen(b);
          lenR = strlen(r);
          lenCad = strlen(cad);

          i = j = k = 0;

          while (i < lenCad) {
              if (strncmp(cad + i, b, lenB) == 0) {
                  j=0;
                  while (j < lenR){
                      temp[k] = r[j];
                      j++;
                      k++;
                  }
                  i += lenB;
              } else {
                  temp[k] = cad[i];
                  k++;
                  i++;
              }
          }

          temp[k] = '\0';

          strcpy(cad, temp);
          return 1;
      }

*/
tNodoArbol *buscarYReemplazar(char *bus,char *cad,char *rem){
  tNodoArbol *aux;

  tNodoArbol *inicial = crearHoja("S");

  tNodoArbol *buscar =  crearNodo("=",&arbol,crearHoja("@bus"),crearHoja(bus));
  uniqueIdMain++;
  tNodoArbol *cadena =  crearNodo("=",&arbol,crearHoja("@cad"),crearHoja(cad));
  uniqueIdMain++;
  asignarHijosNodo(inicial,&arbol,buscar,cadena);

  tNodoArbol *reempl =  crearNodo("=",&arbol,crearHoja("@rem"),crearHoja(rem));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,reempl);

  tNodoArbol *lenBus = crearNodo("=", &arbol, crearHoja("@lenBus"), crearNodo("strlen",&arbol,crearHoja("@bus"),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenBus);

  tNodoArbol *lenRem = crearNodo("=", &arbol, crearHoja("@lenRem"), crearNodo("strlen",&arbol,crearHoja("@rem"),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenRem);


  tNodoArbol *lenCad = crearNodo("=", &arbol, crearHoja("@lenCad"), crearNodo("strlen",&arbol,crearHoja("@cad"),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenCad);

  tNodoArbol *i      = crearNodo("=", &arbol, crearHoja("@i"), crearHoja("0"));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,i);

  tNodoArbol *j      = crearNodo("=", &arbol, crearHoja("@j"), crearHoja("0"));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,j);

  tNodoArbol *k      = crearNodo("=", &arbol, crearHoja("@k"), crearHoja("0"));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,k);

  tNodoArbol *temp   = crearHoja("@temp[1000]");
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,temp);
  uniqueIdMain++;


  tNodoArbol *param1 = crearNodo("+", &arbol, crearHoja("@cad"), crearHoja("@i"));
  tNodoArbol *param2 = crearHoja("@bus");
  tNodoArbol *param3 = crearHoja("@lenBus");
  tNodoArbol *allParam = crearNodo("S", &arbol, param1,param2 );
  uniqueIdMain++;
  allParam = crearNodo("S", &arbol, allParam, param3);

  tNodoArbol *strncmp_nodo = crearNodo("strncmp", &arbol, allParam, NULL);
  uniqueIdMain++;
  
  tNodoArbol *condicionIf = crearNodo("==", &arbol, strncmp_nodo, crearHoja("0"));
  uniqueIdMain++;

  tNodoArbol *cuerpoIf = crearNodo("=", &arbol, crearHoja("@j"), crearHoja("0"));
  uniqueIdMain++;
  
  
  tNodoArbol * cuerpoMientrasInterno = crearNodo("=",&arbol, crearHoja("@temp[k]"), crearHoja("@rem[j]"));
  uniqueIdMain++;

  aux = crearHoja("@j");
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("S",&arbol, cuerpoMientrasInterno,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@j"),crearHoja("1"))
                                            )
                                  );
  uniqueIdMain++;
  aux = crearHoja("@k");
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("S",&arbol, cuerpoMientrasInterno,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@k"),crearHoja("1"))
                                            )
                                  );
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("CUERPO", &arbol,cuerpoMientrasInterno,NULL);
  tNodoArbol *mientrasInterno = crearNodo("WHILE",&arbol, 
                                          crearNodo("<", &arbol, crearHoja("@j"), crearHoja("@lenRes")), 
                                          cuerpoMientrasInterno);
  uniqueIdMain++;
  
  cuerpoIf = crearNodo("S", &arbol ,cuerpoIf,mientrasInterno);
  uniqueIdMain++;

  aux = crearHoja("@i");
  uniqueIdMain++;
  cuerpoIf = crearNodo("S", &arbol ,cuerpoIf,
                      crearNodo("=",&arbol, aux, 
                                crearNodo("+",&arbol, crearHoja("@i"),crearHoja("@lenBus"))
                              ) 
                      );
  uniqueIdMain++;

  tNodoArbol* cuerpoElse = crearNodo("=",&arbol, crearHoja("@temp[k]"), crearHoja("@cad[j]"));
  uniqueIdMain++;
  aux = crearHoja("@k");
  uniqueIdMain++;
  cuerpoElse = crearNodo("S",&arbol, cuerpoElse,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@k"),crearHoja("1"))
                                            )
                                  );
  uniqueIdMain++;

  aux = crearHoja("@i");
  uniqueIdMain++;
  cuerpoElse = crearNodo("S",&arbol, cuerpoElse,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@i"),crearHoja("1"))
                                            )
                                  );
  uniqueIdMain++;
  cuerpoElse = crearNodo("ELSE",&arbol, cuerpoElse, NULL);
  cuerpoIf = crearNodo("CUERPO",&arbol, cuerpoIf, cuerpoElse);
  tNodoArbol *si = crearNodo("IF",&arbol, condicionIf, cuerpoIf);
  uniqueIdMain++;

  tNodoArbol *cuerpoMientras = crearNodo("CUERPO",&arbol, si, NULL);
  uniqueIdMain++;

  tNodoArbol *mientras = crearNodo("WHILE", &arbol, 
                                  crearNodo("<", &arbol, crearHoja("@i"), crearHoja("@lenCad"))
                                  , cuerpoMientras);

  tNodoArbol *final = crearNodo("=",&arbol, crearHoja("@temp[k]"), crearHoja("0"));
  uniqueIdMain++;
  final = crearNodo("S",&arbol, final,
                   crearNodo("strcpy",&arbol, crearHoja("@cad"), crearHoja("@temp"))
                   ); 
  uniqueIdMain++;
  tNodoArbol *funcion = crearNodo("S",&arbol, inicial, mientras);
  uniqueIdMain++;
  funcion = crearNodo("S",&arbol, funcion, final);

  return funcion;
}