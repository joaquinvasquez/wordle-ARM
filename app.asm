.data
	archivo_palabras: .asciz "palabras.txt"
	archivo_ranking: .asciz "ranking.txt"
	caracter_leido: .byte 0

        palabra_seleccionada:  .space 10, 0x00 // 10 bytes con valor nulo para luego escribir la palabra
	longitud_palabra: .byte 0
	palabra_usuario: .space 10

	intentos: .int 5
	puntaje_jugador: .space 2
	puntaje_jugador_char: .space 2
	ranking1: .space 20, 0x00
	ranking2: .space 20, 0x00
	ranking3: .space 20, 0x00

        msj_inicio: .ascii "--- La palabra a adivinar tiene 0 caracteres ---"
	msj_ingresar: .ascii "Ingrese una palabra: "
	msj_ganador: .ascii "FELICIDADES, GANASTE!!!"
 	msj_perdedor: .ascii "PERDISTE :(" 
	msj_pedir_nombre: .ascii "Ingresa tu nombre: "
	msj_ranking:.ascii "--- Ranking ---\n\n"
	msj_reiniciar: .ascii "\nQueres volver a jugar? y/n: " 
        salto_linea: .asciz "\n"
	nombre_jugador: .space 10, 0x00
        rta_reiniciar: .space 2

        // codigo de colores
	color_verde: .asciz "\033[32m"
	color_amarillo: .asciz "\033[33m"
	color_rojo: .asciz "\033[31m"
	color_reset: .asciz "\033[37m"

	// RANDOM
	seed: .word 1
	const1: .word 1103515245
	const2: .word 12345
	numero: .word 0

.text
imprimir:
        .fnstart
		// recibe por parámetros r1: puntero al mensaje, r2: cant de caracteres y r3: flag para imprimir \n al final
		push {r7}
		push {r0}
        	mov r7, #4	// imprime por pantalla
       		mov r0, #1	// salida de cadena
	        swi 0		// llamada al sistema
		cmp r3, #0xa
		bne finImprimir
		push {r2}
		push {r1}
       		mov r0, #1
		ldr r1, =salto_linea
		mov r2, #1
		swi 0
		pop {r1}
		pop {r2}
	finImprimir:
		pop {r0}
		pop {r7}
       		bx lr
        .fnend

ingresarPorTeclado:
	.fnstart
		// recibe por parámetros r1 y r2 con sus valores ya seteados
		push {r7}
		push {r0}
	        mov r7, #3	// ingresa cadena
	        mov r0, #0	// lectura de teclado
	        swi 0		// llamada al sistema
		pop {r0}
		pop {r7}
       		bx lr
	.fnend

seleccionarPalabra:
	// recibe como parametro r0: puntero al archivo, luego de obtener el random, ingresa al archivo y selecciona la palabra
	// 1. tener un numero (random) en un registro
	// 2. abrir archivo palabras como lectura
	// 3. si el numero es positivo, leer un caracter, cuando sea \n restar uno al numero
	// 4. si el numero es cero, no leo el caracter sino que guardo la palabra
	// 5. para guardar la palabra, leo un caracter, si es distinto de \n lo guardo en la palabra y sumo uno al contador, si es igual a \n voy a devolver
	// 6. cierra el archivo y devuelvo en r0 la palabra y en r1 la longitud
	.fnstart
		// 1
		mov r3, #1
		// 2
		mov r1, #0
		mov r2, #0
		mov r7, #5
		swi 0
		// 3
		mov r2, #1
		mov r7, #3
		mov r5, r0
		ldr r1, =caracter_leido
	leerCaracter:
		mov r0, r5
		cmp r3, #0
		beq leerPalabra
		swi 0
		ldrb r8, [r1]
		cmp r8, #0xa
		bne leerCaracter
		sub r3, #1
		bal leerCaracter
	// 4
	leerPalabra:
		ldr r4, =palabra_seleccionada
	// 5
	leerCaracterPalabra:
		mov r0, r5
		swi 0
		ldrb r8, [r1]
		cmp r8, #0xa
		beq devolverPalabra
		strb r8, [r4, r3]
		add r3, #1
		bal leerCaracterPalabra
	// 6
	devolverPalabra:
		mov r0, r5
		mov r7, #6
		swi 0
		mov r0, r4
		mov r1, r3
		bx lr
	// devuelve r0: palabra y r1: longitud de la palabra a adivinar
	.fnend
		
