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

; сообщения
entering_to_pm db 'switching to protected 32-bit mode', 13, 10, 0
entry db 'Jumping to entry point', 13, 10, 0
reading_disk db 'Reading disk...', 13, 10, 0
disk_readed db 'Disk read successfully!', 13, 10, 0
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