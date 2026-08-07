[bits 16]

SECTION .text
global start

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

	message:		db "S1", 0x00
	stage2_err_msg:		db "S2 LOAD ERR", 0x00

	boot_drive:		db 0x00

stage2_err:
	xor si, si
	mov ds, si
	mov si, stage2_err_msg
	call puts
	
err0:
	jmp err0


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
	mov cx, lwidth_terminal/2

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
	mov [boot_drive], dl

;	Setup stack
	cli
	xor ax, ax
	mov ss, ax
	mov sp, 0x7C00
	sti

	mov ah, 0x00 ; Set video mode
	mov al, 0x03 ; Set text mode
	int 0x10

;	Disable cursor
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 0x19
	mov dl, 0x00
	int 0x10

	xor si, si
	mov ds, si
	mov si, message
	call puts
	
;	Load stage2
	extern __s2_sectors
	extern __s2_start
;	Read sectors
	xor ax, ax
	mov ds, ax

	; DAP moved to stack
	; because I run out of space
	mov sp, 16
	mov si, sp

	mov byte [si],		0x10
	mov byte [si+1],	0x00
	mov word [si+2],	__s2_sectors
	mov word [si+4],	0x0500
	mov word [si+6],	0x0000
	mov word [si+8],	0x0001
	mov word [si+10],	0x0000
	mov word [si+12],	0x0000
	mov word [si+14],	0x0000

	mov dl, [boot_drive] ; drive number
	mov ah, 42h
	int 13h
	jc stage2_err

	jmp 0x0000:__s2_start
