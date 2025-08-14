BITS 16
ORG 0X1000

kernel_start:
  mov ah, 0x00 ; устанавливаем видео режим
  mov al, 0x03 ; текстовый режим 16 текстовый  

  int 0x10     ; вызываем прерывание

  mov si, welcome
  call print

  cli
  hlt 

reboot:
  int 0x19 ; перезапуск системы 

print:
  jmp .loop

.loop:
  lodsb        ; читаем по 1 символу из si
  cmp al, 0    ; проверяем на конец строки

  jz .done     ; когда строка заканчивается осуществляем переход

  mov ah, 0x0E ; устанавливаем вывод символа 
  int 0x10     ; выводим символ     

  jmp .loop    ; начинаем цикл заново пока не выведется все слово 

.done:
  ret          ; бесконечный цикл

welcome db 'Welcome to the Pon operating system!', 13, 10, 'Type "help" to get a list of commands', 13, 10, 0  ; 13 - возврат каретки в начало строки, 10 - перевод на новую сроку 
times 1024-($-$$) db 0 