mensajeInicial:
	// recibe r0: puntero a msj_inicial, r1: nuevo numero y r3 numero a cambiar
	.fnstart
		push {lr}
		push {r6}
		mov r2, #1
		mov r4, #0
		mov r6, r1
	leerCaracterMsj:
		cmp r4, r3
		beq reemplazarLongitud
		ldrb r4, [r0], #1
		bal leerCaracterMsj
	reemplazarLongitud:
		sub r0, #1
		strb r1, [r0]
		ldr r1, =msj_inicio
		mov r2, #48
		push {r3}
		mov r3, #0xa
		cmp r6, #0x30
		beq noImprimir
		bl imprimir
	noImprimir:
		pop {r3}
		pop {r6}
		pop {lr}
		bx lr
	.fnend

ingresarPalabra:
	.fnstart
		push {lr}
		// imprimir mensaje que pide palabra
 		ldr r1, =msj_ingresar
 		mov r2, #21
 		mov r3, #0
 		bl imprimir
 	        // entrada por teclado
 	        ldr r1, =palabra_usuario
		ldr r2, =longitud_palabra
		ldrb r2, [r2]
		sub r2, #0x30
		add r2, #1
 		bl ingresarPorTeclado
         	pop {lr}
		mov r0, r2
		bx lr
	// devuelve en r1: puntero a palabra_usuario
 	.fnend

compararPalabras:
	// recibe en r0: puntero a palabra seleccionada, r1: puntero a palabra usuario y r2: longitud
	.fnstart
		push {lr}
		mov r3, #0 // contador letras verificadas
		mov r8, #0 // contador letras verdes
	cicloCaracter:
		cmp r3, r2
		beq finPalabra

 		ldrb r6, [r0, r3]
        	ldrb r5, [r1, r3]

        	cmp r6, r5     // comparo el primer caracter de las dos cadenas 
        	beq imprimirLetraVerde   // si son iguales se pinta de verde

 		mov r4, #0    // inicializo en cero el contador
        cicloCaracterPalabra:
		ldrb r7, [r0, r4] //compruebo si existe el caracter en la cadena
		add r4, #1 // aumento el contador en uno
                cmp r7, r5
                beq imprimirLetraAmarilla // si existe la pinto de amarillo
		cmp r4, r2
                beq imprimirLetraRoja // si recorre toda la cadena y no la encuentra
		bal cicloCaracterPalabra

	imprimirLetraVerde:
		add r8, #1
		push {r0}
		push {r1}
		ldr r1, =palabra_usuario
		add r1, r3
		mov r0, r1
		ldr r1, =color_verde
		bl imprimirCaracterColor
		pop {r1}
		pop {r0}
		add r3, #1
		bal cicloCaracter
	imprimirLetraAmarilla:
		push {r0}
		push {r1}
		ldr r1, =palabra_usuario
		add r1, r3
		mov r0, r1
		ldr r1, =color_amarillo
		bl imprimirCaracterColor
		pop {r1}
		pop {r0}
		add r3, #1
		bal cicloCaracter
	imprimirLetraRoja:
		push {r0}
		push {r1}
		ldr r1, =palabra_usuario
		add r1, r3
		mov r0, r1
		ldr r1, =color_rojo
		bl imprimirCaracterColor
		pop {r1}
		pop {r0}
		add r3, #1
		bal cicloCaracter
		
	finPalabra:
		sub r0, r2, r8
		ldr r1, =salto_linea
		mov r2, #1
		mov r3, #0xa
		bl imprimir
		bl resetColor
		pop {lr}
		bx lr
	.fnend

imprimirCaracterColor:
	// recibe r1: puntero al color, r0: puntero al caracter
	.fnstart
		push {lr}
		push {r2}
		mov r2, #6
		bl imprimir
		mov r1, r0
		mov r2, #1
		bl imprimir
		pop {r2}
		pop {lr}
       		bx lr
	.fnend

