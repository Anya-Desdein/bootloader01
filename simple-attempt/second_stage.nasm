[bits 32]
SECTION .text
global start2

jmp word 0x0000:start2

	msg_s2:		db "Second Stage LOADED <3", 0x00

start2:
	mov edi, 0xB8000 ; VGA addr


	mov esi, msg_s2
print_msg_s2:
;	Print msg!
	mov al, [esi]
	cmp al, 0
	je msge

	mov [edi], al
	mov byte [edi + 1], 0x0B
	
	inc esi
	add edi, 2
	jmp print_msg_s2

msge:
		
