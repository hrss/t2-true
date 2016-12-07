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
mov r7, #22
ldr r0, =turn_around
mov r1, #5
push {r0-r1}
svc 0x0
pop {r0-r2}
mov r7, #22
ldr r0, =turn_around2
mov r1, #100
push {r0-r1}
svc 0x0
pop {r0-r2}


loop:
        mov r0, #25              @ Carrega em r0 a velocidade do motor 0.
                                @ Lembre-se: apenas os 6 bits menos significativos
                                @ serao utilizados.
        mov r1, #25              @ Carrega em r1 a velocidade do motor 1.
        mov r7, #19            @ Identifica a syscall 124 (write_motors).
				push {r0-r1}
        svc 0x0                 @ Faz a chamada da syscall.
				pop {r0-r1}


				ldr r0, =0x0002FFFF
				wait_a_little3:
					add r0, #-1
					cmp r0, #0
					b wait_a_little3



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

				ldr r0, =0x0002FFFF
				wait_a_little:
					add r0, #-1
					cmp r0, #0
					moveq pc, lr
					b wait_a_little

turn_around2:                            @ Vira o robo (pra um lado so, hehe)
        mov r0, #0
        mov r1, #63
				push {r0-r1}
        mov r7, #19
        svc 0x0
				pop {r0-r1}

				ldr r0, =0x0002FFFF
				wait_a_little2:
					add r0, #-1
					cmp r0, #0
					moveq pc, lr
					b wait_a_little2
