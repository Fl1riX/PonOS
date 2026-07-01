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
