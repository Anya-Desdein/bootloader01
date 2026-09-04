[bits 64]
SECTION .text
global k_start

pred:
	mov rdi, 0xB80162
	mov al, 0x04
	mov bl, 0x4F

	mov [rdi], bl
	inc rdi

	mov [rdi], al
	inc rdi

	mov bl, 0x00

	mov [rdi], bl
	inc rdi

	mov [rdi], al
	inc rdi

	ret

k_start:
	call pred
	hlt
	jmp k_start