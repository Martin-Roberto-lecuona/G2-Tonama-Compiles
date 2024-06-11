#include "assembler.h"


void saveAssemblerFile(t_arbol *p){
    FILE *file = fopen("codigo.asm", "w");
    if (file == NULL) {
        perror("Error al abrir el archivo");
        exit(1);
    }
    char header [] = ".MODEL LARGE\n.386\n.STACK 200h\n.DATA\n";
    char tail [] = "\nmov ax,4ch00h\nInt 21h\nEnd";
    char code[] = ".CODE\nmov AX,@DATA\nmov DS,AX\nmov es,ax";

    fprintf(file, header);
    
    recorrerTablaSimbolos(file);
    
    fprintf(file, code);

    recorrerArbolAssembler(p, file);
    
    fprintf(file, tail);
    
    fclose(file);
}
void recorrerArbolAssembler(t_arbol *p, FILE *f) {
  if (!*p) {
    return;
  }
  recorrerArbolAssembler(&(*p)->izq, f);
  
  recorrerArbolAssembler(&(*p)->der, f);
}

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

    fclose(fileSimbol);
}
    