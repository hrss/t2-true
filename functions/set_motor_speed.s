set_motor_speed:

  	mrs r0, CSPR
  	orr r0, r0, #0b11111
	msr CPSR, r0

	mov r0, sp
 

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1, r2}
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
  	beq write_motor_0
		
  	cmp r0, #1
  	beq write_motor_1	@r0 id e r1 velocidade					
	
  	pop {r1-r2}

  	movs pc,lr


set_motors_speed:	

	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0							
	
	mov r0, sp
 

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0
	
	push {r1, r2}
	ldmdb r0, {r1-r2}

	mov r0, r1
	mov r1, r2
									
	mov r2, #0
	mov r3, r1							@velocidade 1 esta em r3

	mov r1, r0
	mov r0, r2							@ok para motor 0	
	
	mov r7, #18							@chama a syscall set_motor_speed para o motor 0
	svc 0x0

	cmp r0, #-2							@confere se o retorno de set_motor_speed e valido
	moveq r0, #-1
	
	mov r1, r3
	mov r3, r0							@r3 fica com r0(velocidade do motor 0)

	mov r0, #1

	svc 0x0									@chama a syscall set_motor_speed para o motor 1
	
	cmp r0, #-2
	moveq r0, #-2

	mov r1, r0
	mov r0, r3
	
	pop {r1-r2}

	movs pc,lr


read_sonar:
	
	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0							
	
	mov r0, sp
 

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1}
	ldmdb r0, {r1}

	mov r0, r1

	
	movmi r0, #-1	

	cmp r0, #15
	movgt r0, #-1
	
	cmp r0, #-1
	bne read_sonar_with_id	
	
	pop {r1}	
	
	movs pc, lr
	

	

	
get_time:

	rotuloRETORNA_TEMPO	
	
	movs pc, lr


set_time:
	
	mrs r0, CSPR
	orr r0, r0, #0b11111
	msr CPSR, r0							
	
	mov r0, sp
 

	mrs r0, CSPR
	and r0, r0, #0b11111111111111111111111111110011
	msr CPSR, r0

	push {r1}
	ldmdb r0, {r1}

	mov r0, r1



	pop {r1}
	
	
	
	

set_alarm:
	
	ldr r2,=MAX_ALARMS
	ldr r2, [r2]

	bl get_time

	cmp r1,r0
	movlt r0, #-2 			@se tempo menor que tempo do sistema r0 = -2
	mov r0, #0					@senão r0 = 0
	

	
	

	
