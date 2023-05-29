global main
extern printf, scanf


section .bss
    buffer resb 512
    user_input resb 256     ; buffer para armazenar a entrada do usuário
    user_output resb 256  
section .data
    total_buffer_size dd 0
    buffer_size dd 0
    dcrypt_key dd 0
    read_bytes dd 0
    size equ 512 
    new_string db size dup(0)
    format db "%s\n", 0    ; formato de entrada para a função scanf string
    format_out db "%s", 10,0   ; formato de saída para a função printf string
    format_dkey db "%d", 0    ; formato de entrada 
    format_d db "%d", 10,0  ; formato de saída
    format_c db "%c", 10,0 
    message db "Erro",10, 0
    error_no_bytes db "Não há bytes para serem lidos", 10,0
    end_msg db "Fim", 10,0
    fileHandle dd 0 
    outputHandle dd 0 
    

section .text

exit_program:
    push end_msg
    call printf
    add esp, 8  

    ; Termina o programa
    mov eax, 1
    xor ebx, ebx
    int 80h

erro:
    push message
    call printf
    add esp, 8

    xor eax, eax
    mov eax, 6          ; sys_close
    mov ebx, [fileHandle]       ; Handle do arquivo
    int 80h

    xor eax, eax
    mov eax, 6          ; sys_close
    mov ebx, [outputHandle]       ; Handle do arquivo
    int 80h

    mov esp,ebp
    pop ebp
    ret 4

no_bytes:

    push error_no_bytes
    call printf
    add esp, 8

    xor eax, eax
    mov eax, 6          ; sys_close
    mov ebx, [fileHandle]       ; Handle do arquivo
    int 80h

    xor eax, eax
    mov eax, 6          ; sys_close
    mov ebx, [outputHandle]       ; Handle do arquivo
    int 80h

    mov esp,ebp
    pop ebp
    ret 4

decrypt:
    ; Prólogo da função
    push ebp
    mov ebp, esp
    sub esp, 8

    ; ebp+8 : texto de entrada, ebp+12 : texto de saída, ebp+16 : chave de criptografia

    ; CRIANDO ARQUIVO NÃO EXISTENTE
    xor eax, eax
    mov eax, 8; sys_create
    mov ebx, [ebp+12]
    mov ecx, 0x201 ; write
    mov edx, 0o777
    int 80h

    mov [outputHandle], eax

    ; Verifica se o arquivo foi aberto com sucesso
    cmp eax, -1
    je erro

    ; ABRINDO ARQUIVO
    xor eax, eax
    mov eax, 5 ; sys_open
    mov ebx, [ebp+8]
    mov ecx, 0 ; read_only
    mov edx, 0o777
    int 80h

    mov [fileHandle], eax

    ; Verifica se o arquivo foi aberto com sucesso
    cmp eax, -1
    je erro
    ; Verifica se o arquivo foi encontrado
    cmp eax, -2
    je erro

    ; LEITURA DO ARQUIVO
    mov eax, 3 ; sys_read
    mov ebx, [fileHandle]
    mov ecx, buffer; buffer para armazenar os dados lidos do arquivo
    mov edx, size ; tamanho máximo de leitura
    ; Chama a função do sistema para ler do arquivo
    int 80h

    mov DWORD [buffer_size], eax
    ; Verifica se o arquivo foi lido com sucesso
    cmp eax, -1
    je erro

    cmp eax, 0
    je no_bytes
    modify_string:

        push DWORD [buffer_size]
        push format_d
        call printf
        add esp, 8  

        xor esi, esi
        xor ecx, ecx

        mov ebx, DWORD [dcrypt_key]
        mov edi, buffer     
        mov esi, new_string  
        mov ecx, DWORD [buffer_size] 

        loop_decrypt:
            ;LOOP PARA DESCRIPTOGRAFAR BUFFER
            mov al, byte[edi] ; byte do buffer
            sub al, bl ; subtrai a chave
            mov [esi], al ; salva no novo buffer
            inc edi ; incrementa o ponteiro do buffer
            inc esi ; incrementa o ponteiro do novo buffer
            dec ecx ; decrementa o contador
 
            cmp ecx, 0 ; verifica se o contador chegou a zero
            jne loop_decrypt ; se não, continua o loop

        write_file:
            ; ESCREVER NO ARQUIVO
            xor eax, eax
            mov eax, 4          
            mov ebx, [outputHandle]       
            mov ecx, new_string    
            mov edx, [buffer_size] 
            int 80h
            
            ; Verificar se ocorreu um erro durante a escrita
            cmp eax, -1
            jl erro

        ; Verifica se ainda há bytes para serem lidos
        cmp word [buffer_size], size
        je continue_modify

        ; Pula para o final do programa
        jmp end_modify

    continue_modify: 
        ; Ajusta a posição de leitura para continuar a partir do ponto onde parou
        xor eax, eax
        xor ecx, ecx
        xor esi, esi

        ; REPOSICIONAMENTO DO PONTEIRO DE ARQUIVO
        mov eax, 19         ; sys_lseek
        mov ebx, [fileHandle]
        mov edx, [buffer_size]
        int 80h

        ; LEITURA DO ARQUIVO
        mov eax, 3 ; sys_read
        mov ebx, [fileHandle]
        mov ecx, buffer; buffer para armazenar os dados lidos do arquivo
        mov edx, size ; tamanho máximo de leitura
        ; Chama a função do sistema para ler do arquivo
        int 80h

        ; Verifica se o arquivo foi lido com sucesso
        cmp eax, -1
        je erro

        ; Verifica se já foi lido todo o arquivo
        cmp eax, 0
        jne modify_string

    end_modify:
        ; FUNÇÃO PARA FECHAR O ARQUIVO E FINALIZAR O LOOP
        ; Fechar o arquivo
        mov eax, 6          ; sys_close
        mov ebx, [fileHandle]       ; Handle do arquivo
        int 80h

        ; Fechar o arquivo
        mov eax, 6          ; sys_close
        mov ebx, [outputHandle]       ; Handle do arquivo
        int 80h

    mov esp, ebp
    pop ebp
    ret 4

    
main:
    xor eax, eax    
    push user_input
    push format
    call scanf
    add esp, 8

    xor eax, eax    
    push user_output
    push format
    call scanf
    add esp, 8

    xor eax, eax    
    push dcrypt_key
    push format_dkey
    call scanf
    add esp, 8

    push DWORD [dcrypt_key]
    push user_output
    push user_input
    call decrypt

    jmp exit_program
