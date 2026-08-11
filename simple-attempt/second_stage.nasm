[bits 32]
SECTION .text
global start2

section .text
	global _start2

jmp start2

	msg_s2:		db "Second Stage Achieved", 0x00

start2:
	; Update all data segment registers
	; 0x10 offset to GDT
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	; Configure stack
	mov ss, ax
	mov esp, 0x7C00

	mov edi, 0x00B8000 ; VGA addr

	mov esi, msg_s2
print_msg_s2:
;	Print msg!
	mov al, [esi]
	cmp al, 0
	je _leave

	mov [edi], al
	mov byte [edi + 1], 0x0B
	
	inc esi
	add edi, 2
	jmp print_msg_s2
	
	; CPUID
	mov eax, 0x80000001 ; extended feature flags
	cpuid

	; Check for long mode support
	test edx, (1 << 29)
	jz _leave



_leave:
