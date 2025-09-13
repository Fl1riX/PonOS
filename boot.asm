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

  sti                  ; включаем аппаратные прерывания

  jmp 0x1000           ; Передать управление загруженному коду (ядру)

; проверка наличия поддержки EDD и LBA 
lba_check: 
  mov ah, 0x41         ; проверка наличия EDD 
  mov dl, [boot_drive] ; номер диска для проверки 
  mov bx, 0x55AA       ; записываем сигнатуру

  int 0x13 
  jc .not_supported 

  cmp bx, 0xAA55
  je .supported
  jne .not_supported

.supported:
  mov si, lba_yes
  call print_info
  inc byte [lba_enable]
  ret

.not_supported:
  mov si, lba_no
  call print_info
  ret

; чтение диска 
read_disk:
  call lba_check
  
  cmp byte [lba_enable], 1
  je .lba
  jne .chs 

  cmp al, 2                  ; проверяем количество реально загруженных секторов 
  je .info                   ; сообщаем, что диск прочитан

  mov si, disk_err_mes
  jne print_error            ; иначе выводим ошибку

; если LBA не поддерживается то используем CHS 
.chs:
  mov ah, 0x02               ; Функция BIOS: чтение секторов с диска
  mov al, 3                  ; Количество секторов для чтения (1 сектор = 512 байт)
  mov ch, 0                  ; Номер цилиндра = 0
  mov dh, 0                  ; Номер головки = 0
  mov cl, 4                  ; Номер сектора (сектора начинаются с 1, сектор 1 — это сам загрузчик)
  mov dl, [boot_drive]       ; Номер загрузочного диска  
  mov bx, 0x1000             ; Смещение в сегменте ES, куда загрузить сектор (ES=0, значит физ. адрес = 0x0000:0x1000)
 
  int 0x13                   ; Вызов BIOS для чтения сектора
  jc disk_error              ; Если установлен флаг CF (ошибка ввода-вывода), перейти на обработку ошибки          
  jnc .info 

  ret 

.lba:
  mov ah, 0x42 ; проверка наличия EDD 
  
  mov si, .dap ; загружаем dap 
  mov dl, [boot_drive] 
  
  int 0x13 
  jc disk_error 
  
  jnc .info 

.dap:
  db 0x10   ; размер струкутуры (16 байт)
  db 0      ; резерв(всегда 0)
  dw 3      ; количество секторов для чтения 
  dw 0x1000 ; смещение в памяти 
  dw 0      ; сегмент памяти
  dq 3      ; номер считываемого сектора

.info:
  mov si, disk_readed
  call print_info
  ret 

; инструкции на случай ошибки чтения ядра с диска
disk_error:
  mov [error_code], ah      ; сохраняем код ошибки для дальнейше обработки и информационного вывода

  inc byte [retry_count]    ; увеличиваем счетчик попыток на 1 

  xor ah, ah                ; сброс диска
  int 0x13  
  jnc read_disk 

  cmp byte [retry_count], 3 ; проверка количества осуществленных попыток
  jge .error 

  jmp read_disk 

.error:
  call find_error_message
  jmp print_error 

; вывод сообщения об ошибке 
print_error: 
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

; поиск кода ошибки в таблице соответствий 
find_error_message:
  mov si, disk_error_table 
  mov al, [error_code] 

.loop:
  cmp byte [si], 0    ; проверяем на конец таблицы 
  je .not_found       ; если ни один код не совпал выводим сообщение о неизвестной ошибке 
  
  cmp byte [si], al   ; сравниваем код из таблицы с искомым
  je .found 

  add si, 3           ; переход к следующей записи 1 байт - код, 2 байта - указатель
  jmp .loop 

.found:
  inc si              ; пропустить код ошибки 
  mov si, [si]        ; загружаем в регист si сообщение об ошибке для дальнейшего вывода 
  ret

.not_found:
  mov si, unknown_error
  ret

; вывод ошибки 
print_info:
  mov ah, 0x0E

  jmp .loop

.loop:
  lodsb
  cmp al, 0
  jz .done

  int 0x10

  jmp .loop

.done:
 ret 

; таблица соответствий для ошибок
disk_error_table:
  db 0x01
  dw error_invalid_cmd

  db 0x02
  dw error_address_mark

  db 0x04
  dw error_sector_not_found

  db 0x08
  dw error_dma_overrun

  db 0x10
  dw error_crc

  db 0x40
  dw error_seek_failed

  db 0x80
  dw error_timeout

  db 0x00 ; макер конца таблицы
  dw unknown_error

; сообщения
stack_inited db 'Stack initialized!', 13, 10, 0
reading_disk db 'Reading disk...', 13, 10, 0
disk_readed db 'Disk readed!', 13, 10, 0
boot_mes db 'Loading kernel...', 13, 10, 0
lba_yes db 'LBA supported!', 13, 10, 0
lba_no db 'LBA not supported!', 13, 10, 0

; ошибки
disk_err_mes db 'Disk reading error!', 0
error_invalid_cmd      db 'Error 0x01: Invalid command', 0
error_address_mark     db 'Error 0x02: Address mark not found', 0  
error_sector_not_found db 'Error 0x04: Sector not found', 0
error_dma_overrun      db 'Error 0x08: DMA overrun', 0
error_crc              db 'Error 0x10: CRC/ECC error', 0
error_seek_failed      db 'Error 0x40: Seek operation failed', 0
error_timeout          db 'Error 0x80: Drive timeout', 0
unknown_error          db 'Unknown disk error', 0

; переменные
retry_count db 0
error_code db 0 
boot_drive db 0 
lba_enable db 0 
checks db 0 

times 1024-($-$$) db 0 
