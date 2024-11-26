.global main
.data
seed:   .word 1          @ Almacena la semilla
const1: .word 1103515245 @ Constante multiplicadora
const2: .word 12345      @ Constante sumadora
contador: .word 0        @ Contador manual para variabilidad

.text
main:

    mov r7, #4           @ syscall: write
    mov r0, #1           @ Salida estándar
    mov r1, r0           @ Semilla combinada
    mov r2, #4           @ Tamaño del valor
    swi 0                @ Imprimir semilla para depuración

bucle:
    bl myrand            @ Generar un número aleatorio
    mov r4, r0           @ Guardar en r4 para depuración

    bl myrand            @ Generar otro número aleatorio
    mov r5, r0           @ Guardar en r5 para depuración
cmp_random:
    cmp r5,#10
    bgt dividir

    mov r7, #1           @ syscall: exit
    mov r0, #0           @ Código de retorno
    swi 0
dividir:
	mov r7,#10
	udiv r5,r7
	bal cmp_random
myrand:
    push {lr}            @ Guardar el registro de enlace
    mov r6, #0x7fff
    ldr r1, =seed        @ Dirección de la semilla
    ldr r0, [r1]         @ Cargar la semilla actual
    ldr r2, =const1
    ldr r2, [r2]         @ Constante multiplicadora
    mul r3, r0, r2       @ r3 = seed * const1
    ldr r0, =const2
    ldr r0, [r0]         @ Constante sumadora
    add r0, r3, r0       @ r0 = r3 + const2
    str r0, [r1]         @ Guardar la nueva semilla
    LSR r0, r0, #16      @ Desplazar 16 bits hacia la derecha
    AND r0, r0, r6  @ Aplicar máscara 0x7FFF
    pop {lr}             @ Restaurar el registro de enlace
    bx lr

mysrand:
    push {lr}            @ Guardar el registro de enlace
    ldr r1, =seed        @ Dirección de la semilla
    str r0, [r1]         @ Guardar la semilla inicial
    pop {lr}             @ Restaurar el registro de enlace
    bx lr

