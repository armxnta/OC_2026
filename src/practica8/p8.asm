section .data

    msgInput db "Ingrese numero: ",0
    msgOriginal db "Arreglo original",10,0
    msgSorted db "Arreglo ordenado",10,0
    newline db 10

section .bss

    arreglo resd 5
    inputBuffer resb 64
    outputBuffer resb 64

section .text
    global _start

_start:

    mov esi, arreglo
    mov ecx, 5
    call capturar_arreglo

    mov eax, 4
    mov ebx, 1
    mov ecx, msgOriginal
    mov edx, 18
    int 80h

    mov esi, arreglo
    mov ecx, 5
    call mostrar_arreglo

    mov esi, arreglo
    mov ecx, 5
    call ordenar_arreglo

    mov eax, 4
    mov ebx, 1
    mov ecx, msgSorted
    mov edx, 18
    int 80h

    mov esi, arreglo
    mov ecx, 5
    call mostrar_arreglo

    mov eax, 1
    xor ebx, ebx
    int 80h

capturar_arreglo:

    xor edi, edi

loop_capturar:

    mov eax, 4
    mov ebx, 1
    mov ecx, msgInput
    mov edx, 17
    int 80h

    mov eax, 3
    mov ebx, 0
    mov ecx, inputBuffer
    mov edx, 64
    int 80h

    mov esi, inputBuffer
    call atoi

    mov [arreglo + edi*4], eax

    inc edi

    cmp edi, 5
    jl loop_capturar

    ret

mostrar_arreglo:

    xor esi, esi          ; CAMBIO: Usamos esi como indice (indice = 0)

loop_mostrar:

    mov eax, [arreglo + esi*4] ; CAMBIO: leemos usando esi

    mov edi, outputBuffer ; CAMBIO: itoa espera el buffer destino en edi, no en esi
    push esi              ; guarda indice
    call itoa
    pop esi               ; restaura indice

    mov eax, 4
    mov ebx, 1
    mov ecx, outputBuffer
    mov edx, 64
    int 80h

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 80h

    inc esi               ; CAMBIO: incrementamos esi
    cmp esi, 5            ; CAMBIO: comparamos esi
    jl loop_mostrar

    ret

ordenar_arreglo:

    mov edi, 0

outer_loop:

    mov ebx, edi
    mov edx, edi
    inc edx

inner_loop:

    cmp edx, 5
    jge check_cambio

    mov eax, [arreglo + edx*4]

    cmp eax, [arreglo + ebx*4]
    jge continuar

    mov ebx, edx

continuar:

    inc edx
    jmp inner_loop

check_cambio:

    cmp ebx, edi
    je next_i

    mov eax, [arreglo + edi*4]
    mov ecx, [arreglo + ebx*4]

    mov [arreglo + edi*4], ecx
    mov [arreglo + ebx*4], eax

next_i:

    inc edi

    cmp edi, 4
    jl outer_loop

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
