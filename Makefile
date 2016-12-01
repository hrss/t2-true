system.o: syscalls.s SOUL.s
	arm-eabi-as -g SOUL.s syscalls.s -o system.o

SO: system.o
	arm-eabi-ld system.o -o SO -g --section-start=.iv=0x70000000 -Ttext=0x70000100 -Tdata=0x70000700 -e 0x70000000

teste.o: teste.s
	arm-eabi-as -g teste.s -o teste.o
teste: teste.o
	arm-eabi-ld teste.o -o teste -g -Ttext=0x70001000 -Tdata=0x70001800
