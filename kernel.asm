BITS 16
ORG 0X1000

jmp kernel_start 

%include "kernel/io.asm"
%include "apps/calculator.asm"

kernel_start:
  mov ah, 0x00 ; устанавливаем видео режим
  mov al, 0x03 ; текстовый режим 16 текстовый  

  int 0x10     ; вызываем прерывание

  mov si, banner
  call print 

  mov si, welcome
  call print

  mov cx, 254
  call read_keyboard 

reboot:
  int 0x19 ; перезапуск системы 

check_pointer:
  cmp byte [pointer_printed], 0
  je .print_pointer
  jl .error

  cmp byte [pointer_printed], 1
  je .printed 
  jg .error

.print_pointer:
  mov si, cmd_pointer
  call print
  inc byte [pointer_printed]
  ret 

.error:
  mov byte [pointer_printed], 1
  ret 

.printed:
  ret 

check_command:  
  push si ; сохраняем регистры
  push di 
  push bx

  movzx si, [pressed_keys]       ; количество нажатых клавиш как счетчик количества клавиш в буфере 
  mov bx, key_buffer             ; указываем адрес буфера 
   
  add bx, si 
  mov byte [bx], 0              

  ; помощь 
  mov si, key_buffer
  mov di, help_cmd
  call str_cmp
  jc .help_found

  ; перезагрузка 
  mov si, key_buffer
  mov di, reboot_cmd
  call str_cmp
  jc .reboot_found

  ; калькулятор
  mov si, key_buffer
  mov di, calc_cmd
  call str_cmp
  jc .calc_found 

  mov si, key_buffer
  mov di, clear_cmd 
  call str_cmp
  jc .clear_found 

  jnc .not_found  

.not_found:
  pop bx
  pop di  
  pop si
  call clear_buffer
  mov byte [pressed_keys], 0  

  mov si, cmd_not_found
  call print 
  clc 
  jmp read_keyboard

.clear_found:
  pop bx
  pop di 
  pop si
  call clear_buffer
  mov byte [pressed_keys], 0  

  clc
  jmp clear_command 

.help_found:
  pop bx
  pop di 
  pop si
  call clear_buffer
  mov byte [pressed_keys], 0  

  clc
  jmp help_command
  
.reboot_found:
  pop bx 
  pop di 
  pop si
  call clear_buffer
  mov byte [pressed_keys], 0  

  clc
  jmp reboot

.calc_found:
  pop bx
  pop di 
  pop si
  call clear_buffer
  mov byte [pressed_keys], 0  

  clc
  jmp calc_command

help_command:
  mov si, help_text
  call print 
  jmp read_keyboard 

calc_command:
  call calc
  jmp read_keyboard
  jmp read_keyboard

clear_command:
  mov ah, 0x00
  mov al, 0x03

  int 0x10 

  jmp read_keyboard

str_cmp:
  push si
  push di 
.loop:
  mov al, [si]
  inc si

  cmp al, [di] ; посимвольно сравниваем ввод с коммандой 
  jne .error   ; если имволы не равны вызываем ошибку 
  inc di       ; выбираем следующий символ из di 

  test al, al  ; проверям на конец строки 
  jnz .loop

  stc ; устанавливаем СF = 1 
  
  pop di
  pop si

  ret  

.error:
  pop di
  pop si

  clc
  ret 

; переменные
key_buffer times 254 db 0     ; буфер клавиатуры под 256 символов 
pressed_keys db 0             ; счетчик нажатых клавиш
pointer_printed db 0 

; команды
help_cmd db 'help', 0 
reboot_cmd db 'reboot', 0 
calc_cmd db 'calc', 0 
clear_cmd db 'clear', 0 

; сообщения 
welcome db 'Welcome to the Pon operating system!', 13, 10, \
           'Type "help" to get command list', 13, 10, 0  ; 13 - возврат каретки в начало строки, 10 - перевод на новую сроку 
cmd_pointer db 'PON>', 0 
help_text db 13, 10,'type:', 13, 10, 'reboot - to reboot the device', 13, 10, \
                    'calc - to open the calculator', 13, 10, \
                    'clear - to clear the screen', 13, 10, 0

banner db 'ooooooooo.                           .oooooo.    .oooooo..o ', 13, 10, \
          '`888   `Y88.                        d8P`  `Y8b  d8P`    `Y8 ', 13, 10, \
          ' 888   .d88   .ooooo.  ooo. .oo.   888      888 Y88bo.      ', 13, 10, \
          ' 888ooo88P   d88  `88b `888P Y88b  888      888  `Y8888o.   ', 13, 10, \
          ' 888         888   888  888   888  888      888      `Y88b  ', 13, 10, \
          ' 888         888   888  888   888  `88b    d88  oo     .d8P ', 13, 10, \
          'o888o        `Y8bod8P  o888o o888o  `Y8bood8P   8``88888P`  ', 13, 10, \
          '                         v0.0.6                             ', 13, 10, 0                                                      
                                                            
; ошибки
cmd_not_found db 13, 10, 'Command not found!', 13, 10, 0 

times 2048-($-$$) db 0 