resetColor:
	.fnstart
		push {lr}
		push {r1}
		push {r2}
		ldr r1, =color_reset
		mov r2, #6
		bl imprimir
		pop {r2}
		pop {r1}
		pop {lr}
       		bx lr
	.fnend

verificarGanador:
	// recibe en r0 flag victoria
	.fnstart
		push {lr}
		cmp r0, #0
		bne finGanador
		ldr r1, =msj_ganador
		mov r2, #23
		mov r3, #0xa
		bl imprimir
		// falta puntaje
		bal finGanador

	finGanador:
		pop {lr}
		bx lr
	// si gano devuelve 0 en r0
	.fnend

verificarPerdedor:
	// recibe como parametro r0: intentos restantes
	.fnstart
		push {lr}

		sub r0, #1
		ldr r1, =intentos
		str r0, [r1]

		cmp r0, #0
		bne finPerdedor
		ldr r1, =msj_perdedor
		mov r2, #11
		mov r3, #0xa
		bl imprimir
		bal finPerdedor

	finPerdedor:
		pop {lr}
		bx lr
	// devuelve en r0: intentos restantes actualizados
	.fnend


ingresarNombre:
	.fnstart
		push {lr}
         	ldr r1, =msj_pedir_nombre
         	mov r2, #19
		mov r3, #0
		bl imprimir

         	ldr r1, =nombre_jugador //donde se guarda la cadena ingresada
         	mov r2, #10   //leer * caracteres
		bl ingresarPorTeclado

         	ldr r1,=salto_linea
         	mov r2,#1
         	bl imprimir
		pop {lr}
		bx lr
	.fnend

nuevoJuego:
	.fnstart
		push {lr}
		ldr r0, =intentos
		mov r1, #5
		str r1, [r0]
		ldr r3, =longitud_palabra
		ldrb r3, [r3] // deja en r3 la longitud de la cadena de esta partida
		mov r1, #0x30 // deja en r1 el caracter 0
		ldr r0, =msj_inicio
		bl mensajeInicial
		ldr r1, =salto_linea
		mov r2, #1
		mov r3, #0xa
		bl imprimir
		pop {lr}
		bx lr
	.fnend

calcularPuntajePartida:
	.fnstart
		push {r0}
		push {r1}
		push {r2}
		push {r3}
		push {r4}
		push {r5}
		push {r6}

		ldr r5, =puntaje_jugador
		ldr r0, =longitud_palabra
		ldrb r0, [r0]  // largo de la palabra a adivinar
		sub r0, #0x30
		ldr r1, =intentos
		ldr r1, [r1]
		mul r0, r1 //multiplico la cantidad de intentos que me quedan por el length de la palabra
		str r0, [r5]
		mov r8, r0
		//pasarlo a caracteres
	
		mov r1, #10
		mov r2, #0
		mov r3, #0
		ldr r4, =puntaje_jugador_char
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

		pop {r6}
		pop {r5}
		pop {r4}
		pop {r3}
		pop {r2}
		pop {r1}
		pop {r0}
		
		mov r3, #0
		ldr r0, =ranking1
		ldr r1, =nombre_jugador
	guardarNombre:
		ldrb r2, [r1, r3]
		cmp r2, #0xa
		beq listoNombre
		strb r2, [r0, r3]
		add r3, #1
		bal guardarNombre
	listoNombre:
		mov r2, #':'
		strb r2, [r0, r3]
		mov r2, #0x20
		add r3, #1
		strb r2, [r0, r3]
		ldr r4, =puntaje_jugador_char
		ldrb r5, [r4], #1
		add r3, #1
		strb r5, [r0, r3]
		ldrb r5, [r4], #1
		add r3, #1
		strb r5, [r0, r3]
		mov r2, #0xa
		add r3, #1
		strb r2, [r0, r3]
		bx lr
	.fnend

