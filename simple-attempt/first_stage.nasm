[bits 16]

[org 0x7c00]
jmp word 0x0000:start
	align 2
	vga_text_base	equ 0xB800

	lwidth_terminal	equ 0x0A0
	rcount_terminal equ 0x019

	curr_terminal:	db 0x00, 0x00

	message:	db 0x41, 0x41, 0x00
	message2:	db 0x69, 0x42, 0x00
	mrep:		db 0x00, 0x00

scroll_up:

	; Method 1: scroll using rep movsw
	xor dx, dx
	mov dx, 1

	; Src and destination
	mov ax, 0xB800
	mov ds, ax
	mov es, ax

	; Direction
	std

	; Src and dest pointers
	mov di, lwidth_terminal
	sub di, 2
	mov si, di
	add si, lwidth_terminal

repeat:

	mov cx, lwidth_terminal
	rep movsw

	add dx, 1
	add di, lwidth_terminal
	add si, lwidth_terminal

	cmp dx, rcount_terminal
	jne repeat

	cld
	
	; Clearl last line
	push ax
	mov ax, 0x20
	
	mov di, si
	add di, 2

	rep stosb

	pop ax

	ret


pawel_jumper:
	
	; Div uses ax for dividend
	mov bl, al
	mov ax, [curr_terminal]


	mov cx, lwidth_terminal
	mov dx, 0
	div cx

	; Check if terminal has to move
	cmp ax, rcount_terminal
	ja scroll_up

	; Bring back al
	xor ax, ax
	mov bl, al

	; Move position to newline
	sub cx, dx
	add [curr_terminal], cx

	ret

; Putchar:
; al: character itself
; VGA buffer - starts at 0xB8000
putchar:
	mov di, vga_text_base
	mov fs, di
	mov di, [curr_terminal]

; Write to addr
	mov [fs:di], al
	inc di

	mov bl, 0x0c
	mov [fs:di], bl

	add [curr_terminal], 2
	ret

; Puts take pointer and prints until eo string add newline at the end
; Pointer to string at [ds:si]
puts:
	mov al, [ds:si]
	cmp al, 0
	je pawel_jumper
	call putchar
	inc si
	jmp puts

start:
	mov ah, 0x00 ; Set video mode
	mov al, 0x03 ; Set text mode
	int 0x10

	mov si, 0
	mov ds, si
	mov si, message
	call puts
	
repeats:
	inc word [mrep]
	; bug here
	mov si, message2
	call puts
	cmp word [mrep], 25
	jl repeats

	mov si, message
	call puts

	L0:
	pause
	jmp L0

times 510-($-$$) db 0
db 0x55
db 0xaa
