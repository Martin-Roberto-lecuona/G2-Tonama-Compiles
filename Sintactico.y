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
programa:
	sentencia {printf(" FIN\n");}
	| sentencia programa
	;

sentencia:
	asignacion
	| comparacion LLAVE_I programa LLAVE_D condicion_sino {printf(" FIN SI\n");}
	| ESCRIBIR PARENTE_I CADENA PARENTE_D
	| ESCRIBIR PARENTE_I ID PARENTE_D
	| LEER PARENTE_I ID PARENTE_D
	| INIT LLAVE_I declaraciones LLAVE_D
	;

declaraciones:
	| variables DOS_PUNT TIPO_DATO declaraciones
	;

variables:
	| ID adicional
	;

adicional:
	| COMA ID adicional
	;

condicion_sino:
	| SINO LLAVE_I programa LLAVE_D {printf(" FIN SINO\n");}
	;

asignacion:
	ID OP_ASIG expresion {printf("    ID = Expresion es ASIGNACION\n");}
	|ID OP_ASIG CADENA {printf("    ID = CADENA es ASIGNACION\n");}
	;

pr_con_comparacion:
	SI
	| MIENTRAS
	;

comparacion:
	pr_con_comparacion PARENTE_I operacion_negacion expresion_comparacion PARENTE_D {printf("comparacion");}
	;
operacion_negacion:
	| NOT
	;
expresion_comparacion:
	|expresion_comparacion operacion_comparacion factor {printf("exprecion operacion factor");}
	|factor {printf("factor es expresion_comparacion");}
	;

operacion_comparacion:
	OP_MAYOR
	| OP_MENOR
	| AND
	| OR
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
	| PARENTE_I expresion PARENTE_D {printf("Expresion entre parentesis es Factor\n");}
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

