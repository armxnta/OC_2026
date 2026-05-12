section .data

    msgInput db "Ingrese un numero: ",0
    msgOutput db "Resultado: ",0
    salto db 10

section .bss

    inputBuffer  resb 64
    outputBuffer resb 64
    numero       resd 1

section .text
    global _start

_start:

    ; Mostrar mensaje
    mov eax, 4
    mov ebx, 1
    mov ecx, msgInput
    mov edx, 20
    int 80h

    ; Leer entrada
    mov eax, 3
    mov ebx, 0
    mov ecx, inputBuffer
    mov edx, 64
    int 80h

    ; Convertir ASCII a entero
    mov esi, inputBuffer
    call atoi

    mov [numero], eax

    ; Convertir entero a ASCII
    mov eax, [numero]
    mov edi, outputBuffer
    call itoa

    ; Mostrar resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, outputBuffer
    mov edx, 64
    int 80h

    ; Salto de linea
    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 80h

    ; Finalizar
    mov eax, 1
    xor ebx, ebx
    int 80h

atoi:

    xor eax, eax
    xor ebx, ebx

skip_spaces:

    mov cl, [esi]

    cmp cl, ' '
    je next_char

    cmp cl, 9
    je next_char

    jmp check_sign

next_char:
    inc esi
    jmp skip_spaces

check_sign:

    mov cl, [esi]

    cmp cl, '-'
    jne positive_check

    mov bl, 1
    inc esi
    jmp convert_loop

positive_check:

    cmp cl, '+'
    jne convert_loop

    inc esi

convert_loop:

    mov cl, [esi]

    cmp cl, '0'
    jb end_atoi

    cmp cl, '9'
    ja end_atoi

    sub cl, '0'

    imul eax, eax, 10

    movzx ecx, cl
    add eax, ecx

    inc esi
    jmp convert_loop

end_atoi:

    cmp bl, 1
    jne return_atoi

    neg eax

return_atoi:
    ret

itoa:

    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jge positive_number

    mov byte [edi], '-'
    inc edi
    neg eax

positive_number:

division_loop:

    xor edx, edx
    div ebx

    add edx, '0'

    push edx
    inc ecx

    cmp eax, 0
    jne division_loop

write_digits:

    pop eax
    mov [edi], al

    inc edi

    loop write_digits

    mov byte [edi], 0

    ret