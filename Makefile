all: compile

compile: 1-nasm.o main.o
	gcc -g -no-pie -o myPrint 1-nasm.o main.o 

main.o: main.c
	gcc -g -c main.o main.c

1-nasm.o: 1-nasm.asm
	nasm -g -f elf64 1-nasm.asm
