section .data
    filename db "palabras.asm", 0   // ; Nombre del archivo con terminación null
    buffer db 256                // ; Buffer para almacenar los datos leídos
    buffer_len equ $ - buffer     //; Tamaño del buffer
    msg db "Contenido del archivo: ", 0
    newline db 10, 0             // ; Nueva línea

section .bss
    fd resb 4                     //; Descriptor de archivo (4 bytes)

section .text
    global _start

_start:
    //; Abrir el archivo
    mov eax, 5                    //; sys_open
    lea ebx, [filename]           //; Nombre del archivo
    mov ecx, 0                   // ; Modo de apertura (lectura: 0)
    int 0x80                      //; Llamada al sistema
    mov [fd], eax                 //; Guardar el descriptor del archivo

    //; Leer el archivo
    mov eax, 3                    //; sys_read
    mov ebx, [fd]                // ; Descriptor del archivo
    lea ecx, [buffer]             //; Dirección del buffer
    mov edx, buffer_len           //; Tamaño del buffer
    int 0x80                      //; Llamada al sistema

    //; Mostrar mensaje
    mov eax, 4                    //; sys_write
    mov ebx, 1                    //; Descriptor de salida (stdout)
    lea ecx, [msg]                //; Mensaje
    mov edx, 23                   //; Longitud del mensaje
    int 0x80                      //; Llamada al sistema

    //; Mostrar contenido del archivo
    mov eax, 4                   // ; sys_write
    mov ebx, 1                    //; Descriptor de salida (stdout)
    lea ecx, [buffer]             //; Contenido leído
    mov edx, eax                  //; Longitud leída previamente (en EAX)
    int 0x80                 
