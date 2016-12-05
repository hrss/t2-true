system.o: syscalls.s SOUL.s
	arm-eabi-as -g SOUL.s syscalls.s -o system.o

SO: system.o
	arm-eabi-ld system.o -o SO -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

teste.o: teste.s
	arm-eabi-as -g teste.s -o teste.o
teste: teste.o
	arm-eabi-ld teste.o -o teste -g -Ttext=0x77802400 -Tdata=0x77803400

disk.img: SO teste
	mksd.sh --so SO --user teste
