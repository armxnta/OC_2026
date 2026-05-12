section .bss
    buffer_in resb 64      ; Reserva 64 bytes para la cadena de entrada
    buffer_out resb 64     ; Reserva 64 bytes para la cadena de salida

section .data
    msg_in db "Ingresa un numero: ", 0
    len_in equ $ - msg_in
    msg_out db "El numero convertido es: ", 0
    len_out equ $ - msg_out
    newline db 10          ; Salto de línea

section .text
    global _start

_start:
    ; --- IMPRIMIR MENSAJE DE ENTRADA ---
    mov eax, 4             ; syscall: sys_write
    mov ebx, 1             ; file descriptor: stdout
    mov ecx, msg_in        ; puntero al mensaje
    mov edx, len_in        ; longitud del mensaje
    int 0x80               ; interrupción del kernel

    ; --- LEER CADENA DEL USUARIO ---
    mov eax, 3             ; syscall: sys_read
    mov ebx, 0             ; file descriptor: stdin
    mov ecx, buffer_in     ; almacenar en buffer_in
    mov edx, 64            ; leer hasta 64 caracteres
    int 0x80

    ; --- LLAMAR A PROCEDIMIENTO ATOI ---
    mov esi, buffer_in     ; Parámetro: Dirección de inicio de cadena en ESI
    call ATOI              ; Retorna el número entero en EAX

    ; --- LLAMAR A PROCEDIMIENTO ITOA ---
    ; EAX ya contiene el número entero.
    mov edi, buffer_out    ; Parámetro: Dirección de inicio de cadena de salida
    mov ecx, 64            ; Parámetro: Longitud máxima
    call ITOA              ; Retorna la dirección en EDI (aunque ya la sabemos)

    ; --- IMPRIMIR MENSAJE DE SALIDA ---
    mov eax, 4             ; sys_write
    mov ebx, 1             ; stdout
    mov ecx, msg_out       
    mov edx, len_out       
    int 0x80

    ; --- IMPRIMIR EL NÚMERO CONVERTIDO (buffer_out) ---
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer_out
    mov edx, 64            ; (Podríamos calcular la longitud exacta, aquí usamos el maximo)
    int 0x80

    ; --- IMPRIMIR SALTO DE LÍNEA ---
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; --- TERMINAR PROGRAMA ---
    mov eax, 1             ; syscall: sys_exit
    xor ebx, ebx           ; código de salida 0
    int 0x80

ATOI:
    xor eax, eax           ; EAX = 0 (Acumulador del resultado)
    xor ebx, ebx           ; EBX = 0 (Bandera para el signo negativo, 0=Positivo, 1=Negativo)
    
.ignorar_espacios:         ; Ignora cualquier espacio en blanco inicial o tabulaciones
    mov cl, byte [esi]
    cmp cl, ' '            ; Compara con espacio
    je .siguiente_espacio
    cmp cl, 9              ; Compara con tabulación
    je .siguiente_espacio
    jmp .revisar_signo

.siguiente_espacio:
    inc esi
    jmp .ignorar_espacios

.revisar_signo:            ; Reconoce y aplica un único signo + o -
    cmp cl, '-'
    jne .revisar_positivo
    mov ebx, 1             ; Activar bandera de negativo
    inc esi
    jmp .convertir_digitos
.revisar_positivo:
    cmp cl, '+'
    jne .convertir_digitos
    inc esi                ; Si es '+', solo avanzar

.convertir_digitos:        ; Convierte los caracteres numéricos consecutivos
    mov cl, byte [esi]
    cmp cl, '0'            ; Se detiene si es menor que '0'
    jl .fin_atoi
    cmp cl, '9'            ; Se detiene si es mayor que '9'
    jg .fin_atoi
    
    sub cl, '0'            ; Convierte ASCII a valor numérico (ej. '3' - '0' = 3)
    imul eax, 10           ; EAX = EAX * 10
    movzx edx, cl          ; Extender CL a EDX rellenando con ceros
    add eax, edx           ; Sumar el nuevo dígito
    
    inc esi                ; Avanzar al siguiente carácter
    jmp .convertir_digitos

.fin_atoi:
    cmp ebx, 1             ; Revisar si la bandera de signo es 1 (negativo)
    jne .retorno_atoi
    neg eax                ; Aplicar complemento a 2 (hacerlo negativo)
.retorno_atoi:
    ret                    ; Retornar. El entero con signo está en EAX.


ITOA:
    push eax               ; Guardar registros para no afectarlos
    push ebx
    push edx
    push esi
    
    mov ebx, 10            ; Divisor = 10 (base 10)
    xor esi, esi           ; Contador de dígitos extraídos = 0
    
    cmp eax, 0
    jge .ciclo_division    ; Si es >= 0, ir directo a dividir
    
    neg eax                ; Si es negativo, hacerlo positivo temporalmente
    mov byte [edi], '-'    ; Colocar el signo '-' en la primera posición de la cadena
    inc edi                ; Avanzar el puntero de la cadena

.ciclo_division:           ; Realiza divisiones base 10
    xor edx, edx           ; Limpiar EDX antes de dividir (EDX:EAX / EBX)
    div ebx                ; EAX = Cociente, EDX = Residuo
    add dl, '0'            ; Convertir residuo numérico a carácter ASCII
    push dx                ; Guardar carácter en la pila (para invertir el orden después)
    inc esi                ; Incrementar contador de dígitos
    test eax, eax          ; ¿El cociente es 0?
    jnz .ciclo_division    ; Si no es 0, seguir dividiendo

.sacar_pila:
    pop dx                 ; Recuperar el último dígito guardado
    mov [edi], dl          ; Colocarlo en la cadena
    inc edi                ; Avanzar puntero
    dec esi                ; Decrementar contador
    jnz .sacar_pila        ; Si hay más dígitos, repetir

    mov byte [edi], 0      ; Añadir carácter nulo (\0) al final de la cadena
    
    pop esi
    pop edx
    pop ebx
    pop eax
    ret