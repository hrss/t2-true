set_motor_speed:

  mrs r0, CSPR
  orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp


	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1, r2, lr}
	ldmdb r0, {r1-r2}

	mov r0, r1		@r0 e id
	mov r1, r2		@r1 e velocidade



  	cmp r0, #1              @averigua se a id do motor e valida
  	cmpne r0,#0
  	mov r0, #-1


  	movmi r1, #-2           @confere se a velocidade e negativa


  	cmp r1, #63             @confere se o valor da velocidade valesse mais que um bit
  	movgt r1, #-2


  	cmp r0, #0		@se a cadeia de lacos rolar a funcao chama o hardware se tudo ok
  	bleq write_motor_0

  	cmp r0, #1
  	bleq write_motor_1	@r0 id e r1 velocidade

  	pop {r1-r2, lr}

  	movs pc, lr


set_motors_speed:

	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp


	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1, r2, lr}
	ldmdb r0, {r1-r3}

	cmp r0, 63
	movhi r0, #-1
	movshi pc, lr

	cmp r1, 63
	movhi r0, #-2
	movshi pc, lr

	mov r0, #0

	bl write_motor_0				@chama a syscall set_motor_speed para o motor 0

	mov r0, #1
	mov r1, r2

	bl write_motor_1



	pop {r1-r3, lr}

	movs pc, lr


read_sonar:

	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp


	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1, lr}
	ldmdb r0, {r1}

	mov r0, r1



	cmp r0, #15
	movhi r0, #-1
	movshi pc, lr

	bl read_sonar_with_id

	pop {r1, lr}

	movs pc, lr


get_time:

	ldr r0,=CONTADOR
	ldr r0, [r0]

	movs pc, lr


set_time:

	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1-r2}
	ldmdb r0, {r1}

	ldr r2,=CONTADOR
	stm r1, [r2]

	mov r0, r1

	pop {r1-r2}

	movs pc, lr


set_alarm:

	mrs r0, CSPR
  orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp


	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1-r3}
	ldmdb r0, {r1-r2}

	mov r0, r1		@r0 e ponteiro
	mov r1, r2		@r1 e tempo do alarme

	ldr r2,=CONTADOR
	ldr r2, [r2]

	cmp r2, r1
	movhi r0, #-2

	movshi pc, lr

	ldr r2,=ALARMS
	ldr r2, [r2]

	cmp r2, #MAX_ALARMS
	mov r0, #-1
	movseq pc, lr

	ldr r3, =ALARMS_FUNCTION_BASE	@vetor de funcoes de alarme
	mul r2, r2, #4			@posicao correta do ponteiro(respectiva funcao)
	str r0, [r3, r2]

	ldr r3, =ALARMS_TIME_BASE
	str r1, [r3, r2]

	ldr r2, =ALARMS
	ldr r3, [r2]
	add r3, r3, #1
	str r3, [r2]

	pop {r1-r3}

	mov r0, #0

	movs pc, lr


register_proximity_callback:

	mrs r0, CSPR
  orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1-r4}
	ldmdb r0, {r1-r3}

	mov r0, r1			@r0 e sonar_id
	mov r1, r2			@r1 e limiar
	mov r2, r3			@r2 e ponteiro da funcao


	cmp r0, #15
	movhi r0, #-2

	movshi pc, lr

	ldr r3, =CALLBACKS
	ldr r3, [r3]

	cmp r3, #MAX_CALLBACKS
	movhi r0, #-1

	movshi pc, lr

	ldr r4, =CALLBACKS_SONAR_BASE	@vetor de sonares
	mul r3, r3, #4			@posicao correta do sonar
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
