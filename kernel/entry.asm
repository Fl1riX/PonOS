[BITS 32]
%include "kernel/constants.inc"
EXTERN main

global _start

section .text

_start:
    cld
    
    ; инициализируем сегментные регистры
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; инициализируем стек
    mov esp, 0x90000
    mov ebp, esp
    
    call main
    
    ; при выходе из ядра зависаем
    cli
.hang:
    hlt
    jmp .hang
