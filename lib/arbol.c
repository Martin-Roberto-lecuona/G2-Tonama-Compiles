#include "arbol.h"

void saveArbolFile(t_arbol *p) {
  FILE *treeFile = fopen("tree.dot", "w");
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