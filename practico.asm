.data   //lista de palabras
	archivo_palabras: .asciz "palabras.txt"
	caracter_leido: .space 199
	//msj inicial
        msj_inicio: .ascii "- La palabra a adivinar tiene "
        cod_caracteres: .space 2
	msj_final: .ascii " caracteres -\n"
	cant_caracteres:.space 2

	msj_ingresar: .ascii "Ingrese una palabra: "
	msj_reiniciar: .ascii "Quieres volver a jugar? y/n:" 
        rta_reiniciar: .ascii ""
	//palabra ingresada por usuario
	cadena: .space 14
	misIntentos: .int 0
	cant_verdes: .int 0
	msj_ganador: .ascii "!felicidades, has ganado!\n"
	msj_pedir_nombre: .ascii "Ingresa tu nombre: "

        //palabra a adivinar
        palabra_seleccionada:  .space 10, 0x00 // 10 bytes con valor nulo para luego escribir la palabra
	longitud_palabra: .int 0

        //codigo de colores
	color_reset: .asciz "\033[37m"
	color_rojo: .asciz "\033[31m"
	color_verde: .asciz "\033[32m"
	color_amarillo: .asciz "\033[33m"

        salto_linea: .asciz "\n"
 	msj_perdedor: .ascii "Perdiste\n" 

         //archivo de rankings
	archivo_rankings: .asciz "rankings.txt"
	rankings_leidos: .space 42

        //PUNTAJES

	 msj_puntaje: .ascii "Tu puntaje fue: "
	 puntaje_jugador: .space 4
         puntaje_jugador2: .space 4
	 puntaje_jugador3: .space 4

        //DECO nombres y PUNTAJE
         msj_rankings:.ascii "rankings:\n"
         nombre_jugador: .space 10
	 cod_puntaje: .space 3,0
	 puntos0: .ascii " puntos"

	 nombre_jugador2: .space 10
	 cod_puntaje2: .space 3,0
	 puntos2: .ascii " puntos"

	 nombre_jugador3: .space 10
	 cod_puntaje3: .space 3,0
         puntos3: .ascii " puntos"


	// RANDOM
	seed: .word 1
	const1: .word 1103515245
	const2: .word 12345
	numero: .word 0

.text

imprimir:
        .fnstart
		// recibe por parámetros r1 y r2 con sus valores ya seteados
        	mov r7, #4	// imprime por pantalla
       		mov r0, #1	// salida de cadena
	        swi 0		// llamada al sistema
       		bx lr
        .fnend

ingresarPorTeclado:
	.fnstart
		// recibe por parámetros r1 y r2 con sus valores ya seteados
	        mov r7, #3	// ingresa cadena
	        mov r0, #0	// lectura de teclado
	        swi 0		// llamada al sistema
       		bx lr
	.fnend

reiniciarIntentos:
        ldr r0,=cant_verdes
        mov r1,#0
        str r1,[r0]
        ldr r0,=misIntentos
        mov r1,#0
        str r1,[r0]
	b jugar

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

seleccionarPalabra:
	// recibe como parametro r0: puntero al archivo, luego de obtener el random, ingresa al archivo y selecciona la palabra
	.fnstart
		mov r8, #0
		mov r7, #0
		mov r6, r0
//		obtenerRandom
		mov r0, #15   // se puede cambiar el valor (entiendo que te genera un random entre 0y4 o 1y4)
		bl mysrand     //se usa una sola vez al principio del programa
		bl myrand // leo número aleatorio, queda en r0
		mov r5, r0
		//abrir archivo
		mov r7, #5
		ldr r0, =archivo_palabras
		mov r1, #0
		mov r2, #0
		swi 0
		cmp r0,#0
		blt error
		mov r6, r0
		//ir leyendolo de a un caracter, compararlo con 0, si es igual, restar 1 a random
		mov r7, #3
		ldr r1, =caracter_leido
		mov r2, #199
		swi 0
		//mostrar lo traído por pantalla
		mov r7,#4
		mov r0,#1
		mov r2, #199
		ldr r1, =caracter_leido
		swi 0
         	mov r5,#0
		mov r3,#0
		ldr r1,=caracter_leido
	leerCaracter:
		ldr r5, =palabra_seleccionada
		mov r4,#0
		//ldr r0,[r4]  //salto de linea
		ldrb r4,[r1,r3]
		strb r4,[r5,r3]
		cmp r4,#0x0a	// compara r5 con '\n'
		beq devolverPalabra    //swi 0	// si no es igual, lee un caracter nuevo
		add r8,#1
		add r3,#1
		b leerCaracter

	devolverPalabra:
		mov r1,#0
		mov r0,#0
		ldr r0,=cant_caracteres
		str r8,[r0]
	      	// salida por pantalla
		bl deco_cant_caracteres
		mov r2,#50
	        ldr r1, =msj_inicio	// falta recorrer msj_inicio y reemplazar la longitud de la palabra
        	push {lr}
		bl imprimir
        	pop {lr}
		//bx lr
		swi 0
	// devuelve r0: longitud de la palabra a adivinar
	.fnend

