global main
extern printf, scanf


section .bss
    buffer resb 512
    user_input resb 256     ; buffer para armazenar a entrada do usuário
    user_output resb 256  
section .data
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

read_file:
    ; Prólogo da função
    push ebp
    mov ebp, esp
    sub esp, 8

    ; ebp+8 : texto de entrada, ebp+12 : texto de saída
    
    ; mov edx, [ebp+12] ; Segundo parâmetro
    ; Exibe o parâmetro ( o que o usuário escreveu )
    push DWORD [ebp+8]
    push format_out
    call printf
    add esp, 8   

    push DWORD [ebp+12]
    push format_out
    call printf
    add esp, 8   

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
    xor eax,eax
    mov eax, 3 ; sys_read
    mov ebx, [fileHandle]
    mov ecx, buffer   ; buffer para armazenar os dados lidos do arquivo
    mov edx, buffer_size ; tamanho máximo de leitura
    ; Chama a função do sistema para ler do arquivo
    int 80h

    ; Verifica se o arquivo foi lido com sucesso
    cmp eax, -1
    je erro

    ; EXIBE O QUE TEM NO EAX
    push eax
    push format_d
    call printf
    add esp, 8  
    ; EXIBE O QUE TEM NO ARQUIVO DE ENTRADA
    push buffer
    push format_out
    call printf
    add esp, 8  

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

    ; Carrega buffer size
    mov esi, buffer
    xor ecx,ecx
    mov ecx,esi

    loop_strlen:

        mov al, byte [esi]
        cmp al, 0
        je calculate_file

        inc esi
        jmp loop_strlen
    

    calculate_file: 
        ;Calcula o tamanho da string subtraindo o endereço anterior como o incrementado
        sub esi,ecx
        cmp esi, 0
        je erro

        mov [buffer_size], esi

        modify_string:
            
            xor esi, esi
            xor ecx, ecx

            mov ebx, 2
            mov edi, buffer     
            mov esi, new_string  
            mov ecx, DWORD [buffer_size] 

            modify_loop:
                ;LOOP PARA DESCRIPTOGRAFAR BUFFER
                mov al, byte[edi]
                add al, bl
                mov [esi], al
                inc edi
                inc esi
                dec ecx

                cmp ecx, 0
                jne modify_loop


        write_file:
            ; ESCREVER NO ARQUIVO
            xor eax,eax
            xor eax, eax
            mov eax, 4          
            mov ebx, [outputHandle]       
            mov ecx, new_string    
            mov edx, [buffer_size] 
            int 80h
            
            ; Verificar se ocorreu um erro durante a escrita
            cmp eax, -1
            jl erro

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
    call read_file

    jmp exit_program
