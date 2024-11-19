.data
        mensaje: .ascii "ingresar 4 caracteres:\n"
	reintentar: .ascii "Quieres volver a jugar? y/n:" 
        respuestaUser: .ascii ""
	cadena: .space 10
	misIntentos: .int 0
	verificarVerdes: .int 0
	puntaje: .ascii "0"
	ganador: .ascii "Adivinaste la palabra\n"
        miPalabra:  .ascii "hola\n"
	color_reset: .asciz "\033[37m"
	color_rojo: .asciz "\033[31m"
	color_verde: .asciz "\033[32m"
	color_amarillo: .asciz "\033[33m"
	color_azul: .asciz "\033[34m"
        salto_linea: .asciz "\n"
	perdiste: .ascii "Perdiste\n"

.text
.global main

reiniciarIntentos:
        ldr r0,=verificarVerdes
        mov r1,#0
        str r1,[r0]
        ldr r0,=misIntentos
        mov r1,#0
        str r1,[r0]

ingresarPalabra:

      // -------- salida por pantalla ------

        mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #23 //tamaño de la  cadena
        ldr r1, =mensaje
        swi 0 //invoca la subrutina de SO

        //--------entrada por teclado-------

        mov r7, #3   //lectura de teclado
        mov r0, #0   //ingresa cadena
        mov r2, #5   //leer * caracteres
        ldr r1, =cadena //donde se guarda la cadena ingresada
        swi 0
        //
	mov r6,#0     // contador de caracteres
        ldr r3,=cadena  //traigo cadena ingresa por el usuario
        ldr r4,=miPalabra //traigo mi palabra

compara:
 	ldrb r8,[r3,r6]    // guardo el primer caracter de la palabra ingresada y muevo un lugar
        ldrb r5,[r4,r6]    // guardo el primer caracter de mi palabra y muevo un lugar
	b verificar

verificar:

        cmp r8,r5     // comparo el primer caracter de las dos cadenas 
        beq letra_verde   // si son iguales se pinta de verde
	cmp r8,r5
        bne comprobarAzul // la etiqueta pregunta si el caracter ingresado existe en nuestra cadena 

comprobarAzul:
        ldr r10,=miPalabra  //traigo la palabra a adivinar
 	mov r9,#0    // inicializo en cero el contador
         ciclo:
		ldrb r11,[r10,r9]//compruebo si existe el caracter en la cadena
                cmp r11,r8
                beq letra_azul // si existe la pinto de azul
		cmp r9,#4
                beq letra_roja // si recorre toda la cadena y no la encuentra la pinta de rojo
		add r9,#1 // aumento el contador en uno
		b ciclo//regreso al ciclo para comprobar en el siguiente caracter
letra_verde:
	 ldr r1,=color_verde
         bl cambiar_color
	 bl imprimir_caracter
comprobarGanador:
         ldr r0,=verificarVerdes
         ldr r1,[r0]
         add r1,#1
         str r1,[r0]
         ldr r0,=verificarVerdes
         ldr r1,[r0]
         cmp r1,#5
         beq ganaste
	 b compara
letra_azul:
        ldr r1,=color_azul
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
                                                                        //
        .fnstart
        push {lr}                                                       //

        mov r2, #6      //largo del codigo de los colores                //
        bl imprimir
                                                                        //
        pop {lr}
        bx lr                                                           //
        .fnend
imprimir:                                                                       //
        .fnstart
        push {lr}                                                               //

        mov r0, #1 // Salida de cadena                                          //
        mov r7, #4 //Codigo de interrupcion: Imprimir por pantalla
        swi 0 // Llamada al sistema                                             //

        pop {lr}                                                                //
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
        cmp r6,#5
        beq salto
        add r6,#1

	pop {lr}
        bx lr
	b compara

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
        mov r2, #23 //tamaño de la  cadena
        ldr r1, =ganador
        swi 0 //invoca la subrutina de SO


        mov r7, #1  //salida al sistema
        swi 0

volverIntentar:

        mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #10 //tamaño de la  cadena
        ldr r1, =perdiste
        swi 0 //invoca la subrutina de SO
	b intentar

intentar:
	mov r7, #4 //salida por pantalla
        mov r0, #1 //salida de cadena
        mov r2, #28 //tamaño de la  cadena
        ldr r1, =reintentar
        swi 0 //invoca la subrutina de SO

	mov r7, #3   //lectura de teclado
        mov r0, #0   //ingresa cadena
        mov r2, #2   //leer * caracteres
        ldr r1, =respuestaUser //donde se guarda la cadena ingresada
        swi 0
	b volverAJugar

volverAJugar:
       ldr r1,=respuestaUser
       ldrb r2,[r1,#0]
       cmp r2,#0x79
       beq reiniciarIntentos
       b fin

fin:
        mov r7, #1  //salida al sistema
        swi 0

main:
    b ingresarPalabra
    intentos:
	ldr r0,=verificarVerdes
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
