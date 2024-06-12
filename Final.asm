include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h
.DATA

.CODE
MOV DS,AX
MOV es,ax
FINIT
FFREE

fld a
fld 1
fadd
fstp @aux1
fld @aux1
fistp a


ffree
mov ax, 4c00h
int 21h
end