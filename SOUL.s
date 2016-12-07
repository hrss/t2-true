.org 0x0
.section .iv,"a"

_start:

interrupt_vector:
    b RESET_HANDLER
.org 0x08
		b SVC_HANDLER
.org 0x18
    b IRQ_HANDLER


.org 0x100
.text

@ Zera o contador
ldr r2, =CONTADOR  @lembre-se de declarar esse contador em uma secao de dados!
mov r0,#0
str r0,[r2]

RESET_HANDLER:
    @Set interrupt table base address on coprocessor 15.
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    @@@.Setando o GPT
		.set GPT_CR, 0x53FA0000
		.set GPT_PR, 0x4
		.set GPT_IR, 0xC
		.set GPT_OCR1, 0x10
		.set GPT_SR, 0x08

		mov r0, #0x41
		ldr r1, =GPT_CR
		str r0, [r1]

		mov r0, #0
		str r0, [r1, #GPT_PR]

		ldr r0, =1000
		str r0, [r1, #GPT_OCR1]

		mov r0, #1
		str r0, [r1, #GPT_IR]



SET_TZIC:
    @ Constantes para os enderecos do TZIC
    .set TZIC_BASE,             0x0FFFC000
    .set TZIC_INTCTRL,          0x0
    .set TZIC_INTSEC1,          0x84
    .set TZIC_ENSET1,           0x104
    .set TZIC_PRIOMASK,         0xC
    .set TZIC_PRIORITY9,        0x424

    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE

    ldr	r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)

    mov	r0, #(1 << 7)
    str	r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3

    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov	r0, #1
    str	r0, [r1, #TZIC_INTCTRL]

    @instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled

SET_GPIO:
		.set GPIO_BASE, 0x53F84000 @ DR
		.set GPIO_GDIR, 0x4
		.set GPIO_PSR, 0x8


		ldr r0, =0b11111111111111000000000000111110 @Setando Gdir
		ldr r1, =GPIO_BASE
		str r0, [r1, #GPIO_GDIR]

		@Setar valor inicial do trigger e dos motor_write no dr

		@Setando as pilhas dos modos

		mrs r0, CPSR
		orr r0, r0, #0b11111 @System/User
		msr CPSR, r0

		ldr r0, =0x76000000
		mov sp, r0


		mrs r0, CPSR
		and r0, r0, #0b11111111111111111111111111110011 @Supervisor
		msr CPSR, r0

		ldr r0, =0x74000000
		mov sp, r0

		mrs r0, CPSR
		orr r0, r0, #0b11111
		and r0, r0, #0b11111111111111111111111111110010 @IRQ
		msr CPSR, r0

		ldr r0, =0x73005000
		mov sp, r0

		mrs r0, CPSR
		orr r0, r0, #0b11111
		and r0, r0, #0b11111111111111111111111111110111 @Abort
		msr CPSR, r0

		ldr r0, =0x73000000
		mov sp, r0

		mrs r0, CPSR
		orr r0, r0, #0b11111
		and r0, r0, #0b11111111111111111111111111111011 @Undefined
		msr CPSR, r0

		ldr r0, =0x72005000
		mov sp, r0

		mrs r0, CPSR
		orr r0, r0, #0b11111
		and r0, r0, #0b11111111111111111111111111110001 @FIQ
		msr CPSR, r0

		ldr r0, =0x71000000
		mov sp, r0

		mrs r0, CPSR
		orr r0, r0, #0b11111
		and r0, r0, #0b11111111111111111111111111110000 @IRQ
		msr CPSR, r0


		@Passando controle para o usuário
		ldr r0, =0x77802000
		blx r0


SVC_HANDLER:
	cmp r7, #16
	beq read_sonar
	cmp r7, #17
	beq register_proximity_callback
	cmp r7, #18
	beq set_motor_speed
	cmp r7, #19
	beq set_motors_speed
	cmp r7, #20
	beq get_time
	cmp r7, #21
	beq set_time
	cmp r7, #22
	beq set_alarm
	cmp r7, #23
	beq end_call_function

	movs pc, lr

@Incrementando o contador
IRQ_HANDLER:
		push {r0-r7, lr}
		ldr r1, =GPT_CR		@Avisando que a interrupção foi recebida
		mov r0, #1
		str r0, [r1, #GPT_SR]

		ldr r1, =CONTADOR
		ldr r0, [r1]
		add r0, r0, #1
		str r0, [r1]

		ldr r4, =ALARMS
		ldr r6, [r4]
    cmp r6, #0
    beq end_while_alarms
    mov r6, #7

		while_alarms:
				cmp r6, #0
				blt end_while_alarms

        ldr r2, =ALARMS_TIME_BASE
				ldr r3, [r2, r6, lsl #2]

				cmp r3, r0
        moveq r3, #0
        streq r3, [r2, r6, lsl #2]
        ldreq r3, [r4]
        addeq r3, r3, #-1
        streq r3, [r4]

				bleq call_function_alarms
				add r6, r6, #-1
				b while_alarms
        @Lembrar de colocar tempo igual a zero ao inicializar
		end_while_alarms:


    ldr r4, =CALLBACKS
    ldr r6, [r4]
		add r6, r6, #-1

    while_callbacks:
      cmp r6, #0
      blt end_while_callbacks

      ldr r3, =CALLBACKS_SONAR_BASE
      ldr r0, [r3, r6, lsl #2]

			bl read_sonar_with_id

			ldr r3, =CALLBACKS_THRESHOLD_BASE
			ldr r1, [r3, r6, lsl #2]
			cmp r0, r1

			bllt call_function_callbacks

		end_while_callbacks:

		sub lr, lr, #4
		pop {r0-r7, lr}
		movs pc, lr

call_function_alarms:
		push {lr}
		ldr r7, =ALARMS_FUNCTION_BASE
		ldr r7, [r7, r6, lsl #2]

		mrs r0, CPSR
		and r0, r0, #0b11111111111111111111111111110000
		msr CPSR, r0

		ldr lr, =return_from_function
		mov pc, r7

end_call_function:
		pop {lr}
		mov pc, lr

call_function_callbacks:
		push {lr}
		ldr r7, =CALLBACKS_FUNCTION_BASE
		ldr r7, [r7, r6, lsl #2]

		mrs r0, CPSR
		and r0, r0, #0b11111111111111111111111111110000
		msr CPSR, r0

		ldr lr, =return_from_function
		mov pc, r7

return_from_function:
		mov r7, #23
		svc 0x0


@id em r0
read_sonar_with_id:
		@mrs r1, CPSR
		@and r1, r0, #0b11111111111111111111111011111111
		@msr CPSR, r1

		ldr r1, =GPIO_BASE
		ldr r2, [r1]

		@Mascara para escrever o id do sonar no DR, no lugar certo
		mov r0, r0, lsl #2
		and r2, r2, #0b11111111111111111111111111000001
		orr r0, r0, #2 @Acionando o trigger
		orr r2, r2, r0
		str r2, [r1]

		ldr r0, =0x0000000F
		wait_to_trigger:
			add r0, r0, #-1
			cmp r0, #0
			beq finished_waiting
			b wait_to_trigger
		finished_waiting:

		mov r0, #0b11111111111111111111111111111101
		and r2, r2, r0

		str r2, [r1]

		@Espera o valor da flag do DR ser 1
		wait_for_flag:
			ldr r0, [r1]
			and r2, r0, #1
			cmp r2, #0
			beq wait_for_flag

		ldr r2, =0b00000000000000111111111111000000
		and r0, r0, r2 @Mascara para a leitura do sonar
		mov r0, r0, lsr #6
		mov pc, lr

@velocidade em r0
write_motor_0:
		ldr r1, =GPIO_BASE
		ldr r2, [r1]

		@Mascara para escrever o id do sonar no DR, no lugar certo
		mov r0, r0, lsl #19
		and r2, r2, #0b11111110000000111111111111111111
		orr r2, r2, r0
		str r2, [r1]

		mov pc, lr

write_motor_1:
		ldr r1, =GPIO_BASE
		ldr r2, [r1]

		@Mascara para escrever o id do sonar no DR, no lugar certo
		mov r0, r0, lsl #26
		and r2, r2, #0b00000001111111111111111111111111
		orr r2, r2, r0
		str r2, [r1]

		mov pc, lr

write_both_motors:

		ldr r3, =GPIO_BASE
		ldr r2, [r3]

		@Mascara para escrever o id do sonar no DR, no lugar certo
		mov r0, r0, lsl #19
		mov r1, r1, lsl #26
		and r2, r2, #0b00000001111111111111111111111111
		and r2, r2, #0b11111110000000111111111111111111
		orr r2, r2, r0
		orr r2, r2, r1
		str r2, [r3]

		mov pc, lr

.data
CONTADOR:
 		.word 0x0
ALARMS:
		.word 0x0
ALARMS_FUNCTION_BASE:
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
ALARMS_TIME_BASE:
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
CALLBACKS:
		.word 0x0
CALLBACKS_SONAR_BASE:
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
CALLBACKS_THRESHOLD_BASE:
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
CALLBACKS_FUNCTION_BASE:
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
		.word 0x0
