all: floppy
	qemu-system-x86_64 -hda floppy

test: floppy
	xdd floppy

clean:
	rm -f floppy