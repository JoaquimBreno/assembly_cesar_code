

section .bss
    user_input resd 1

section .data
    menu_str db "1 - Descriptografar", 10, "2 - Criptografar", 10, "Digite sua opcao: ", 0
    result_str db "Resultado: %d", 10, 0
    format_in db "%d", 0

section .text
; Incluir as funções externas que usaremos
    global main
    extern printf, scanf, fflush, stdout
; Função para descriptografar
decrypt:
    push ebp
    mov ebp, esp
    mov eax, 12
    jmp .exit
    .exit:
    leave
    ret 4

; Função para criptografar
encrypt:
    push ebp
    mov ebp, esp
    mov eax, 13
    jmp .exit
    .exit:
    leave
    ret 4

; Entrada do programa
main:
    ; Exibir o menu
    push menu_str
    call printf
    add esp, 4

    ; Ler a seleção do usuário
    lea eax, [user_input]
    push eax
    push format_in
    call scanf
    add esp, 8

    ; Chamar a função apropriada
    cmp DWORD [user_input], 1
    je .call_decrypt
    cmp DWORD [user_input], 2
    je .call_encrypt
    jmp main

    ; Chamar a função decrypt e exibir o resultado
    .call_decrypt:
    call decrypt
    jmp .display_result

    ; Chamar a função encrypt e exibir o resultado
    .call_encrypt:
    call encrypt

    ; Exibir o resultado
    .display_result:
    push eax
    push result_str
    call printf
    add esp, 8

    ; Limpar o buffer de stdout
    push DWORD [stdout]
    call fflush
    add esp, 4

    ; Encerrar o programa
    mov eax, 1
    xor ebx, ebx
    int 80h