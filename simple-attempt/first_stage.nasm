[bits 16]

[org 0x7c00]
jmp word 0x0000:start
	align 2
	message:	db 0x41, 0x0c
	localization:	db 0x00, 0xb8
	localization2:	db 0x02, 0x00, 0x00, 0xb8

; Putchar:
; ax: character itself
; bx: localization in the VGA buffer - starts at 0xB8000
putchar:
	mov fs, bx
	mov [fs:di], ax
	ret


puts:
	

start:
	mov ah, 0x00 ; Set video mode
	mov al, 0x03 ; Set text mode
	int 0x10

; Putchar to console like mov di a call putchar
; Puts take pointer and prints until eo string add newline at the end


	mov ax, [message]
	mov bx, [localization]
	call putchar

	mov bx, [localization2+2]
	mov di, [localization2]
	call putchar
L0:
	pause
	jmp L0

times 510-($-$$) db 0
db 0x55
db 0xaa
