:: Script para windows
del resultado.txt
flex Lexico.l

bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c -o lyc-compiler-1.0.0.exe
lyc-compiler-1.0.0.exe prueba.txt > resultado.txt
@REM lyc-compiler-1.0.0.exe simple.txt > resultado.txt
@REM compilador.exe pruebasFallas.txt


@echo off
del lyc-compiler-1.0.0.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
