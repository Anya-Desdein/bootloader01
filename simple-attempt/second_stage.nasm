[bits 32]
start:
	mov si, message
	call puts

message:		db "Second Stage", 0x00
