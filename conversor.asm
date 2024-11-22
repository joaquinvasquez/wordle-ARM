section .data
    numero db 123 ; Número a mostrar
    buffer db '00000$', 0// ; Buffer para almacenar el número convertido a ASCII

section .bss

section .text
    global _start

_start:
   // ; Convertir el número a ASCII
    mov ax, [numero]
    call int_to_ascii

    //; Mostrar el número en pantalla
    mov ah, 09h
    lea dx, [buffer]
    int 21h

    //; Salir del programa
    mov ah, 4Ch
    int 21h

int_to_ascii:
    //; Convertir el número en AX a una cadena ASCII en buffer
    mov cx, 10 //; Divisor (base 10)
    lea di, [buffer + 4] //; Apuntar al final del buffer
    mov byte [di], '$' //; Terminar la cadena con '$'
    dec di

convert_loop:
    xor dx, dx// ; Limpiar DX
    div cx //; AX / 10, el cociente en AX, el resto en DX
    add dl, '0' //; Convertir el resto a ASCII
    mov [di], dl //; Almacenar el carácter en el buffer
    dec di
    test ax, ax //; Verificar si el cociente es 0
    jnz convert_loop //; Si no es 0, continuar el bucle

    ret

