set_motor_speed:

  stmfd sp!, {r4-r11, lr} @salvei registradores não utilizados
  add fp, sp, #32
  sub sp, #4
  ldr r1, [fp,#4]         @velocidade
  ldr r0, [fp,#8]         @id do motor

  cmp r0, #1              @averigua se a id do motor e valida
  cmpne r0,#0
  movne r0, #-1
	mov r0, #0

  movmi r1, #-2           @confere se a velocidade e negativa


  cmp r1, #63             @confere se o valor da velocidade valesse mais que um bit
  movgt r1, #-2
	mov r0, #0	
	
	
  lmfd sp!, {r4-r11,lr}		@desempilha os registradores não utilizados
  movs pc,lr


set_motors_speed:	

	stmfd sp!, {r4-r11, lr} @salvei registradores não utilizados
  add fp, sp, #32
  sub sp, #4
  ldr r1, [fp,#4]         @velocidade de 1
  ldr r0, [fp,#8]         @velocidade de 0

	mov r2, #0
	mov r3, #1

	mov r4, r0
	mov r0, r2
	mov r5, r1
	mov r1, r4

	mov r7, #18							@chama a syscall set_motor_speed para o motor 0
	svc 0x0

	cmp r0, #-2
	moveq r0, #-1
	
	mov r2, r0
	mov r0, r3
	mov r1, r5

	svc 0x0									@chama a syscall set_motor_speed para o motor 1
	
	cmp r0, #-2
	moveq r0, #-2

	mov r3, r0
	mov r0, r2							@ajeita os parametros para retorno da funcao
	mov r1, r3

	lmfd sp!, {r4-r11, lr}

	
	movs pc,lr


read_sonar:

	stmfd sp!, {r4-r11, lr} @salvei registradores não utilizados
	add fp, sp, #32
	sub sp, #4
	ldr r0, [fp, #4]
	
	cmp r0, #0
	movlt r0, #-1	

	cmp r0, #15
	movgt r0, #-1
	
	lmfd sp!, {r4-r11, lr}

	movs pc, lr
	
	
	

	
get_time:

	
	movs pc, lr


set_time:


	stmfd sp!, {r4-r11, lr} @salvei registradores não utilizados
	add fp, sp, #32
	sub sp, #4
	ldr r0, [fp, #4]
	lmfd sp!, {r4-r11, lr}
	

	set_alarm:


	

