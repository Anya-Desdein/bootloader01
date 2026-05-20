[bits 16]

[org 0x7c00]
jmp word 0x0000:start

start:
	mov ah, 0x00 ; Set video mode
	mov al, 0x03 ; Set text mode
	int 0x10

; TODO: Write puts function
	mov ax, 0x0c41
	mov bx, 0xb800
	mov fs, bx
	xor di, di
	mov [fs:di], ax

	mov ax, 0x1f42
	mov bx, 0xb800
	mov fs, bx
	xor di, di
	mov di, 2
	mov [fs:di], ax

	mov ax, 0x0a43
	mov bx, 0xb800
	mov fs, bx
	xor di, di
	mov di, 4
	mov [fs:di], ax

L0:
	pause
	jmp L0

times 510-($-$$) db 0
db 0x55
db 0xaa
