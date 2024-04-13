:: Script para windows
del resultado.txt
flex Lexico.l

bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c -o compilador.exe
compilador.exe prueba.txt > resultado.txt
@REM compilador.exe ./ejemplos/commAnidado.txt
@REM compilador.exe pruebasFallas.txt


@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
