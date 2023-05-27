.686
.model flat,stdcall

option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
;--------------------inputs e variáveis para leitura de arquivos
    inputFile db 260 dup(0)          ; Buffer para armazenar o nome do arquivo de entrada
    outputFile db 260 dup(0)         ; Buffer para armazenar o nome do arquivo de saída
    inputHandle dd 0                 ; Handle de entrada
    outputHandle dd 0                ; Handle de saída
    readCount dd ?                   ; Variável para armazenar o número de bytes lidos 
    writeCount dd ?                  ; Variável para armazenar o número de bytes escritos
    bufferSize equ 512               ; Tamanho do buffer para leitura/escrita do arquivo
    buffer db bufferSize dup(0)      ; Buffer para armazenar o conteúdo do arquivo de entrada
    modifiedString db bufferSize dup(0)  ; Variável para armazenar a string modificada
    promptInput db "Digite o nome do arquivo de entrada: ", 0
    promptOutput db "Digite o nome do arquivo de saída: ", 0
    promptNumber db "Digite o número para somar a cada caractere: ", 0
    newline db 13, 10, 0             ; Definir sequência de escape para quebra de linha
    emptyPrompt db "O arquivo está vazio.", 0
    errorPrompt db "Erro ao abrir o arquivo.", 0

;-------------------inputs e variáveis para leitura do Menu
    titulo db "Selecione uma opcao:", 0ah, 0h
    textCod db "(1) Codificar", 0ah, 0h
    textDecod db "(2) Decodificar", 0ah, 0h
    TextSair db "(3) Sair", 0ah, 0h
    inputString db 50 dup(0)
    tamanho_string dd 0 ; Variavel para armazenar tamanho de string terminada em 0

    ;---------Variáveis de opções Menu
    numCod dd 1
    numDec dd 2
    numSair dd 3
    
.code
;-------------------------------Função codificar
codificar:
    push ebp
    mov ebp, esp
    

    ; Abrir o arquivo de entrada
    invoke CreateFile, addr inputFile, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inputHandle, eax

    ; Verificar se o arquivo de entrada foi aberto com sucesso
    cmp inputHandle, INVALID_HANDLE_VALUE
    je erro

    ; Abrir o arquivo de saída
    invoke CreateFile, addr outputFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov outputHandle, eax

    ; Verificar se o arquivo de saída foi aberto com sucesso
    cmp outputHandle, INVALID_HANDLE_VALUE
    je erro

    ; Arquivo aberto com sucesso
    invoke ReadFile, inputHandle, addr buffer, bufferSize, addr readCount, NULL
    cmp readCount, 0
    je nenhum_dado

    ; Loop para processar o arquivo em porções de 512 bytes
    process_loop:
        ; Colocar a string lida do arquivo na variável modifiedString e adicionar o número de soma a cada caractere
        mov edi, offset buffer           ; Endereço do buffer de entrada
        mov esi, offset modifiedString   ; Endereço da variável modifiedString
        mov ecx, readCount               ; Número de bytes lidos

        modify_loop:
            mov al, [edi]   ; Caractere atual
            add al, bl      ; Adicionar número de soma ao caractere
            mov [esi], al   ; Armazenar o caractere modificado na variável modifiedString

            inc edi         ; Avançar para o próximo caractere do buffer de entrada
            inc esi         ; Avançar para o próximo caractere da modifiedString
            dec ecx         ; Decrementar o contador de repetições

            cmp ecx, 0      ; Verificar se o contador chegou a zero
            jne modify_loop ; Saltar de volta para modify_loop se o contador for diferente de zero

        ; Escrever a string modificada no arquivo de saída
        invoke WriteFile, outputHandle, addr modifiedString, readCount, addr writeCount, NULL

        ; Verificar se há mais dados a serem lidos
        cmp readCount, bufferSize
        je continue_loop

        ; Sair do loop se não há mais dados a serem lidos
        jmp end_loop

    continue_loop:
        ; Ler a próxima porção do arquivo de entrada
        invoke ReadFile, inputHandle, addr buffer, bufferSize, addr readCount, NULL
        cmp readCount, 0
        jne process_loop

    end_loop:
    ; Fechar os handles dos arquivos
    invoke CloseHandle, inputHandle
    invoke CloseHandle, outputHandle

    mov esp, ebp
    pop ebp
    ret

    erro:
    ; Exibir mensagem de erro
    invoke WriteConsole, outputHandle, addr errorPrompt, sizeof errorPrompt, addr writeCount, NULL

    nenhum_dado:
        ; Exibir mensagem de arquivo vazio
        invoke WriteConsole, outputHandle, addr emptyPrompt, sizeof emptyPrompt, addr writeCount, NULL
    
        ; Fechar os handles dos arquivos
        invoke CloseHandle, inputHandle
        invoke CloseHandle, outputHandle

