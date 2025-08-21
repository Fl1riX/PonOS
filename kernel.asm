BITS 16
ORG 0X1000

kernel_start:
  mov ah, 0x00 ; устанавливаем видео режим
  mov al, 0x03 ; текстовый режим 16 текстовый  

  int 0x10     ; вызываем прерывание

  mov si, welcome
  call print

  call read_keyboard

  cli
  hlt 

reboot:
  int 0x19 ; перезапуск системы 

;TODO: повиксить работу с клавиатурой
read_keyboard:
  mov ah, 0x00
  int 0x16

  cmp al, 8
  je .del_character

  mov ah, 0x0E
  int 0x10     ; выводим один символ из al 

  jne read_keyboard

.del_character:
  mov ah, 0x03 ; получаем текущую позицию курсора
  mov bh, 0    ; устанавливаем страницу
  int 0x10 

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

; сообщения 
welcome db 'Welcome to the Pon operating system!', 13, 10, 'Press "1" to get help, "2" to reboot', 13, 10, 0  ; 13 - возврат каретки в начало строки, 10 - перевод на новую сроку 
;ent db 'Enter pressed', 13, 10, 0

times 1024-($-$$) db 0 
