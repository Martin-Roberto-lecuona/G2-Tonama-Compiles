## Script para Unix
flex Lexico.l
bison -dyv Sintactico.y
gcc lex.yy.c y.tab.c -o lyc-compiler-1.0.0
./lyc-compiler-1.0.0 prueba.txt
rm lex.yy.c
rm y.tab.c
rm y.output
rm y.tab.h
rm lyc-compiler-1.0.0