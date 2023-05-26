global main
extern printf, scanf


section .bss
    buffer resb 512
    user_input resb 256     ; buffer para armazenar a entrada do usuário

section .data
    buffer_size equ 512
    ;buffer db 100           ; tamanho máximo do buffer
    format db "%s\n", 0    ; formato de entrada para a função scanf
    format_out db "%s", 10,0   ; formato de saída para a função printf
    message db "Digite uma string: ", 0
    message_len equ $ - message


section .text

strlen:
    push ebp
    mov ebp, esp
    xor eax, eax
    mov edi, [ebp + 8]    ; Pega o endereço da string
    mov ecx, 0            ; Inicializa o contador de tamanho da string

    loop_start:
        cmp byte [edi], 0   ; Verifica se chegou ao final da string
        je loop_end         ; Se sim, sai do loop
        inc ecx             ; Incrementa o contador
        inc edi             ; Avança para o próximo caractere
        jmp loop_start      ; Volta para o início do loop

    loop_end:
    mov eax, ecx           ; Coloca o tamanho da string em eax

    mov esp, ebp
    pop ebp
    ret

read_file:

    push ebp
    mov ebp, esp
    sub esp, 8
    mov eax, [ebp+8]
    push eax
    push format_out
    call printf
    add esp, 8    

    mov esp,ebp
    pop ebp
    ret 4

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
    
    push user_input
    call read_file

    ; ; Termina o programa
    mov eax, 1
    xor ebx, ebx
    int 80h
