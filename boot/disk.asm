; проверка наличия поддержки EDD и LBA 
lba_check: 
  mov ah, 0x41         ; проверка наличия EDD 
  mov dl, [boot_drive] ; номер диска для проверки 
  mov bx, 0x55AA       ; записываем сигнатуру

  int 0x13 
  jc .not_supported 

  cmp bx, 0xAA55
  je .supported
  jmp .not_supported

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
  jmp .chs 

; если LBA не поддерживается то используем CHS 
.chs:
  mov ah, 0x02               ; Функция BIOS: чтение секторов с диска
  mov al, 5                  ; Количество секторов для чтения (1 сектор = 512 байт)
  mov ch, 0                  ; Номер цилиндра = 0 
  mov dh, 0                  ; Номер головки = 0
  mov cl, 4                  ; Номер сектора (сектора начинаются с 1, сектор 1 — это сам загрузчик)
  mov dl, [boot_drive]       ; Номер загрузочного диска  
  mov bx, 0x1000             ; Смещение в сегменте ES, куда загрузить сектор (ES=0, значит физ. адрес = 0x0000:0x1000)
 
  int 0x13                   ; Вызов BIOS для чтения сектора
  jc disk_error              ; Если установлен флаг CF (ошибка ввода-вывода), перейти на обработку ошибки          

  jmp.info 

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
  dw 5      ; количество секторов для чтения 
  dw 0x1000 ; смещение в памяти 
  dw 0      ; сегмент памяти
  dq 3     ; номер считываемого сектора

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