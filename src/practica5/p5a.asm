%include "../../lib/pc_io.inc"

section .text
global _start

_start:

    ; imprimir cadena original
    mov edx, msg
    call puts

    ; reemplazar a por Z (direccionamiento directo)
    mov byte [msg], 'Z'

    ; imprimir cadena modificada
    mov edx, msg
    call puts

    mov eax,1
    int 0x80

section .data
msg db 'abcdefghijklmnopqrstuvwxyz0123456789',0xa,0