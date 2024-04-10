// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;
  int yyerror();
  int yylex();
%}

%token CTE
%token FLOT
%token ID
%token OP_ASIG
%token OP_SUMA
%token OP_MULT
%token OP_REST
%token OP_DIVI
%token PARENTE_I
%token PARENTE_D
%token CADENA
%token SI
%token MIENTRAS
%token SINO
%token OP_MAYOR
%token OP_MENOR
%token OP_MAYOR_IGUAL
%token OP_MENOR_IGUAL
%token OP_IGUAL
%token LLAVE_I
%token LLAVE_D
%token ESCRIBIR
%token LEER
%token OR
%token AND
%token NOT
%token INIT
%token DOS_PUNT
%token TIPO_DATO
%token COMA


%%
proyecto : 
	bloque {printf(" FIN\n");}
	;
bloque:
	sentencia {printf(" sentencia es bloque\n");}
	| bloque sentencia {printf(" bloque sentencia es bloque\n");}
	;

sentencia:
	asignacion
	| iteracion 
	| seleccion
	| ESCRIBIR PARENTE_I CADENA PARENTE_D
	| ESCRIBIR PARENTE_I ID PARENTE_D
	| LEER PARENTE_I ID PARENTE_D
	| INIT LLAVE_I declaraciones LLAVE_D
	| INIT LLAVE_I LLAVE_D
	;

asignacion:
	ID OP_ASIG expresion {printf("    ID = Expresion es ASIGNACION\n");}
	|ID OP_ASIG CADENA {printf("    ID = CADENA es ASIGNACION\n");}
	;

seleccion:
	SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D SINO LLAVE_I bloque LLAVE_D {printf("SI (condicion) bloque sino bloque = seleccion\n");}
	| SI PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("SI (condicion) bloque = seleccion\n");}
	;
iteracion:
	MIENTRAS PARENTE_I condicion PARENTE_D LLAVE_I bloque LLAVE_D {printf("mientras (condicion) bloque = iteracion\n");}
	;
compuertas:
	AND
	|OR
	;
comparador:
	OP_MAYOR
	| OP_MENOR
	| OP_MAYOR_IGUAL
	| OP_MENOR_IGUAL
	| OP_IGUAL
	;

condicion:
	comparacion {printf("comparacion = condicion\n");}
	|condicion compuertas comparacion {printf("condicion compuerta comparacion = condicion\n");}
	;
comparacion:
	expresion comparador expresion {printf("expresion comparador expresion = comparacion\n");}
	|NOT comparacion {printf("NOT comparacion = comparacion\n");}
	| PARENTE_I comparacion PARENTE_D {printf("(comparacion) = comparacion\n");}
	| factor {printf("factor = comparacion\n");}
	;

expresion:
	termino {printf("Termino es Expresion\n");}
	|expresion OP_SUMA termino {printf("Expresion+Termino es Expresion\n");}
	|expresion OP_REST termino {printf("Expresion-Termino es Expresion\n");}
	;

termino:
	factor {printf("Factor es Termino\n");}
	|termino OP_MULT factor {printf("Termino*Factor es Termino\n");}
	|termino OP_DIVI factor {printf("Termino/Factor es Termino\n");}
	;

factor:
	ID {printf("    ID es Factor \n");}
	| CTE {printf("    CTE es Factor\n");}
	| FLOT {printf("    FLOT es Factor\n");}
	;
declaraciones:
	variables DOS_PUNT TIPO_DATO declaraciones
	| variables DOS_PUNT TIPO_DATO
	;

variables:
	ID COMA variables
	| ID
	;
%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        
        yyparse();
        
    }
	fclose(yyin);
        return 0;
}
int yyerror(void)
     {
       printf("Error Sintactico\n");
	 exit (1);
     }

