system.o: syscalls.s SOUL.s
	arm-eabi-as -g SOUL.s syscalls.s -o system.o

SO: system.o
	arm-eabi-ld system.o -o SO -g  --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

motors.o: motors.s
	arm-eabi-as -g motors.s -o motors.o

motors: motors.o
	arm-eabi-ld motors.o -o motors -g -Ttext=0x77802000

disk.img: SO motors
	mksd.sh --so SO --user motors
