:: Script para windows
del resultado.txt

flex Lexico.l
bison -dyv Sintactico.y

gcc.exe lex.yy.c y.tab.c -o lyc-compiler-3.0.0.exe
lyc-compiler-3.0.0.exe test.txt > resultado.txt

@echo off
del lyc-compiler-3.0.0.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

:: tasm Final.asm
:: tasm numbers.asm
:: tlink Final.obj numbers.obj
:: Final.exe