contarCaracteresCadena:
	//recibe en r1: puntero a cadena
	.fnstart
		push {r2}
		mov r0, #0
	ciclo:
		ldrb r2, [r1, r0]
		cmp r2, #0
		beq finContador
		add r0, #1
		bal ciclo
	finContador:
		pop {r2}
		bx lr
	// devuelve en r0: cantidad de caracteres
	.fnend

generarRanking:
	.fnstart
	// 0 en ranking 1 guardar nombre_jugador: puntaje_jugador\n
	// 1 abrir archivo para lectura
	// 2 ir poniendo cada caracter en ranking 2 hasta \n
	// 3 repetir con ranking 3
	// 4 cerrar archivo y abrirlo para escritura
	// 5 mostrar por pantalla todos los rankigs
	// 6 escribir cada ranking en archivo
	// 7 cerrar archivo
		push {lr}
		// 0
		push {r0}
		bl calcularPuntajePartida	
		pop {r0}
		// 1
		mov r1, #0
		mov r2, #0
		mov r7, #5
		swi 0
		// 2
		mov r2, #1
		mov r7, #3
		mov r5, r0
		ldr r1, =caracter_leido
		ldr r6, =ranking2
	leerCaracterRk2:
		mov r0, r5
		swi 0
		ldrb r8, [r1]
		strb r8, [r6], #1
		cmp r8, #0xa
		bne leerCaracterRk2
		// 3
		ldr r6, =ranking3
	leerCaracterRk3:
		mov r0, r5
		swi 0
		ldrb r8, [r1]
		strb r8, [r6], #1
		cmp r8, #0xa
		bne leerCaracterRk3
		// 4
		mov r0, r5
		mov r7, #6
		swi 0
		ldr r0, =archivo_ranking
		mov r1, #1
		mov r2, #666
		mov r7, #5
		swi 0
		mov r5, r0
		// 5 y 6
		ldr r1, =ranking1
		bl contarCaracteresCadena	// devuelve en r0 la cantidad de caracteres de la cadena recibida en r1
		mov r2, r0
		bl imprimir
		mov r0, r5
		mov r7, #4
		swi 0
		ldr r1, =ranking2
		bl contarCaracteresCadena
		mov r2, r0
		bl imprimir
		mov r0, r5
		mov r7, #4
		swi 0
		ldr r1, =ranking3
		bl contarCaracteresCadena
		mov r2, r0
		bl imprimir
		mov r0, r5
		mov r7, #4
		swi 0
		// 7
		mov r0, r5
		mov r7, #6
		swi 0

		pop {lr}
		bx lr
	.fnend

.global main
main:
	ldr r0, =archivo_palabras
	bl seleccionarPalabra
	mov r12, r1
	ldr r2, =longitud_palabra
	add r1, #0x30
	str r1, [r2]
	ldr r0, =msj_inicio
	mov r3, #0x30
	bl mensajeInicial
	nuevoIntento:
		bl ingresarPalabra
		ldr r0, =palabra_seleccionada
		ldr r1, =palabra_usuario
		mov r2, r12 // le paso la longitud de la palabra a r2
		bl compararPalabras // devuelve en r0 la diferencia entre la longitud y las letras verdes
		bl verificarGanador
		cmp r0, #0
		beq mostrarPuntaje
		ldr r0, =intentos
		ldr r0, [r0]
		bl verificarPerdedor
		cmp r0, #0
		bne nuevoIntento
		bal reiniciarJuego
	mostrarPuntaje:
		// pide nombre, muestra ranking
		bl ingresarNombre
		ldr r1, =msj_ranking
		mov r2, #17
		bl imprimir
		ldr r0, =archivo_ranking
		bl generarRanking

	reiniciarJuego:
		//preguntar y reiniciar mensaje inicio etc
        	ldr r1, =msj_reiniciar
        	mov r2, #29 //tamaño de la  cadena
        	mov r3, #0
		bl imprimir
        	ldr r1, =rta_reiniciar //donde se guarda la cadena ingresada
	        mov r2, #2   //leer * caracteres
		bl ingresarPorTeclado
		ldrb r1, [r1]
		cmp r1, #'y'
		bne fin
		bl nuevoJuego
		bal main

fin:
        mov r7, #1  //salida al sistema
        swi 0