;---------------------------Função decodificar
decodificar:
    push ebp
    mov ebp, esp

    ; Abrir o arquivo de entrada
    invoke CreateFile, addr inputFile, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inputHandle, eax

    ; Verificar se o arquivo de entrada foi aberto com sucesso
    cmp inputHandle, INVALID_HANDLE_VALUE
    je erroDe

    ; Abrir o arquivo de saída
    invoke CreateFile, addr outputFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov outputHandle, eax

    ; Verificar se o arquivo de saída foi aberto com sucesso
    cmp outputHandle, INVALID_HANDLE_VALUE
    je erroDe

    ; Arquivo aberto com sucesso
    invoke ReadFile, inputHandle, addr buffer, bufferSize, addr readCount, NULL
    cmp readCount, 0
    je nenhum_dadoDe

    ; Loop para processar o arquivo em porções de 512 bytes
    process_loopDe:
        ; Colocar a string lida do arquivo na variável modifiedString e adicionar o número de soma a cada caractere
        mov edi, offset buffer           ; Endereço do buffer de entrada
        mov esi, offset modifiedString   ; Endereço da variável modifiedString
        mov ecx, readCount               ; Número de bytes lidos

        modify_loopDe:
            mov al, [edi]   ; Caractere atual
            sub al, bl      ; Adicionar número de soma ao caractere
            mov [esi], al   ; Armazenar o caractere modificado na variável modifiedString

            inc edi         ; Avançar para o próximo caractere do buffer de entrada
            inc esi         ; Avançar para o próximo caractere da modifiedString
            dec ecx         ; Decrementar o contador de repetições

            cmp ecx, 0      ; Verificar se o contador chegou a zero
            jne modify_loopDe ; Saltar de volta para modify_loopDe se o contador for diferente de zero

        ; Escrever a string modificada no arquivo de saída
        invoke WriteFile, outputHandle, addr modifiedString, readCount, addr writeCount, NULL

        ; Verificar se há mais dados a serem lidos
        cmp readCount, bufferSize
        je continue_loopDe

        ; Sair do loop se não há mais dados a serem lidos
        jmp end_loopDe

    continue_loopDe:
        ; Ler a próxima porção do arquivo de entrada
        invoke ReadFile, inputHandle, addr buffer, bufferSize, addr readCount, NULL
        cmp readCount, 0
        jne process_loopDe

    end_loopDe:
    ; Fechar os handles dos arquivos
    invoke CloseHandle, inputHandle
    invoke CloseHandle, outputHandle

    mov esp, ebp
    pop ebp
    ret

    erroDe:
    ; Exibir mensagem de erro
    invoke WriteConsole, outputHandle, addr errorPrompt, sizeof errorPrompt, addr writeCount, NULL

    nenhum_dadoDe:
        ; Exibir mensagem de arquivo vazio
        invoke WriteConsole, outputHandle, addr emptyPrompt, sizeof emptyPrompt, addr writeCount, NULL
    
        ; Fechar os handles dos arquivos
        invoke CloseHandle, inputHandle
        invoke CloseHandle, outputHandle


start:
    invoke ClearScreen
    
    ; Obter handle de entrada padrão
    push STD_INPUT_HANDLE
    call GetStdHandle
    mov inputHandle, eax

    ; Obter handle de saída padrão
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov outputHandle, eax
;--------------------------- Exibe Menu
    invoke WriteConsole, outputHandle, addr titulo, sizeof titulo, addr writeCount, NULL
    invoke WriteConsole, outputHandle, addr textCod, sizeof textCod, addr writeCount, NULL
    invoke WriteConsole, outputHandle, addr textDecod, sizeof textDecod, addr writeCount, NULL
    invoke WriteConsole, outputHandle, addr TextSair, sizeof TextSair, addr writeCount, NULL
    
