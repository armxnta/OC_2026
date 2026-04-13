%include "../../lib/pc_io.inc"

section .text
global _start

_start:                   

    call getch
    call itoa
    mov edx,ncad
    call puts

    mov bx,word[len]
    mov edx,cad
    call capturar

    mov al,[nlin]
    call putchar
    call puts        ; imprime original

    ; mayusculas
    mov edx,cad
    call mayusculas

    mov al,[nlin]
    call putchar
    call puts

    ; minusculas
    mov edx,cad
    call minusculas

    mov al,[nlin]
    call putchar
    call puts

    mov eax,1
    int 0x80


    capturar:
        push edx
        push cx
        mov cx,bx
        dec cx

    .ciclo: 
        call getch
        cmp al,127
        jne .guardar
        call borrar
        jmp .ciclo

    .guardar:
        call putchar
        mov [edx],al
        cmp al,0xa
        je .salir
        inc edx
        loop .ciclo

    .salir:
        mov byte[edx],0
        pop cx
        pop edx
        ret

    mayusculas:
        push edx

    .loop:
        mov al,[edx]
        cmp al,0
        je .fin

        cmp al,'a'
        jb .siguiente
        cmp al,'z'
        ja .siguiente

        sub al,32
        mov [edx],al

    .siguiente:
        inc edx
        jmp .loop

    .fin:
        pop edx
        ret

    minusculas:
        push edx

    .loop:
        mov al,[edx]
        cmp al,0
        je .fin

        cmp al,'A'
        jb .siguiente
        cmp al,'Z'
        ja .siguiente

        add al,32
        mov [edx],al

    .siguiente:
        inc edx
        jmp .loop

    .fin:
        pop edx
        ret


    borrar:
        push ax 
        mov al,0x8
        call putchar    
        mov al,' '
        call putchar
        mov al,0x8
        call putchar   
        pop ax
        ret 

    itoa:
        push bx
        mov bl,100
        mov ah,0
        div bl
        mov bx,ax
        add al,'0'
        call putchar
        mov al,ah
        add al,'0'
        call putchar
        pop bx
        ret


    section .data
        ncad db 0xa,'Cadena: ',0
        nlin db 0xa
        len db 64
        cad times 64 db 0