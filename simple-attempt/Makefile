all: floppy.bin

floppy.bin: first_stage.o second_stage.o dynamic_stage2.ld
	ld -m elf_i386 -T dynamic_stage2.ld first_stage.o second_stage.o floppy.bin --oformat binary

first_stage.o: first_stage.nasm
	nasm -f elf32 first_stage.nasm -o first_stage.o

second_stage.o: second_stage.nasm
	nasm -f elf32 second_stage.nasm -o second_stage.o


run: floppy.bin
	qemu-system-x86_64 -drive file=floppy.bin,format=raw -cpu host -enable-kvm -no-reboot -no-shutdown -d int,cpu_reset,pcall

clean:
	rm -f first_stage.o second_stage.o floppy.bin

.PHONY: clean run

