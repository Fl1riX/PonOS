BITS 16
ORG 0x8000

start:
  mov [boot_drive], dl ; сохраняем в регистр dl номер диска с которого произошла загрузка

; инициируем видеорежим для информационного вывода 
  mov ah, 0x00 
  mov al, 0x03

  int 0x10 

  cli ; отключаем аппаратные прерывания

  ; Обнуляем регистры AX, DS и ES (чтобы сегменты данных и доп. сегменты указывали на 0x0000)
  xor ax, ax
  mov ds, ax
  mov es, ax                    

  mov si, reading_disk
  call print_info      ; сообщение Reading disk...

  call read_disk       ; считываем диск

  mov si, boot_mes    
  call print_info

  mov si, entering_to_pm
  call print_info

  jmp mov_to_pm

mov_to_pm:
  in al, 0x92   ; чтение порта и запись значения в AL 
  or al, 2      ; устанавливаем бит №1 в AL (A20 gate bit)
  out 0x92, al  ; обратно записываем значение из al в  порт 0x92 

  lgdt [gdt_descriptor]

  mov eax, cr0         ; Установить бит PE(Protected Mode)
  or eax, 1
  mov cr0, eax
  
  jmp dword CODE_SEG:0x1000; Far jum

%include "gdt.asm"
%include "disk.asm"
%include "print.asm"
%include "data.asm"

times 1024-($-$$) db 0 
