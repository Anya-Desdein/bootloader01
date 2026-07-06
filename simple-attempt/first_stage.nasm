[bits 16]

[org 0x7c00]
jmp word 0x0000:start
	align 2
	vga_text_base	equ 0xB800

	lwidth_terminal	equ 0x0A0
	rcount_terminal equ 0x019
	full_terminal	equ lwidth_terminal*rcount_terminal
	rchlf		equ rcount_terminal/2

	curr_terminal:	db 0x00, 0x00

	hex_digits:	db "0123456789ABCDEF"
	message:	db 0x41, 0x41, 0x00
	message2:	db 0x69, 0x42, 0x00
	message3:	db 0x3F, 0x47, 0x00
	message4:	db 0x49, 0x48, 0x00
	mrep:		db 0x00, 0x00
	idx:		db 0x00, 0x00

scroll_up:
	; Scroll using rep movsw
	mov dx, 0

	; Src  = ds:si
	; Dest = es:di
	mov ax, 0xB800
	mov ds, ax
	mov es, ax

	; Forward direction
	cld

	; Src and dest pointers
	mov di, lwidth_terminal
	mov si, di
	add si, lwidth_terminal

repeat:
	; Numbers of moves
	; Each letter is 2 bytes
	mov cx, rchlf
	rep movsw

	; Counter less than
	; Row count (25) -1
	inc dx
	cmp dx, rcount_terminal

	add di, lwidth_terminal
	add si, lwidth_terminal

	je repeat

	; Clearl last line
	push ax
	mov ax, 0x20
	
	mov di, si
	inc di
	inc di

	rep stosb

	pop ax

	mov word[curr_terminal], 3838
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
	; Check if terminal is full
	; Div uses ax for dividend
	push al
	mov ax, [curr_terminal]
	mov cx, full_terminal
	mov dx, 0
	div cx
	cmp ax, cx
	jbe full_check_cdn
	call scroll_up
	; Bring back al
full_check_cdn:
	xor ax, ax
	pop al
	ret
; Puts take pointer and prints until eo string add newline at the end
; Pointer to string at [ds:si]
puts:
	; check if character is EOS
	mov al, [ds:si]
	cmp al, 0
	inc si
	je puts_end
	call putchar
	jmp puts
puts__end:
	ret

index_line:
	mov al, [idx+1]
	and ax, 0x00f0
	shr al, 4
	mov si, hex_digits
	add si, ax
	mov al, [si]
	call putchar

	mov al, [idx+1]
	and ax, 0x000f
	mov si, hex_digits
	add si, ax
	mov al, [si]
	call putchar

	mov al, [idx]
	and ax, 0x00f0
	shr al, 4
	mov si, hex_digits
	add si, ax
	mov al, [si]
	call putchar

	mov al, [idx]
	and ax, 0x000f
	mov si, hex_digits
	add si, ax
	mov al, [si]
	call putchar

	mov al, ':'
	call putchar

	mov al, ' '
	call putchar

	inc word [idx]

	ret

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

	; call index_line

	mov si, message2
	call puts
	cmp word [mrep], 25
	jl repeats

	mov si, message
	call puts
	 mov si, message3
	 call puts
	 mov si, message4
	 call puts
	L0:
	pause
	jmp L0

times 510-($-$$) db 0
db 0x55
db 0xaa