ingresarPalabra:
	.fnstart
		ldr r0,=cant_caracteres
		ldr r3,[r0]
		add r3, #1
	      	// salida por pantalla
		ldr r1, =msj_ingresar
		mov r2, #21
        	push {lr}
		bl imprimir
        	pop {lr}
		swi 0
	        // entrada por teclado
	        ldr r1, =cadena
	        mov r2,r3
        	push {lr}
		bl ingresarPorTeclado
        	pop {lr}

		mov r6,#0     // contador de caracteres
	        ldr r3,=cadena  //traigo cadena ingresa por el usuario
	        ldr r4,=palabra_seleccionada //traigo mi palabra
	.fnend

compara:
 	ldrb r8,[r3,r6]    // guardo el primer caracter de la palabra ingresada y muevo un lugar
        ldrb r5,[r4,r6]    // guardo el primer caracter de mi palabra y muevo un lugar
	b verificar

verificar:

        cmp r8,r5     // comparo el primer caracter de las dos cadenas 
        beq letra_verde   // si son iguales se pinta de verde
	cmp r8,r5
        bne comprobarAmarilla // la etiqueta pregunta si el caracter ingresado existe en nuestra cadena 

comprobarAmarilla:
        ldr r10,=palabra_seleccionada  //traigo la palabra a adivinar
 	mov r9,#0    // inicializo en cero el contador
        ciclo:
		ldrb r11,[r10,r9]//compruebo si existe el caracter en la cadena
                cmp r11,r8
                beq letra_amarilla // si existe la pinto de azul
		cmp r9,#4
                beq letra_roja // si recorre toda la cadena y no la encuentra la pinta de rojo
		add r9,#1 // aumento el contador en uno
		b ciclo//regreso al ciclo para comprobar en el siguiente caracter
letra_verde:
	ldr r1,=color_verde
        bl cambiar_color
	bl imprimir_caracter
comprobarGanador:
        ldr r0,=cant_verdes
        ldr r1,[r0]
	add r1,#1
        str r1,[r0]
        ldr r0,=cant_verdes
        ldr r1,[r0]
	ldr r0,=cant_caracteres
	ldr r2,[r0]
	add r2,#1
        cmp r1,r2
        beq ganaste
	b compara
letra_amarilla:
        ldr r1,=color_amarillo
	bl cambiar_color
	bl imprimir_caracter
	ldr r1,=color_reset //reseteo los colores
        bl cambiar_color
	b compara
letra_roja:
        ldr r1,=color_rojo
        bl cambiar_color
        bl imprimir_caracter
        ldr r1,=color_reset //reseteo los colores
        bl cambiar_color
	b compara

cambiar_color:
        .fnstart
        push {lr}

        mov r2, #6	// largo del codigo de los colores
        bl imprimir

        pop {lr}
        bx lr
        .fnend

imprimir_caracter:
	.fnstart
	push {lr}

	ldr r1,=cadena // cadena ingresada
        add r1,r6      // le sumo el iterador para llegar al caracter que estoy verificando
        mov r2,#1
        bl imprimir //imprimo el caracter
	ldr r1,=color_reset //reseteo los colores
        bl cambiar_color
	ldr r1,=cant_caracteres
	ldr r0,[r1]
	add r0,#1
        cmp r6,r0
        beq intentos
        add r6,#1

	pop {lr}
        bx lr
	b compara
	.fnend	// creo

salto:
	ldr r1,=salto_linea
        mov r2,#1
 	bl imprimir
	b intentos

