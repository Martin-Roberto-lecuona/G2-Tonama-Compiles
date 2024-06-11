.MODEL LARGE
.386
.STACK 200h
.DATA
@aux dd 0
@res dd 0
a dd ?
b dd ?
c dd ?
d dd ?
_-1 dd -1
_2 dd 2
_1#45 dd 1.45
.CODE
mov AX,@DATA
mov DS,AX
mov es,ax
mov ax,4ch00h
Int 21h
End