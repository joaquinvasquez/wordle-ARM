.data 
incognita: .asciz "orga" 
largo_incognita: .byte 4
palabra: .asciz "boca" 
colores: .asciz "varv"
color_default: .asciz "\033[37m"
color_reset: .asciz "\033[0m"
color_rojo: .asciz "\033[31m"
color_verde: .asciz "\033[32m" 
color_amarillo: .asciz "\033[33m" 
color_azul: .asciz "\033[34m" 
salto_linea: .asciz "\n"
.text
//cambia el color del texto a imprimir
//entrada: r1 -> color al que se va a cambiar 

cambiar_color:
									//
	.fnstart
	push {lr}							//

	mov r2, #6      @largo del codigo de los colores		//
	bl imprimir
									//
	pop {lr}
	bx lr								//
	.fnend


//imprime por pantalla el mensaje que se encuentra en r1
//entradas: -> r1 mensaje a imprimir						//
//            -> r2 cantidad de caracteres a imprimir
imprimir:									//
	.fnstart
	push {lr}								//

	mov r0, #1 // Salida de cadena						//
	mov r7, #4 //Codigo de interrupciÃ³n: Imprimir por pantalla
	swi 0 // Llamada al sistema						//

	pop {lr}								//
	bx lr
	.fnend
//imprime cada letra que ingreso el usuario con su color correspondiente
imprimir_resultado:
	.fnstart
	push {lr}

	mov r3, #0           //iterador

	ciclo_imprimir_resultado:

		ldr r2, =colores
		ldrb r0, [r2,r3]            //obtengo la letra del color del siguiente caracter a imprimir
		ldr r4, =largo_incognita
		ldrb r4, [r4]			//largo de la cadena para saber cuando terminar de verificar
 		mov r4, #4


        //verifico que letra es para determinar el color
                cmp r0, #'r'
		beq letra_roja

		cmp r0, #'a'
		beq letra_amarilla

		cmp r0, #'v'
		beq letra_verde

        //dependiendo el color, selecciono el correspondiente del .data y luego imprimo el caracter correspondiente
		letra_roja:
			ldr r1,=color_rojo
			bl cambiar_color
			b imprimir_caracter

		letra_amarilla:
			ldr r1,=color_amarillo
			bl cambiar_color
			b imprimir_caracter

		letra_verde:
			ldr r1,=color_verde
			bl cambiar_color
			b imprimir_caracter


		//aca ya tengo el color que le corresponde a la letra
		imprimir_caracter:          //obtengo el caracter que se debe imprimir
			ldr r1, =palabra    //	@direccion de la palabra que ingreso e user
			add r1, r3	   //	@le agrego el iterador para llegar a la letra que estoy verificando
			mov r2, #1	  //	@cantidad de caracteres a imprimir
			bl imprimir	//	@imprimo el caracter


	               //aumento el itereador para pasar a la siguiente letra
			add r3, #1
			cmp r3, r4              //verifico si ya termino la letra para terminar la iteracion
			beq fin_imprimir_resultado

                	//reseteo color para que los lados no tengan colores
			ldr r1, =color_reset
			bl cambiar_color

                   	b ciclo_imprimir_resultado

	fin_imprimir_resultado:
		//reseteo color para que los lados no tengan colores
			ldr r1, =color_reset
			bl cambiar_color

			//imprimo el lado derecho del cuadrado
	//		ldr r1, =lado_der_letra
	//		mov r2, $largo_lado_der_letra
			bl imprimir

 
        //en caso de haber terminado de imprimir todos los caracteres, restablezco el color de impresion para evitar errores
		ldr r1, =color_default
		bl cambiar_color
		//salto de linea
		ldr r1, =salto_linea
		mov r2, #1
		bl imprimir

		//imprimo la parde de abajo de las letras 
//		bl imprimir_bordes_palabra

		pop {lr}
		bx lr
		.fnend


.global main
main:
	bl imprimir_resultado

mov r7, #1
swi 0


