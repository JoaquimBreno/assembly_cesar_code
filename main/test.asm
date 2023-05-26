global main
extern printf, scanf

section .bss
    user_input resb 256
    buffer resb 512

section .data
    buffer_size equ 512
    format db "%s\n", 0  ; Formato de string para o printf
    format_out db "%s", 10, 0
 
section .text
      
main:
    xor eax, eax    
    push user_input
    push format
    call scanf
    add esp, 8

    push user_input
    push format_out
    call printf
    add esp, 8 
    
    mov eax, 1
    xor ebx, ebx
    int 80h