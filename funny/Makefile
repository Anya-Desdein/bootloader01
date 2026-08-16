all: floppy
	qemu-system-x86_64 -hda floppy

floppy:
	python lol.py

test: floppy
	xdd floppy

clean:
	rm -f floppy