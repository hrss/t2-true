@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@ Código que faz o robo virar se estiver perto de uma parede
@ Este codigo le os valores de 2 sonares frontais para decidir se o
@ robo deve virar ou seguir em frente.
@ 2 syscalls serao utilizadas para controlar o robo:
@   write_motors  (syscall de numero 124)
@                 Parametros:
@                       r0 : velocidade para o motor 0  (valor de 6 bits)
@                       r1 : velocidade para o motor 1  (valor de 6 bits)
@
@  read_sonar (syscall de numero 125)
@                 Parametros:
@                       r0 : identificador do sonar   (valor de 4 bits)
@                 Retorno:
@                       r0 : distancia capturada pelo sonar consultado (valor de 12 bits)
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


.text
.align 4
.globl _start

_start:                         @ main
loop:
        mov r0, #10              @ Carrega em r0 a velocidade do motor 0.
                                @ Lembre-se: apenas os 6 bits menos significativos
                                @ serao utilizados.
        mov r1, #10              @ Carrega em r1 a velocidade do motor 1.
        mov r7, #19            @ Identifica a syscall 124 (write_motors).
				push {r0-r1}
        svc 0x0                 @ Faz a chamada da syscall.
				pop {r0-r1}

        ldr r6, =800           @ r6 <- 1200 (Limiar para parar o robo)

        mov r0, #3              @ Define em r0 o identificador do sonar a ser consultado.
				push {r0}
        mov r7, #16            @ Identifica a syscall 125 (read_sonar).
        svc 0x0
        mov r5, r0              @ Armazena o retorno da syscall.
				pop {r1}

        mov r0, #4              @ Define em r0 o sonar.
				push {r0}
        mov r7, #16
        svc 0x0
				pop {r1}

        cmp r5, r0              @ Compara o retorno (em r0) com r5.
        bge min                 @ Se r5 > r0: Salta pra min
        mov r0, r5              @ Senao: r0 <- r5
min:


        cmp r0, r6              @ Compara r0 com r6
        blt turn_around                 @ Se r0 menor que o limiar: Salta para end

                                @ Senao define uma velocidade para os 2 motores


        b loop                  @ Refaz toda a logica


turn_around:                            @ Vira o robo (pra um lado so, hehe)
        mov r0, #63
        mov r1, #0
				push {r0-r1}
        mov r7, #19
        svc 0x0
				pop {r0-r1}

				ldr r0, =0x000000FF
				wait_a_little:
					add r0, #-1
					cmp r0, #0
					beq loop
					b wait_a_little

        b loop              @ volta pro loop
