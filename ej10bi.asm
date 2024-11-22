	@--- REGISTROS ---
	@r0 ->
	@r1 ->
	@r2 ->
	@r3 ->
	@r4 ->
	@r5 ->
	@r6 ->
	@-----------------
.data
	numero: .int 123
	resultado: .space 20, 0
.text
.global main
main:
	ldr r5, =numero
	ldr r0, [r5]
	mov r1, #10
	mov r2, #0
	mov r3, #0
	ldr r4, =resultado
	mov r6, #0

cuenta_caracteres:
	cmp r0, r1
	blt fin_cuenta_caracteres
ciclo_cuenta:
	add r2, #1
	sub r0, r0, r1
	cmp r0, r1
	bge ciclo_cuenta
	
	mov r3, r0
	mov r0, r2
	mov r2, #0
	add r6, #1
	bal cuenta_caracteres
fin_cuenta_caracteres:
	add r6, #1
	ldr r0, [r5]

division:
	@--- REGISTROS ---
	@r0 -> dividendo
	@r1 -> divisor
	@r2 -> cociente
	@r3 -> resto
	@r4 -> resultado
	@-----------------
	cmp r0, r1
	blt resto
ciclo_dividir:
	add r2, #1
	sub r0, r0, r1
	cmp r0, r1
	bge ciclo_dividir
resto:
	mov r3, r0
	mov r0, r2
	mov r2, #0
	
	add r3, #0x30
	sub r6, #1
	strb r3, [r4, r6]
	cmp r6, #0
	bgt division

fin:
	mov r7, #1
	swi 0
