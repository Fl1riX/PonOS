[BITS 32]
EXTERN main

global _start
section .text

; константы для gdt, высчитаны в ручную
; Null descriptor (0) + Code descriptor (8) + Data descriptor (16)
CODE_SEG equ 0x08
DATA_SEG equ 0x10

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
