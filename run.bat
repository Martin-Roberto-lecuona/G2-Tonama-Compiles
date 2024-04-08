:: Script para windows
flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c -o compilador.exe
pause
compilador.exe prueba.txt > resultado.txt
pause

@REM compilador.exe ./ejemplos/whileAnidado.txt
@REM compilador.exe pruebasFallas.txt


@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
