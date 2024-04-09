:: Script para windows
del resultado.txt
flex Lexico.l
pause
bison -dyv Sintactico.y
pause
gcc.exe lex.yy.c y.tab.c -o compilador.exe
pause
compilador.exe prueba.txt > resultado.txt
@REM compilador.exe ./ejemplos/commAnidado.txt
@REM compilador.exe pruebasFallas.txt

pause
@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output
