include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h
.DATA

@aux dd 0
@res dd 0
a dd ?
b dd ?
_1 dd 
_4#12 dd ,ùe4.12
@aux1 dd 0


.CODE
MOV DS,AX
MOV es,ax
FINIT
FFREE

fld a
fld _1
fadd
fstp @aux1
fld @aux1
fistp a


ffree
mov ax, 4c00h
int 21h
end