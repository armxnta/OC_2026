section .data

    msgInput db "Ingrese numero: "
    lenInput equ $-msgInput

    msgOriginal db 10,"Arreglo original",10
    lenOriginal equ $-msgOriginal

    msgSorted db 10,"Arreglo ordenado",10
    lenSorted equ $-msgSorted

    newline db 10

section .bss

    arreglo resd 5

    inputBuffer  resb 64
    outputBuffer resb 64

section .text
    global _start

_start:

    call capturar_arreglo

    ; Mostrar original

    mov eax, 4
    mov ebx, 1
    mov ecx, msgOriginal
    mov edx, lenOriginal
    int 80h

    call mostrar_arreglo

    ; Ordenar

    call ordenar_arreglo

    ; Mostrar ordenado

    mov eax, 4
    mov ebx, 1
    mov ecx, msgSorted
    mov edx, lenSorted
    int 80h

    call mostrar_arreglo

    ; Salir

    mov eax, 1
    xor ebx, ebx
    int 80h

capturar_arreglo:

    xor esi, esi

capture_loop:

    cmp esi, 5
    jge end_capture

    ; Mostrar mensaje

    mov eax, 4
    mov ebx, 1
    mov ecx, msgInput
    mov edx, lenInput
    int 80h

    ; Leer entrada

    mov eax, 3
    mov ebx, 0
    mov ecx, inputBuffer
    mov edx, 64
    int 80h

    ; ASCII -> entero

    mov edi, inputBuffer
    call atoi

    ; Guardar entero

    mov [arreglo + esi*4], eax

    inc esi
    jmp capture_loop

end_capture:
    ret

mostrar_arreglo:

    xor esi, esi

show_loop:

    cmp esi, 5
    jge end_show

    ; Obtener entero

    mov eax, [arreglo + esi*4]

    ; Convertir entero -> ASCII

    mov edi, outputBuffer
    call itoa

    ; Calcular longitud

    mov edi, outputBuffer
    xor edx, edx

count_length:

    cmp byte [edi], 0
    je print_number

    inc edi
    inc edx
    jmp count_length

print_number:

    ; Imprimir número

    mov eax, 4
    mov ebx, 1
    mov ecx, outputBuffer
    int 80h

    ; Salto línea

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 80h

    inc esi
    jmp show_loop

end_show:
    ret

ordenar_arreglo:

    xor esi, esi

outer_loop:

    cmp esi, 4
    jge end_sort

    mov ebx, esi

    mov edi, esi
    inc edi

inner_loop:

    cmp edi, 5
    jge swap_check

    mov eax, [arreglo + edi*4]

    cmp eax, [arreglo + ebx*4]
    jge continue_loop

    mov ebx, edi

continue_loop:

    inc edi
    jmp inner_loop

swap_check:

    cmp ebx, esi
    je next_i

    mov eax, [arreglo + esi*4]
    mov edx, [arreglo + ebx*4]

    mov [arreglo + esi*4], edx
    mov [arreglo + ebx*4], eax

next_i:

    inc esi
    jmp outer_loop

end_sort:
    ret


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