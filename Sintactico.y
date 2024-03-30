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
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token CADENA
%token SI
%token MIENTRAS
%token SINO
%token OP_MAYOR
%token OP_MENOR
%token LA
%token LC
%token ESCRIBIR
%token LEER
%token OR
%token AND
%token NOT
%token INIT
%token DP
%token TDD
%token COMA

%%
programa:
	sentencia {printf(" FIN\n");}
	| sentencia programa
	;

sentencia:
	asignacion
	| comparacion LA programa LC condicion_sino {printf(" FIN SI\n");}
	| ESCRIBIR PA CADENA PC
	| ESCRIBIR PA ID PC
	| LEER PA ID PC
	| INIT LA declaraciones LC
	;

declaraciones:
	| variables DP TDD declaraciones
	;

variables:
	| ID adicional
	;

adicional:
	| COMA ID adicional
	;

condicion_sino:
	| SINO LA sentencia LC {printf(" FIN SINO\n");}
	;

asignacion:
	ID OP_AS expresion {printf("    ID = Expresion es ASIGNACION\n");}
	|ID OP_AS CADENA {printf("    ID = CADENA es ASIGNACION\n");}
	;

pr_con_comparacion:
	SI
	| MIENTRAS
	;

comparacion:
	pr_con_comparacion PA operacion_negacion expresion_comparacion PC {printf("comparacion");}
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
	|expresion OP_SUM termino {printf("Expresion+Termino es Expresion\n");}
	|expresion OP_RES termino {printf("Expresion-Termino es Expresion\n");}
	;

termino:
	factor {printf("Factor es Termino\n");}
	|termino OP_MUL factor {printf("Termino*Factor es Termino\n");}
	|termino OP_DIV factor {printf("Termino/Factor es Termino\n");}
	;

factor:
	ID {printf("    ID es Factor \n");}
	| CTE {printf("    CTE es Factor\n");}
	| FLOT {printf("    FLOT es Factor\n");}
	| PA expresion PC {printf("Expresion entre parentesis es Factor\n");}
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

