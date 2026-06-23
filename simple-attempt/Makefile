all: floppy.bin

floppy.bin: first_stage.o
	cp first_stage.o floppy.bin

first_stage.o: first_stage.nasm
	nasm $< -o $@

run: floppy.bin
	qemu-system-x86_64 -drive file=floppy.bin,format=raw -cpu host -enable-kvm -no-reboot -no-shutdown -d int,cpu_reset,pcall -s -S

clean:
	rm -f first_stage.o

.PHONY: clean run

