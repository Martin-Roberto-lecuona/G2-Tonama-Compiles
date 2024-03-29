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
%token OP_MAYOR
%token OP_MENOR
%token LA
%token LC

%%
programa:
  sentencia {printf(" FIN\n");};
sentencia:  	   
	asignacion
  | sentencia asignacion
  | comparacion LA sentencia LC {printf(" FIN SI\n");};
  ;

asignacion: 
          ID OP_AS expresion {printf("    ID = Expresion es ASIGNACION\n");}
          |ID OP_AS CADENA {printf("    ID = CADENA es ASIGNACION\n");}
	  ;

pr_con_comparacion:
  SI

comparacion:
  pr_con_comparacion PA expresion_comparacion PC {printf("comparacion");}
 
expresion_comparacion:
  |expresion_comparacion operacion_comparacion factor_comparacion {printf("exprecion operacion factor");}
  |factor_comparacion {printf("exprecion es factor");}
  ;

factor_comparacion:
  ID {printf("    ID es Factor \n");}
      | CTE {printf("    CTE es Factor\n");}
      | FLOT {printf("    FLOT es Factor\n");}
      | expresion_comparacion {printf("factor_comparacion es Factor\n");}
      ;

operacion_comparacion:
    OP_MAYOR 
    | OP_MENOR
    ;

expresion:
         termino {printf("    Termino es Expresion\n");}
	 |expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
	 |expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
	 ;

termino: 
       factor {printf("    Factor es Termino\n");}
       |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
       |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
       ;

factor: 
      ID {printf("    ID es Factor \n");}
      | CTE {printf("    CTE es Factor\n");}
      | FLOT {printf("    FLOT es Factor\n");}
	| PA expresion PC {printf("    Expresion entre parentesis es Factor\n");}
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

