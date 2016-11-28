.org 0x0
.section .iv,"a"

_start:

interrupt_vector:

    b RESET_HANDLER
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

		mov r0, #100
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
		.set GPIO_PSER, 0x8


		mov r0, #0b11111111111111100000000000111110 @Setando Gdir
		ldr r1, =GPIO_BASE
		str r0, [r1, #GPIO_GDIR]

		@Setar valor inicial do trigger e dos motor_write no dr


laco:
    b laco @@Setar pilhas e passar controle para o usuário

@Incrementando o contador
IRQ_HANDLER:
		push {r0-r12, lr}
		ldr r1, =GPT_CR		@Avisando que a interrupção foi recebida
		mov r0, #1
		str r0, [r1, #GPT_SR]

		ldr r1, =CONTADOR
		ldr r0, [r1]
		add r0, r0, #1
		str r0, [r1]

		ldr r1, =ALARMS
		ldr r1, [r1]
		add r1, r1, #-1

		while_alarms:
				cmp r1, #0
				blt end_while_alarms
				ldr r2, =ALARMS_TIME_BASE
				ldr r3, [r2, r1, lsl #2]

				cmp r3, r0
				bleq call_function
				add r1, r1, #-1
				b while_alarms
@Lembrar de colocar tempo igual a zero
		end_while_alarms:

		sub lr, lr, #4
		pop {r0-r12, lr}
		movs pc, lr

call_function:
		push {lr}
		ldr r4, =ALARMS_FUNCTION_BASE
		ldr r4, [r4, r1, lsl #4]

		mrs r0, CSPR
		and r0, r0, #0b11111111111111111111111111110000
		msr CPSR, r0

		bl r4
		mov r7, #23
		svc 0x0
end_call_function:
		pop {lr}
		mov pc, lr




@id em r0
read_sonar_with_id:
		ldr r1, =GPIO_BASE
		ldr r2, [r1]

		@Mascara para escrever o id do sonar no DR, no lugar certo
		mov r0, r0, lsl #2
		and r2, r2, #0b11111111111111111111111111000001
		add r0, r0, #2 @Acionando o trigger
		orr r2, r2, r0

		str r2, [r1]

		@Espera o valor da flag do DR ser 1
		wait_for_flag:
			ldr r0, [r1]
			and r2, r0, #1
			cmp r2, #0
			beq wait_for_flag

		and r0, r0, #0b00000000000000011111111111000000 @Mascara para a leitura do sonar
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




.data
CONTADOR:
 		.word 0x0
ALARMS:
		.word 0x0
ALARMS_FUNCTION_BASE:
		.wfill 8 0x0
ALARMS_TIME_BASE:
		.wfill 8 0x0
CALLBACKS:
		.word 0x0
CALLBACKS_SONAR_BASE:
		.wfill 8 0x0
CALLBACKS_THRESHOLD_BASE:
		.wfill 8 0x0
CALLBACK_FUNCTION_BASE:
		.wfill 8 0x0
