BITS 16
ORG 0X1000

;jmp kernel_start 

;%include "calculator.asm"

kernel_start:
  mov ah, 0x00 ; устанавливаем видео режим
  mov al, 0x03 ; текстовый режим 16 текстовый  

  int 0x10     ; вызываем прерывание

  mov si, banner
  call print 

  mov si, welcome
  call print

  call read_keyboard 

reboot:
  int 0x19 ; перезапуск системы 

read_keyboard:
  mov ah, 0x00
  int 0x16

  cmp byte [pressed_keys], 254  ; если количество клавиш превышает размер буфера, то происходит перезагрузка
  jae clear_buffer

  cmp al, 8 ; проверка на backspace
  je .del_character

  cmp al, 13 ; проверка на enter
  je .enter_pressed

  push bx
  movzx si, [pressed_keys]         
  mov bx, key_buffer            ; указываем адрес буфера 
   
  add bx, si 
  mov [bx], al                  ; записываем клавишу в буфер + смещение на 1 
  inc byte [pressed_keys]       ; увеличиваем число нажатых кнопок
  
  pop bx

  mov ah, 0x0E      ; функция вывода символа 
  int 0x10          ; выводим один символ из al 

  jmp read_keyboard ; бесконечный цикл

.enter_pressed:
  call check_command
  jmp read_keyboard

.del_character:
  mov ah, 0x03 ; получаем текущую позицию курсора
  mov bh, 0    ; устанавливаем страницу
  int 0x10 

  dec byte [pressed_keys]

  push bx
  movzx si, [pressed_keys]  ; указываем адрес буфера 
  mov bx, key_buffer
   
  add bx, si 
  mov byte [bx], 0        ; записываем клавишу в буфер + смещение на 1 

  pop bx

  cmp dl, 0    ; проверка на начало строки 
  je read_keyboard
  jne .continue

.continue:
  dec dl       ; уменьшаем позицию курсора на 1 символ 
  mov ah, 0x02 ; устанавливаем курсор 
  int 0x10 

  mov ah, 0x0E ; устанавливаем вывод символа 
  mov al, ' '  ; выводим пробел 
  int 0x10 
  
  mov ah, 0x03 ; снова получаем позицию курсора потому что при выводе символа он смещается влево 
  int 0x10 
  dec dl

  mov ah, 0x02 ; устанавливаем курсор 
  int 0x10
  jmp read_keyboard ; снова читаем клавиатуру 

clear_buffer:
  push ax
  push cx
  push di 

  mov di, key_buffer
  mov cx, 254
  mov al, 0
  rep stosb  ; rep повтояет инструкцию столько сколько указанно в cx, stosb копирует байт из al по адресу es:di

  pop di
  pop cx
  pop ax

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
  ;call calc
  ;jmp read_keyboard
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


print:
  jmp .loop

.loop:
  lodsb        ; загружаем по 1 символу из si в al
  cmp al, 0    ; проверяем на конец строки

  jz .done     ; когда строка заканчивается осуществляем переход

  mov ah, 0x0E ; устанавливаем вывод символа 
  int 0x10     ; выводим символ     

  jmp .loop    ; начинаем цикл заново пока не выведется все слово 

.done:
  ret

; переменные
key_buffer times 254 db 0     ; буфер клавиатуры под 256 символов 
pressed_keys db 0             ; счетчик нажатых клавиш

; команды
help_cmd db 'help', 0 
reboot_cmd db 'reboot', 0 
calc_cmd db 'calc', 0 
clear_cmd db 'clear', 0 
help_text db 13, 10,'type:', 13, 10, 'reboot - to reboot the device', 13, 10, 'calc - to open the calculator', 13, 10, 0

; сообщения 
welcome db 'Welcome to the Pon operating system!', 13, 10, 'Type "help" to get command list', 13, 10, 0  ; 13 - возврат каретки в начало строки, 10 - перевод на новую сроку 
banner db 'ooooooooo.                           .oooooo.    .oooooo..o ', 13, 10, \
          '`888   `Y88.                        d8P`  `Y8b  d8P`    `Y8 ', 13, 10, \
          ' 888   .d88   .ooooo.  ooo. .oo.   888      888 Y88bo.      ', 13, 10, \
          ' 888ooo88P   d88  `88b `888P Y88b  888      888  `Y8888o.   ', 13, 10, \
          ' 888         888   888  888   888  888      888      `Y88b  ', 13, 10, \
          ' 888         888   888  888   888  `88b    d88  oo     .d8P ', 13, 10, \
          'o888o        `Y8bod8P  o888o o888o  `Y8bood8P   8``88888P`  ', 13, 10, 13, 10, 0                                                      
                                                            
; ошибки
cmd_not_found db 13, 10, 'Command not found!', 13, 10, 0 

times 1536-($-$$) db 0 
