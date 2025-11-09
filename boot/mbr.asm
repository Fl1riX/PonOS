BITS 16
ORG 0x7C00

start:
  mov [boot_drive], dl
  
  cli

  xor ax, ax
  mov es, ax
  mov ds, ax

  ; инициализируем стек 
  mov ss, ax 
  mov sp, 0x7000
  mov bp, sp

  call reading_disk

  sti 

  jmp 0x8000


reading_disk:
  mov ah, 0x02               ; Функция BIOS: чтение секторов с диска
  mov al, 2                  ; Количество секторов для чтения (1 сектор = 512 байт)
  mov ch, 0                  ; Номер цилиндра = 0
  mov dh, 0                  ; Номер головки = 0
  mov cl, 2                  ; Номер сектора = 2 (сектора начинаются с 1, сектор 1 — это сам загрузчик)
  mov dl, [boot_drive]       ; Диск 0x00 = первый флоппи-диск (или A:)
  mov bx, 0x8000             ; Смещение в сегменте ES, куда загрузить сектор (ES=0, значит физ. адрес = 0x0000:0x1000)
 
  int 0x13                   ; Вызов BIOS для чтения сектора
  jc .disk_error

  ret

.disk_error:
  xor ah, ah
  int 0x13

  int 0x19

boot_drive db 0

times 510-($-$$) db 0 
dw 0xAA55
