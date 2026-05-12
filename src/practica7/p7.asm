section .data

    mensajeEntrada db "Ingresar un numero: ",0
    mensajeResultado db "Resultado convertido: ",0
    salto db 10

section .bss

    bufferEntrada resb 64
    bufferSalida  resb 64
    numero        resd 1

section .text
    global _start

_start:

    ;mostrar mensaje
    mov eax, 4
    mov ebx, 1
    mov ecx, mensajeEntrada
    mov edx, 20
    int 80h

    ;leer entrada
    mov eax, 3
    mov ebx, 0
    mov ecx, bufferEntrada
    mov edx, 64
    int 80h

    ;atoi
    mov esi, bufferEntrada
    call atoi

    mov [numero], eax

    ;itoa
    mov eax, [numero]
    mov edi, bufferSalida
    call itoa

    ;mostrar resultado
    mov eax, 4
    mov ebx, 1
    mov ecx, mensajeResultado
    mov edx, 22
    int 80h

    ;numero convertido
    mov eax, 4
    mov ebx, 1
    mov ecx, bufferSalida
    mov edx, 64
    int 80h

    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 80h

    mov eax, 1
    xor ebx, ebx
    int 80h

atoi:
    xor eax, eax
    xor ebx, ebx

ignorar_espacios:
    mov cl, [esi]

    cmp cl, ' '
    je avanzar

    cmp cl, 9
    je avanzar

    jmp revisar_signo

avanzar:
    inc esi
    jmp ignorar_espacios

revisar_signo:
    mov cl, [esi]

    cmp cl, '-'
    jne revisar_positivo

    mov bl, 1
    inc esi
    jmp convertir

revisar_positivo:
    cmp cl, '+'
    jne convertir

    inc esi

convertir:
    mov cl, [esi]

    cmp cl, '0'
    jb terminar_atoi

    cmp cl, '9'
    ja terminar_atoi

    sub cl, '0'

    imul eax, eax, 10

    movzx ecx, cl
    add eax, ecx

    inc esi
    jmp convertir

terminar_atoi:
    cmp bl, 1
    jne return

    neg eax

return:
    ret

itoa:
    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jge iniciar_conversion

    mov byte [edi], '-'
    inc edi
    neg eax

iniciar_conversion:

division:
    xor edx, edx
    div ebx

    add edx, '0'

    push edx
    inc ecx

    cmp eax, 0
    jne division

escribir_digitos:
    pop eax
    mov [edi], al

    inc edi
    loop escribir_digitos
    mov byte [edi], 0

    ret
