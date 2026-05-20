all: floppy.bin

floppy.bin: first_stage.o
	cp first_stage.o floppy.bin

first_stage.o: first_stage.nasm
	nasm $< -o $@

run: floppy.bin
	qemu-system-x86_64 -hda floppy.bin -cpu host -enable-kvm

clean:
	rm -f first_stage.o

.PHONY: clean run

