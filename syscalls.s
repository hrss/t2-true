.set MAX_ALARMS, 0x08
.set MAX_CALLBACKS, 0x08

return:
	movs pc, lr

set_motor_speed:

 	push {r1}

	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r1, sp

	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

		mov r0, r1

		pop {r1}

		push {r1-r2, lr}
		ldmia r0, {r1-r2}

		mov r0, r1		@r0 e id
		mov r1, r2		@r1 e velocidade



  	cmp r0, #1              @averigua se a id do motor e valida
  	cmpne r0,#0
  	movne r0, #-1
		popne {r1-r2, lr}
		bne return

  	movmi r1, #-2           @confere se a velocidade e negativa
		popmi {r1-r2, lr}
		bmi return

  	cmp r1, #63             @confere se o valor da velocidade valesse mais que um bit
  	movgt r1, #-2
		popgt {r1-r2, lr}
		bgt return

  	cmp r0, #0		@se a cadeia de lacos rolar a funcao chama o hardware se tudo ok
		moveq r0, r1
  	bleq write_motor_0

  	cmp r0, #1
		moveq r0, r1
  	bleq write_motor_1	@r0 id e r1 velocidade

  	pop {r1-r2, lr}

  	movs pc, lr


set_motors_speed:

	@Guardando valor do r1 para poder salvar sp do usuáro
	push {r1}

	@ Mudando para o modo system
	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	@Salvando sp em r1
	mov r1, sp

	@Voltando para o modo supervisor
	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	@Colocando sp do usario em r0 e recuperando r1
	mov r0, r1
	pop {r1}

  @Guardando registradores que serão usados e pegando os parametros da pilha
	push {r1-r3, lr}
	ldmia r0, {r1-r2}

  @Comparando com a velocidade maxima e retornando erro caso seja maior para o motor 0
	cmp r1, #63
	movhi r0, #-1
	pophi {r1-r3, lr}
	bhi return

	@Comparando com a velocidade maxima e retornando erro caso seja maior para o motor 1
	cmp r2, #63
	movhi r0, #-2
	pophi {r1-r3, lr}
	bhi return

	mov r0, r1

	mov r1, r2

	bl write_both_motors				@chama a syscall set_motor_speed para o motor 0

	pop {r1-r3, lr}

	mov r0, #0 @Retorno quando está tudo certo
	movs pc, lr


read_sonar:
	push {r1}

	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r1, sp

	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	mov r0, r1

	pop {r1}

	push {r1, lr}
	ldmia r0, {r1}

	mov r0, r1

	cmp r0, #15
	movhi r0, #-1
	pophi {r1, lr}
	bhi return

	bl read_sonar_with_id

	pop {r1, lr}

	movs pc, lr


get_time:

	ldr r0,=CONTADOR
	ldr r0, [r0]

	movs pc, lr


set_time:
	push {r1}

	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r1, sp

	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	mov r0, r1

	pop {r1}
	ldmia r0, {r1}

	ldr r2,=CONTADOR
	str r1, [r2]

	mov r0, r1

	pop {r1-r2}

	movs pc, lr


set_alarm:

	push {r1}

	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r1, sp

	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	mov r0, r1

	pop {r1}
	push {r1-r5}
	ldmia r0, {r1-r2}

	mov r0, r1		@r0 e ponteiro
	mov r1, r2		@r1 e tempo do alarme

	ldr r2,=CONTADOR
	ldr r2, [r2]

	cmp r2, r1
	movhi r0, #-2
	pophi {r1-r5}
	bhi return

	ldr r2,=ALARMS
	ldr r2, [r2]

	cmp r2, #MAX_ALARMS
	moveq r0, #-1
	popeq {r1-r5}
	beq return

	ldr r3, =ALARMS_TIME_BASE
	mov r4, #0

add_alarm_while:

	cmp r4, #7			@inicia um while para encaixar o tempo do alarme na posicao certa do vetor de TEMPOS DO ALARME
	bgt end_alarm_while
	ldr r5, [r3, r4, lsl #2]

	cmp r5, #0
	streq r1, [r3, r4, lsl #2]
	ldreq r3, =ALARMS_FUNCTION_BASE		@ja aproveita e encaixa no mesmo lugar so que em ALARMS_FUNCTION_BASE o ponteiro da funcao necessaria p o caso
	streq r0, [r3, r4, lsl #2]
	beq end_alarm_while
	add r4, r4, #1
	b add_alarm_while

end_alarm_while:

	ldr r2, =ALARMS
	ldr r3, [r2]
	add r3, r3, #1
	str r3, [r2]

	pop {r1-r5}

	mov r0, #0

	movs pc, lr


register_proximity_callback:

	push {r1}

	mrs r0, CPSR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r1, sp

	mrs r0, CPSR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	mov r0, r1

	pop {r1}

	push {r1-r4}
	ldmia r0, {r1-r3}

	mov r0, r1			@r0 e sonar_id
	mov r1, r2			@r1 e limiar
	mov r2, r3			@r2 e ponteiro da funcao


	cmp r0, #15
	movhi r0, #-2
	pophi {r1-r4}
	bhi return

	ldr r3, =CALLBACKS
	ldr r3, [r3]

	cmp r3, #MAX_CALLBACKS
	movhi r0, #-1
	pophi {r1-r4}
	bhi return

	ldr r4, =CALLBACKS_SONAR_BASE	@vetor de sonares
	lsl r3, r3, #2			@posicao correta do sonar
	str r0, [r4, r3]

	ldr r4, =CALLBACKS_THRESHOLD_BASE	@guarda as limiares de cada callback
	str r1, [r4, r3]

	ldr r4, =CALLBACKS_FUNCTION_BASE	@guarda as limiares de cada callback
	str r2, [r4, r3]

	ldr r3, =CALLBACKS		@incrementa o valor em CALLBACKS
	ldr r4, [r3]
	add r4, r4, #1
	str r4, [r3]

	pop {r1-r4}
	mov r0, #0

	movs pc, lr
