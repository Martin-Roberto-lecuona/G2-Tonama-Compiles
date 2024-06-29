:: Script para windows
del resultado.txt

flex Lexico.l
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c -o lyc-compiler-2.0.0.exe
lyc-compiler-2.0.0.exe testCondicion.txt > resultado.txt

@echo off
del lyc-compiler-2.0.0.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
