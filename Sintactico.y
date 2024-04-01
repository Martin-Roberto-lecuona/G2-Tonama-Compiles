// Usa Lexico_CLLAVE_AsePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopPARENTE_Arser=0;
FILE  *yyin;
  int yyerror();
  int yylex();
%}

%token TIPO_DATO

%token AND
%token OR
%token NOT

%token ESCRIBIR
%token LEER
%token INIT
%token SI
%token SINO
%token MIENTRAS

%token COMA
%token CTE
%token FLOT
%token ID
%token CADENA

%token OP_ASIG
%token OP_SUMA
%token OP_MULT
%token OP_REST
%token OP_DIVI
%token OP_MAYOR
%token OP_MENOR

%token PARENTE_A
%token PARENTE_C
%token LLAVE_A
%token LLAVE_C
%token DOSPUNTOS


%%
programa:
	sentencia {printf(" FIN\n");}
	| sentencia programa
	;

sentencia:
	asignacion
	| comPARENTE_Aracion LLAVE_A programa LLAVE_C condicion_sino {printf(" FIN SI\n");}
	| ESCRIBIR PARENTE_A CADENA PARENTE_C
	| ESCRIBIR PARENTE_A ID PARENTE_C
	| LEER PARENTE_A ID PARENTE_C
	| INIT LLAVE_A decLLAVE_Araciones LLAVE_C
	;

decLLAVE_Araciones:
	| variables DOSPUNTOS TIPO_DATO decLLAVE_Araciones
	;

variables:
	| ID adicional
	;

adicional:
	| COMA ID adicional
	;

condicion_sino:
	| SINO LLAVE_A programa LLAVE_C {printf(" FIN SINO\n");}
	;

asignacion:
	ID OP_ASIG expresion {printf("    ID = Expresion es ASIGNACION\n");}
	|ID OP_ASIG CADENA {printf("    ID = CADENA es ASIGNACION\n");}
	;

pr_con_comPARENTE_Aracion:
	SI
	| MIENTRAS
	;

comPARENTE_Aracion:
	pr_con_comPARENTE_Aracion PARENTE_A operacion_negacion expresion_comPARENTE_Aracion PARENTE_C {printf("comPARENTE_Aracion");}
	;
operacion_negacion:
	| NOT
	;
expresion_comPARENTE_Aracion:
	|expresion_comPARENTE_Aracion operacion_comPARENTE_Aracion factor {printf("exprecion operacion factor");}
	|factor {printf("factor es expresion_comPARENTE_Aracion");}
	;

operacion_comPARENTE_Aracion:
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
	| PARENTE_A expresion PARENTE_C {printf("Expresion entre PARENTE_Arentesis es Factor\n");}
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
        
        yyPARENTE_Arse();
        
    }
	fclose(yyin);
        return 0;
}
int yyerror(void)
     {
       printf("Error Sintactico\n");
	 exit (1);
     }

