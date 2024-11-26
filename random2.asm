.data

seed: .word 1
const1: .word 1103515245
const2: .word 12345
numero: .word 0
.text


.global main

myrand:
  .fnstart
    push {lr}
    ldr r1, =seed @ leo puntero a semilla
    ldr r0, [ r1 ] @ leo valor de semilla
                ldr r2, =const1
    ldr r2, [ r2 ] @ leo const1 en r2
    mul r3, r0, r2 @ r3= seed * 1103515245
    ldr r0, =const2
    ldr r0, [ r0 ] @ leo const2 en r0
    add r0, r0, r3 @ r0= r3+ 12345
    str r0, [ r1 ] @ guardo en variable seed
/* Estas dos lí neas devuelven "seed > >16 & 0x7fff ".
Con un peque ño truco evitamos el uso del AND */
    LSL r0, # 1
    LSR r0, # 17
    pop {lr}
    bx lr
  .fnend

mysrand:
  .fnstart
    push {lr}
    ldr r1, =seed
    str r0, [ r1 ]
    pop {lr}
    bx lr
  .fnend
main:
/* Llamamos a mysrand con parámetro 42 */
  mov r0, # 42   // se puede cambiar el valor
  bl mysrand   //se usa una sola vez al principio del programa

bucle:
  bl myrand @ leo número aleatorio, queda en r0
  mov r4,r0
// bl myrand
//  mov r5,r0
/* Recuperamos registros y salimos */
  mov r7,#1
  swi 0
