[bits 32]
SECTION .text
global start2

section .text
	global _start2

jmp start2
	; GDT_64 Segment Flag Bits
	%define S_P	(1 << 7) ; Present
	%define S__DPL0	(0 << 5) ; Ring 0
	%define S_S	(1 << 4) ; Code or Data descriptor
	%define S_C	(1 << 3) ; Executable
	%define S_D	(0 << 3) ; Non-executable
	%define S_R	(1 << 3) ; Read
	%define S_W	(1 << 1) ; Write
	%define F_G	(1 << 3) ; Page granularity 4 KiB
	%define F_L	(1 << 1) ; 64-bit long mode
	%define
	%define

	; Kernel Code Descriptor
	istruc GDTE

	iend


	msg_s2:		db "Second Stage Achieved", 0x00
	msg1:		db "Hello Everynyan", 0x00

	align 4
	gdt_64:
	; Kinda same like in 32
	; But 64-bit entries
	; 0-15  FFFF is the max segment size
	; 16-31 Generally ignored ?
	; 32-39 Ignored in my case ?
	; 40-47 Access Byte. Privilege level, segment type, perms
	; Like Ring 0 == 00
	; Ring 1 == 01
	; Ring 2 == 10
	; Ring 3 == 11
	; Privilege: 

	; Null Descriptor
	dq 0x0000000000000000

	; Kernel Code Segment
	dw 0xFFFF
	dw 0x0000
	db 0x00
	


	; Kernel Data Segment


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
	je pcontinue

	mov [edi], al
	mov byte [edi + 1], 0x0B
	
	inc esi
	add edi, 2
	jmp print_msg_s2
pcontinue:	
	; CPUID
	mov eax, 0x80000001 ; extended feature flags
	cpuid

	; Check for long mode support
	test edx, (1 << 29)
	jz _leave

	test edx, (1 << 20)
	jz _leave

	; Disable 32-bit paging
	mov eax, cr0
	and eax, 0x7FFFFFFF
	mov cr0, eax

	mov eax, cr4
	; Enable Physical Address Extension
	; 64-bit memory addressing
	or eax, (1 << 5)
	mov cr4, eax

	; Setup 4 level paging
	; Positioned above the 1MiB

	; Clear mem
	mov edi, 0x00100000 ; Destination
	mov ecx, 4096 ; Repeat count
	xor eax, eax ; Operation
	rep stosd ; Repat
	
	; Page table structure:
	; PML4 0x100000
	; PDPT 0x101000
	; PD   0x102000
	; PT   0x103000

	; Flags:
	; Bit 0 = Exists
	; Bit 1 = Read/Write
	; Bit 2 = User/Supervisor
	; Bit 3 = Page-level write-through
	; Bit 4 = Page-level cache disable
	; Bit 5 = Accessed [CPU setis it to 1 automatically when it reads/writes from this page]
	; Bit 6 = Valid only in the final PT entry, for telling if RAM has newer val than Disk
	; Bit 7 = Page size, valid only in PML4, PDPPT, PD
	; Bit 8 = Global flag prevents clearing TLB when switching between programs
	; Bit 63 = No execute (NX/XD)
	mov dword [0x00100000], 0x00101003 ; PML4 entry
	mov dword [0x00101000], 0x00102003 ; PDPT entry
	mov dword [0x00102000], 0x00103003 ; PD entry
	
	; Identity map for the first 2MiB
	mov edi, 0x103000   ; Start of PT
	mov ebx, 0x00000003 ; First entry should point to 0, 3 is flags

	; ECX decreased by loop
	mov ecx, 512	    ; Map all 512 * 4 entries
map:
	mov [edi], ebx
	add edi, 8	; Page entry size
	add ebx, 4096	; Move to next
	loop  map

	mov eax, 0x00100000
	mov cr3, eax

	; Enable long mode
	; in Extended Feature Enable Register
	; (EFER)
	mov ecx, 0xC0000080 ; EFER address identifier
	rdmsr
	or eax, (1 << 8) ; Enable long mode
	wrmsr

	; Activate paging
	mov eax, cr0
	or eax, (1 << 31) ; Flip the paging flag
	mov cr0, eax

	mov esi, msg1
	mov edi, 0x00B80A0
print_msg1:
;	Print msg!
	mov al, [esi]
	cmp al, 0
	je pcontinue2

	mov [edi], al
	mov byte [edi + 1], 0x0B
	
	inc esi
	add edi, 2
	jmp print_msg1
pcontinue2:
	; Load 64-bit GDT and far jump
	
[bits 64]
start_long_mode:

_leave:
