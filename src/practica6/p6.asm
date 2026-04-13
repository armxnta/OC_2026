%include "../../lib/pc_io.inc"  	; incluir declaraciones de procedimiento externos
								; que se encuentran en la biblioteca libpc_io.a

section	.text
	global _start       ;referencia para inicio de programa
	
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
    call puts

    mov al,[nlin]
    call putchar
    call putchar

	mov	eax, 1	    	; seleccionar llamada al sistema para fin de programa
	int	0x80        	; llamada al sistema - fin de programa

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
section	.data
    ncad db 0xa,'Cadena: ',0
    nlin db 0xa
    len db 64
    cad	times 64 db 0