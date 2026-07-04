; вывод сообщения об ошибке 
print_error: 
  call print_loop

  cli 
  hlt 

; вывод ошибки 
print_info:
  call print_loop

  ret

print_loop:
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