ganaste:
	ldr r1,=color_reset //reseteo los colores
        bl cambiar_color

        mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #26 //tamaño de la  cadena
        ldr r1, =msj_ganador
        swi 0 //invoca la subrutina de SO
        b decodificarPuntos

deco_cant_caracteres:
    .fnstart
     push {lr}
	mov r5,#0
        ldr r5,=cant_caracteres
        ldr r3,[r5]

        mov r1,#10 //divisor
        mov r2,#0 //contador
        ldr r4,=cod_caracteres //acá vamos a enviar el puntaje codificado
        mov r0,r3
        mov r3,#0
        mov r6,#0
        deco_caracteres:
                        cmp r0,r1 //comparo el resultado de puntajes si es menor a diez
                        blt fin_deco_caracteres
                        cuenta:
                                add r2, #1
                                sub r0, r0, r1
                                cmp r0,r1
                                bge cuenta

                                mov r3,r0
                                mov r0,r2
                                mov r2,#0
                                add r6,#1
                                bal deco_caracteres
        fin_deco_caracteres:
                        add r6,#1
                        ldr r0,[r5]
        div:
                cmp r0,r1
                blt rest
        ciclo_div:
                add r2,#1
                sub r0,r0,r1
                cmp r0,r1
                bge ciclo_div
        rest:
              mov r3, r0
              mov r0,r2
              mov r2,#0
              add r3,#0x30
              sub r6,#1
              strb r3,[r4,r6]
              cmp r6,#0
              bgt div
     pop {lr}
     bx lr
     .fnend


decodificarPuntos:
	mov r5,#0
	ldr r5,=puntaje_jugador
	ldr r0, =cant_caracteres
	ldr r4,[r0]  // largo de la palabra a adivinar
	ldr r1,=misIntentos
	ldr r2,[r1]
	//add r2,#1
	mov r3,#5 //es la cantidad de intentos 
	sub r3,r2 //a 5 le resto la cantidad de intentos que voy
	mul r3,r4 //multiplico la cantidad de intentos que me quedan por el length de la palabra
	str r3,[r5]

	ldr r5,=puntaje_jugador
        ldr r0,[r5]
	mov r1,#10 //divisor
	mov r2,#0 //contador   
	ldr r4,=cod_puntaje //acá vamos a enviar el puntaje codificado
	mov r0,r3
	mov r3,#0
	mov r6,#0
	cuenta_caracteres:
			cmp r0,r1 //comparo el resultado de puntajes si es menor a diez
			blt fin_cuenta_caracteres
			ciclo_cuenta:
				add r2, #1
				sub r0, r0, r1
				cmp r0,r1
				bge ciclo_cuenta
	
				mov r3,r0
				mov r0,r2
				mov r2,#0
				add r6,#1
				bal cuenta_caracteres
	fin_cuenta_caracteres:
			add r6,#1
			ldr r0,[r5]
	division:
		cmp r0,r1
		blt resto
	ciclo_dividir:
		add r2,#1
		sub r0,r0,r1
		cmp r0,r1
		bge ciclo_dividir
	resto:
	      mov r3, r0
	      mov r0,r2
	      mov r2,#0
	      add r3,#0x30
	      sub r6,#1
	      strb r3,[r4,r6]
	      cmp r6,#0
	      bgt division
	b calcular_rankings

calcular_rankings:
                //mover los puntos del primero al segundo y segundo al tercero, se libera el primer lugar
                ldr  r1,=cod_puntaje3
                ldr  r2,=cod_puntaje2
                ldr  r3,[r2]
                str  r3,[r1]
                ldr  r1,=cod_puntaje
                ldr  r3,[r1]
                str  r3,[r2]
                //mover los nombres de los jugadores un lugar
                ldr r1,=nombre_jugador3
                ldr r2,=nombre_jugador2
                ldr r3,[r2]
                str r3,[r1]
                ldr r1,=nombre_jugador
                ldr r3,[r1]
                str r3,[r2]
                b puntos


puntos:
	ldr r1,=cod_puntaje
	ldr r2,[r1]

	mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #16 //tamaño de la  cadena
        ldr r1, =msj_puntaje
        swi 0 //invoca la subrutina de SO

	mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #2 //tamaño de la  cadena
        ldr r1, =cod_puntaje
        swi 0 //invoca la subrutina de SO

        ldr r1,=salto_linea
        mov r2,#1
        bl imprimir
        b ingresarNombre


