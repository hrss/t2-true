_start:
ldr r1, =0xFFFFFFFF
while:
	mov r7, #20
	svc 0x0

	mov r1, #0