;--------------------------- Ler opção Menu
    invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr readCount, NULL
    invoke StrLen, addr inputString
    mov tamanho_string, eax

    ;--------------Remove quebra de linha
    mov esi, offset inputString ; Armazenar apontador da string em esi
    proximo:
    mov al, [esi] ; Mover caractere atual para al
    inc esi ; Apontar para o proximo caractere
    cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
    jne proximo
    dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
    xor al, al ; ASCII 0, terminado de string
    mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

    ;----------transforma string em inteiro
    invoke atodw, addr inputString

    ;--------Verifica opção selecionada
    cmp eax, numCod
    je cod
    cmp eax, numDec
    je deco
    jmp fim_programa
;---------------------------Label cod    
    cod:
        ; Exibir prompt para o usuário para o nome do arquivo de entrada
        invoke WriteConsole, outputHandle, addr promptInput, sizeof promptInput, addr writeCount, NULL

        ; Ler o nome do arquivo de entrada
        invoke ReadConsole, inputHandle, addr inputFile, sizeof inputFile, addr writeCount, NULL

        ;--------------Remove quebra de linha
        mov esi, offset inputFile ; Armazenar apontador da string em esi
        proximoIn:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoIn
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Exibir prompt para o usuário para o nome do arquivo de saída
        invoke WriteConsole, outputHandle, addr promptOutput, sizeof promptOutput, addr writeCount, NULL

        ; Ler o nome do arquivo de saída
        invoke ReadConsole, inputHandle, addr outputFile, sizeof outputFile, addr writeCount, NULL

        ;--------------Remove quebra de linha
        mov esi, offset outputFile ; Armazenar apontador da string em esi
        proximoOut:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoOut
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Exibir prompt para o usuário para o número de soma
        invoke WriteConsole, outputHandle, addr promptNumber, sizeof promptNumber, addr writeCount, NULL

        ; Ler o número de soma
        invoke ReadConsole, inputHandle, addr buffer, bufferSize, addr writeCount, NULL

                ;--------------Remove quebra de linha
        mov esi, offset buffer ; Armazenar apontador da string em esi
        proximoNum:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoNum
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Converter o número lido em inteiro
        invoke atodw, addr buffer
        mov ebx, eax   ; Armazenar o número de soma em EBX

        ; Chamar a função codificar com os parâmetros adequados
        push offset inputFile     ; Passar o endereço do nome do arquivo de entrada
        push offset outputFile    ; Passar o endereço do nome do arquivo de saída
        push ebx                  ; Passar o número de soma
        call codificar
        jmp start
;---------------------------Label deco
    deco:
        ; Exibir prompt para o usuário para o nome do arquivo de entrada
        invoke WriteConsole, outputHandle, addr promptInput, sizeof promptInput, addr writeCount, NULL

        ; Ler o nome do arquivo de entrada
        invoke ReadConsole, inputHandle, addr inputFile, sizeof inputFile, addr writeCount, NULL

        ;--------------Remove quebra de linha
        mov esi, offset inputFile ; Armazenar apontador da string em esi
        proximoInDe:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoInDe
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Exibir prompt para o usuário para o nome do arquivo de saída
        invoke WriteConsole, outputHandle, addr promptOutput, sizeof promptOutput, addr writeCount, NULL

        ; Ler o nome do arquivo de saída
        invoke ReadConsole, inputHandle, addr outputFile, sizeof outputFile, addr writeCount, NULL

        ;--------------Remove quebra de linha
        mov esi, offset outputFile ; Armazenar apontador da string em esi
        proximoOutDe:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoOutDe
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Exibir prompt para o usuário para o número de soma
        invoke WriteConsole, outputHandle, addr promptNumber, sizeof promptNumber, addr writeCount, NULL

        ; Ler o número de soma
        invoke ReadConsole, inputHandle, addr buffer, bufferSize, addr writeCount, NULL

                ;--------------Remove quebra de linha
        mov esi, offset buffer ; Armazenar apontador da string em esi
        proximoNumDe:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximoNumDe
        dec esi ; Apontar para caractere anterior, onde o CR foi encontrado
        xor al, al ; ASCII 0, terminado de string
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; Converter o número lido em inteiro
        invoke atodw, addr buffer
        mov ebx, eax   ; Armazenar o número de soma em EBX

        ; Chamar a função decodificar com os parâmetros adequados
        push offset inputFile     ; Passar o endereço do nome do arquivo de entrada
        push offset outputFile    ; Passar o endereço do nome do arquivo de saída
        push ebx                  ; Passar o número de soma
        call decodificar
        jmp start

fim_programa:   
    invoke ExitProcess, 0
end start