ingresarNombre:
	 mov r7, #4 //salida por pantalla
         mov r0, #1 //salida de cadena
         mov r2, #19 //tamaño de la  cadena
         ldr r1, =msj_pedir_nombre
         swi 0 //invoca la subrutina de SO

         mov r7, #3   //lectura de teclado
         mov r0, #0   //ingresa cadena
         mov r2, #9   //leer * caracteres
         ldr r1, =nombre_jugador //donde se guarda la cadena ingresada
         swi 0

         ldr r1,=salto_linea
         mov r2,#1
         bl imprimir
  	 b traer_rankings

traer_rankings:
	mov r7, #5 // Abrir archivo
        ldr r0, =archivo_rankings // puntero al nombre del archivo
 // en r0 devuelve el descriptor
        mov r1, #2 // 0: Lectura, 1: Escritura 2: lectura/escritura
        mov r2, #0 // Permisos (0666 en octal rw para todos, son 
// permisos de linux), se pone 0 en caso de lectura.
        swi 0 // SysCall
 // —-- Vemos cómo resultó. ¿Se pudo abrir?----------------
        cmp r0, #0 // ¿pudimos abrir el archivo?
        blt error // si es menor, negativo, hubo error
        mov r6, r0
	mov r7, #3 // lectura del archivo, porque r0 contiene el descriptor.
        ldr r1, =rankings_leidos // donde poner el contenido del archivo leído.
        mov r2, #42 // cantidad de caracteres a leer.
        swi 0
	mov r0, r6 // ponemos en r0 descriptor
        mov r7, #6 // Cerramos archivo abierto
        swi 0
	b mostrarRankings



mostrarRankings:

         mov r7, #4 //salida por pantalla
         mov r0, #1 //salida de cadena
         mov r2, #10 //tamaño de la  cadena
         ldr r1, =msj_rankings
         swi 0 //invoca la subrutina de SO


         mov r7, #4 //salida por pantalla
         mov r0, #1 //salida de cadena
         mov r2, #42 //tamaño de la  cadena
         ldr r1, =rankings_leidos
         swi 0 //invoca la subrutina de SO

	 ldr r1,=salto_linea
         mov r2,#1
         bl imprimir

	 mov r7, #4 //salida por pantalla
         mov r0, #1 //salida de cadena
         mov r2, #4 //tamaño de la  cadena
         ldr r1, =nombre_jugador2
         swi 0 //invoca la subrutina de SO

         ldr r1,=salto_linea
         mov r2,#1
         bl imprimir

	 mov r7, #4 //salida por pantalla
         mov r0, #1 //salida de cadena
         mov r2, #8 //tamaño de la  cadena
         ldr r1, =nombre_jugador3
         swi 0 //invoca la subrutina de SO

         ldr r1,=salto_linea
         mov r2,#1
         bl imprimir
       b fin


volverIntentar:

        mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #10 //tamaño de la  cadena
        ldr r1, =msj_perdedor
        swi 0 //invoca la subrutina de SO
	b intentar

intentar:
	mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #28 //tamaño de la  cadena
        ldr r1, =msj_reiniciar
        swi 0 //invoca la subrutina de SO

	mov r7, #3   //lectura de teclado
        mov r0, #0   //ingresa cadena
        mov r2, #2   //leer * caracteres
        ldr r1, =rta_reiniciar //donde se guarda la cadena ingresada
        swi 0
	b volverAJugar

volverAJugar:
       ldr r1,=rta_reiniciar
       ldrb r2,[r1,#0]
       cmp r2,#0x79
       beq reiniciarIntentos
       b fin

fin:
        mov r7, #1  //salida al sistema
        swi 0

.global main
main:
	jugar:
	ldr r0, =archivo_palabras
	bl seleccionarPalabra //recibe en r0 la longitud de la palabra, se pasa como parametro a ingresarPalabra
	mov r10, r0
	bl ingresarPalabra
	intentos:
		ldr r0,=cant_verdes
	       	mov r1,#0
		str r1,[r0]
		ldr r0,=misIntentos
	        ldr r1,[r0]
		add r1,#1
		str r1,[r0]
		ldr r0,=misIntentos
		ldr r1,[r0]
	        cmp r1,#5
	        beq volverIntentar
	        b ingresarPalabra












