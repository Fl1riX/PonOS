read_keyboard:
  call check_pointer

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
  dec byte [pointer_printed]
  call check_command

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
