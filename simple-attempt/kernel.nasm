[bits 64]
SECTION .text
global k_start

k_start:
	hlt
	jmp k_start