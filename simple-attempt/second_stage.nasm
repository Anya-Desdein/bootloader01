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

	test edx, (1 << 20)
	jz _leave

	; Disavle 32-bit paging
	mov eax, cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax

	mov eax, cr4
	; Enable Physical Address Extension
	; 64-bit memory addressing
	or eax, (1 << 5)
	; Enable FXSAVE/FXRSTOR
	; Save SSE state during process switches
	or eax, (1 << 9)
	; Enable OSXMMEXCPT
	; UNMASKED SIMD float exception
	or eax, (1 << 10)
	mov cr3, eax

	; TODO: paging
_leave:
