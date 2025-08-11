BITS 16
ORG 0x7C00 

retry_count db 0

start:
  cli

  ; Обнуляем регистры DS и ES (чтобы сегменты данных и доп. сегменты указывали на 0x0000)
  xor ax, ax
  mov ds, ax
  mov es, ax

  ; инициализируем стек 
  mov ss, ax
  mov sp, 0x7000
  mov bp, sp

  sti
  
  call read_disk
  jmp 0x1000      ; Передать управление загруженному коду (ядру)

read_disk:
  mov ah, 0x02    ; Функция BIOS: чтение секторов с диска
  mov al, 1       ; Количество секторов для чтения (1 сектор = 512 байт)
  mov ch, 0       ; Номер цилиндра = 0
  mov dh, 0       ; Номер головки = 0
  mov cl, 2       ; Номер сектора = 2 (сектора начинаются с 1, сектор 1 — это сам загрузчик)
  mov dl, 0       ; Диск 0x00 = первый флоппи-диск (или A:)
  mov bx, 0x1000  ; Смещение в сегменте ES, куда загрузить сектор (ES=0, значит физ. адрес = 0x0000:0x1000)
 
  int 0x13        ; Вызов BIOS для чтения сектора
  jc disk_error   ; Если установлен флаг CF (ошибка ввода-вывода), перейти на обработку ошибки
  
  ret 

; инструкции на случай ошибки чтения ядра с диска
disk_error:
  inc byte [retry_count] ; увеличиваем счетчик попыток на 1 

  xor ah, ah ; сброс диска
  int 0x13  
  jnc read_disk 

  cmp byte [retry_count], 3 ; проверка количества осуществленных попыток
jge .error 

  jmp read_disk 

.error:
  mov si, disk_err_mes ; перемещаем сообщение об ошибке в si для дальнейшего вывода
  jmp print_error 

; вывод сообщения об ошибке 
print_error: 
  mov ah, 0x00
  mov al, 0x03
  
  int 0x10
  mov ah, 0x0E

  jmp .loop 

.loop:
  lodsb
  cmp al, 0
  jz .done
  
  int 0x10 

  jmp .loop 

.done:
  cli 
  hlt 

disk_err_mes db 'Disk reading error!', 0

times 510-($-$$) db 0 ; Заполнение оставшегося места до 510 байт нулями
dw 0xAA55             ; Сигнатура загрузочного сектора (MBR/boot sector)
