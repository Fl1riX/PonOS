gdt_start:
  ; Null дескриптор - обязательная часть
  dq 0x0   

gdt_code:
  dw 0xFFFF     ; Limit[0-15]
  dw 0x0000     ; Base[0-15]
  db 0x00       ; Base[16-23]
  db 10011010b  ; флаги доступа
  db 11001111b  ; флаги + Limit[16-19]
  db 0x00       ; Base[24-31]

gdt_data:
  dw 0xFFFF     ; Limit[0-15]
  dw 0x0000     ; Base[0-15]
  db 0x00       ; Base[16-23]
  db 10010010b  ; флаги доступа
  db 11001111b  ; флаги + Limit[16-19]
  db 0x00       ; Base[24-31]
 
gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start - 1 ; размер GDT в байтах - 1 (-1 т.к это особенность процессора. Если Gdt=24б, то пишем 23)
  dd gdt_start               ; адрес начала gdtc

; константы (при изменении GDT поменять их в entry)
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start