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

capture_loop:

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
    jl capture_loop

    ret

mostrar_arreglo:

    xor edi, edi

show_loop:

    mov eax, [arreglo + edi*4]

    mov edi, outputBuffer
    call itoa

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

    inc edi

    cmp edi, 5
    jl show_loop

    ret

ordenar_arreglo:

    mov edi, 0

outer_loop:

    mov ebx, edi
    mov edx, edi
    inc edx

inner_loop:

    cmp edx, 5
    jge swap_check

    mov eax, [arreglo + edx*4]

    cmp eax, [arreglo + ebx*4]
    jge continue_loop

    mov ebx, edx

continue_loop:

    inc edx
    jmp inner_loop

swap_check:

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
