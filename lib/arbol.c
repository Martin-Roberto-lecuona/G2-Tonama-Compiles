#include "arbol.h"
#include "tsimbolos.h"

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


tNodoArbol *crearHoja(char *terminal,char* tipoDato) {
  /* printf("crearHoja new: %s \n", terminal); */
  tNodoArbol *nuevo = (tNodoArbol *) malloc(sizeof(tNodoArbol));
  nuevo->info = malloc(strlen(terminal) + 1);
  memcpy(nuevo->info, terminal, strlen(terminal) + 1);
  nuevo->der = NULL;
  nuevo->izq = NULL;
  nuevo->uniqueId = uniqueIdMain;
  nuevo->tipoDato = malloc(strlen(tipoDato) + 1);
  memcpy(nuevo->tipoDato, tipoDato, strlen(tipoDato) + 1); 
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
  tNodoArbol *auxDecPtr = crearNodo("-", &arbol, crearHoja("@aux",INT), crearHoja("1",INT));
  uniqueIdMain++;
  tNodoArbol *itemSubstractPtr = crearNodo("-", &arbol, crearHoja(item,FLOAT), crearHoja("@mon",FLOAT));
  uniqueIdMain++;
  tNodoArbol *auxIgual = crearNodo("=", &arbol, crearHoja("@res",FLOAT), itemSubstractPtr);
  uniqueIdMain++;
  tNodoArbol *sPtr = crearNodo("S", &arbol, auxIgual, crearNodo("=", &arbol, crearHoja("@aux",FLOAT),auxDecPtr));
  uniqueIdMain++;
  tNodoArbol *elsePtr = crearNodo("=", &arbol, crearHoja("@res",FLOAT), crearNodo("/", &arbol, crearNodo("*", &arbol, crearHoja(item,FLOAT), crearHoja("@mon",FLOAT)), crearHoja("100",FLOAT)));
  elsePtr = crearNodo("else", &arbol, elsePtr, NULL );
  uniqueIdMain++;
  tNodoArbol *cuerpoPtr = crearNodo("CUERPO", &arbol, sPtr,elsePtr);
  return crearNodo("IF", &arbol, crearNodo(">", &arbol, crearHoja("@aux",FLOAT), crearHoja("0",FLOAT)), cuerpoPtr);
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

  tNodoArbol *inicial = crearHoja("S",NULL);

  tNodoArbol *buscar =  crearNodo("=",&arbol,crearHoja("@bus",STR),crearHoja(bus,STR));
  uniqueIdMain++;
  tNodoArbol *cadena =  crearNodo("=",&arbol,crearHoja("@cad",STR),crearHoja(cad,STR));
  uniqueIdMain++;
  asignarHijosNodo(inicial,&arbol,buscar,cadena);

  tNodoArbol *reempl =  crearNodo("=",&arbol,crearHoja("@rem",STR),crearHoja(rem,STR));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,reempl);

  tNodoArbol *lenBus = crearNodo("=", &arbol, crearHoja("@lenBus",INT), crearNodo("strlen",&arbol,crearHoja("@bus",STR),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenBus);

  tNodoArbol *lenRem = crearNodo("=", &arbol, crearHoja("@lenRem",INT), crearNodo("strlen",&arbol,crearHoja("@rem",STR),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenRem);


  tNodoArbol *lenCad = crearNodo("=", &arbol, crearHoja("@lenCad",INT), crearNodo("strlen",&arbol,crearHoja("@cad",STR),NULL));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,lenCad);

  tNodoArbol *i      = crearNodo("=", &arbol, crearHoja("@i",INT), crearHoja("0",INT));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,i);

  tNodoArbol *j      = crearNodo("=", &arbol, crearHoja("@j",INT), crearHoja("0",INT));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,j);

  tNodoArbol *k      = crearNodo("=", &arbol, crearHoja("@k",INT), crearHoja("0",INT));
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,k);

  tNodoArbol *temp   = crearHoja("@temp[1000]",INT);
  uniqueIdMain++;
  inicial =  crearNodo("S",&arbol,inicial,temp);
  uniqueIdMain++;


  tNodoArbol *param1 = crearNodo("+", &arbol, crearHoja("@cad",STR), crearHoja("@i",INT));
  tNodoArbol *param2 = crearHoja("@bus",STR);
  tNodoArbol *param3 = crearHoja("@lenBus",INT);
  tNodoArbol *allParam = crearNodo("S", &arbol, param1,param2 );
  uniqueIdMain++;
  allParam = crearNodo("S", &arbol, allParam, param3);

  tNodoArbol *strncmp_nodo = crearNodo("strncmp", &arbol, allParam, NULL);
  uniqueIdMain++;
  
  tNodoArbol *condicionIf = crearNodo("==", &arbol, strncmp_nodo, crearHoja("0",INT));
  uniqueIdMain++;

  tNodoArbol *cuerpoIf = crearNodo("=", &arbol, crearHoja("@j",INT), crearHoja("0",INT));
  uniqueIdMain++;
  
  
  tNodoArbol * cuerpoMientrasInterno = crearNodo("=",&arbol, crearHoja("@temp[k]",STR), crearHoja("@rem[j]",STR));
  uniqueIdMain++;

  aux = crearHoja("@j",INT);
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("S",&arbol, cuerpoMientrasInterno,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@j",INT),crearHoja("1",INT))
                                            )
                                  );
  uniqueIdMain++;
  aux = crearHoja("@k",INT);
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("S",&arbol, cuerpoMientrasInterno,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@k",INT),crearHoja("1",INT))
                                            )
                                  );
  uniqueIdMain++;
  cuerpoMientrasInterno = crearNodo("CUERPO", &arbol,cuerpoMientrasInterno,NULL);
  tNodoArbol *mientrasInterno = crearNodo("WHILE",&arbol, 
                                          crearNodo("<", &arbol, crearHoja("@j",INT), crearHoja("@lenRes",INT)), 
                                          cuerpoMientrasInterno);
  uniqueIdMain++;
  
  cuerpoIf = crearNodo("S", &arbol ,cuerpoIf,mientrasInterno);
  uniqueIdMain++;

  aux = crearHoja("@i",INT);
  uniqueIdMain++;
  cuerpoIf = crearNodo("S", &arbol ,cuerpoIf,
                      crearNodo("=",&arbol, aux, 
                                crearNodo("+",&arbol, crearHoja("@i",INT),crearHoja("@lenBus",INT))
                              ) 
                      );
  uniqueIdMain++;

  tNodoArbol* cuerpoElse = crearNodo("=",&arbol, crearHoja("@temp[k]",INT), crearHoja("@cad[j]",INT));
  uniqueIdMain++;
  aux = crearHoja("@k",INT);
  uniqueIdMain++;
  cuerpoElse = crearNodo("S",&arbol, cuerpoElse,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@k",INT),crearHoja("1",INT))
                                            )
                                  );
  uniqueIdMain++;

  aux = crearHoja("@i",INT);
  uniqueIdMain++;
  cuerpoElse = crearNodo("S",&arbol, cuerpoElse,
                                    crearNodo("=",&arbol, aux, 
                                              crearNodo("+",&arbol, crearHoja("@i",INT),crearHoja("1",INT))
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
                                  crearNodo("<", &arbol, crearHoja("@i",INT), crearHoja("@lenCad",INT))
                                  , cuerpoMientras);

  tNodoArbol *final = crearNodo("=",&arbol, crearHoja("@temp[k]",INT), crearHoja("0",INT));
  uniqueIdMain++;
  final = crearNodo("S",&arbol, final,
                   crearNodo("strcpy",&arbol, crearHoja("@cad",STR), crearHoja("@temp",STR))
                   ); 
  uniqueIdMain++;
  tNodoArbol *funcion = crearNodo("S",&arbol, inicial, mientras);
  uniqueIdMain++;
  funcion = crearNodo("S",&arbol, funcion, final);

  return funcion;
}