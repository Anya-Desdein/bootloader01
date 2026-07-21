[bits 16]

[org 0x7c00]
jmp word 0x0000:start
	align 2
	vga_text_base	equ 0xB800

	lwidth_terminal	equ 0x0A0
	rcount_terminal equ 0x019
	full_terminal	equ lwidth_terminal*rcount_terminal
	last_char	equ full_terminal-2
	last_line:	equ full_terminal-lwidth_terminal

	curr_terminal:		db 0x00, 0x00

	read_terminal_src:	db 0x00, 0x9E
	read_terminal_dest:	db 0x00, 0x00

;	hex_digits:		db "0123456789ABCDEF"
	message:		db 0x41, 0x42, 0x00
	message2:		db 0x11, 0x45, 0x00
	message3:		db 0x43, 0x44, 0x00
	message4:		db 0x46, 0x47, 0x00
	message5:		db 0x45, 0x48, 0x00

newline:
	push dx
	push ax
	push cx

	xor dx, dx
	; dx:ax / cx
	mov ax, [curr_terminal]
	mov cx, lwidth_terminal
	div cx

	; Substract filled line part
	; from the line width
	mov bx, ax
	add bx, 1
	mul bx, lwidth_terminal
	mov word[curr_terminal], bx

	cmp bx, last_char
	jl newline_ret

scroll_line:
	mov ax, vga_text_base
	mov fs, ax

	mov word[read_terminal_src], lwidth_terminal
	mov word[read_terminal_dest], 0
scr:
	mov di, [read_terminal_src]
	mov al, [fs:di]
	
	mov bx, [read_terminal_dest]
	mov di, bx
	mov [fs:di], al
	inc di
	mov al, 0x0c
	mov [fs:di], al

	add [read_terminal_src],  2
	add [read_terminal_dest], 2

	mov ax, [read_terminal_src]
	cmp ax, last_char
	jl scr

	mov ax, vga_text_base
	mov es, ax
	xor dx, dx
	mov ax, lwidth_terminal
	mov bx, 2
	div bx
	mov cx, ax

	mov ax, last_line
	mov di, ax
	mov ax, 0
	cld
	rep stosw

	mov word[curr_terminal], last_line

newline_ret:
	pop cx
	pop ax
	pop dx

	ret

write_char:
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
; Putchar:
; al: character itself
; VGA buffer - starts at 0xB8000
putchar:
	call full_check

	; check if character is new line
	cmp  al, 0x0A
	je   putchar_newline
	call write_char
	ret
putchar_newline:
	call newline
	ret

full_check:
	mov bx, [curr_terminal]
	cmp bx, full_terminal

	jb full_check_cdn
	call scroll_line
full_check_cdn:
	ret
; Puts take pointer and prints until eo string add newline at the end
; Pointer to string at [ds:si]
puts:
	; check if character is EOS
	mov al, [ds:si]

	inc si
	cmp al, 0
	je puts_end
	call putchar
	jmp puts
puts_end:
	call newline
	ret

start:
	mov ah, 0x00 ; Set video mode
	mov al, 0x03 ; Set text mode
	int 0x10

	xor si, si
	mov ds, si
	mov si, message
	call puts
	mov si, message4
	call puts

	mov cx, 20
.L1:
	mov si, message3
	call puts
	dec cx
	jne .L1

	mov cx, 4
.L2:
	mov si, message4
	call puts
	dec cx
	jne .L2

	mov cx, 4
.L3:
	mov si, message5
	call puts
	dec cx
	jne .L3

times 510-($-$$) db 0
db 0x55
db 0xaa
