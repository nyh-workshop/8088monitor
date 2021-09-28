	; References: 1. https://www.retrobrewcomputers.org/forum/index.php?t=msg&goto=6936&
	;             2. https://github.com/coopzone-dc/v20-mbc-examples
	
	GPIOA equ 3                  ;gpio port A data
	IODIRA equ 5                 ;gpio port A input / output direction
	SERTX equ 0x01               ; SERIAL TX opcode
	STO_ADDR equ 0x01            ; Address of the STORE OPCODE write port
	EXC_WR_ADDR equ 0x00         ; Address of the EXECUTE WRITE OPCODE write port
	
	MON_REG_AREA_OFFSET equ 0x500
	MON_HEX_REG_AREA_OFFSET equ MON_REG_AREA_OFFSET + 0x20
	
	[map mapFile2.txt]           ; Set output map file
	CPU 8086                     ; Set 8086 / 8088 opcodes only
	BITS 16                      ; Set default 16 bit
	
	org 600h
	
	; zero stack area (256 bytes)
	mov ax, 0x00
	mov es, ax
	
	mov ax, 0x00
	mov ds, ax
	
	xor di, di
	mov ax, 0x00
	mov cx, 0xFF
	
	; init stack here:
	mov sp, 0x0400
	mov ss, sp
	
fillStackAreaZeroLoop:
	stosw
	loop fillStackAreaZeroLoop
	
	; assign an int03 address to IVT:
	mov ax, 0x00
	mov ds, ax
	
	mov ax, int03
	mov bx, 0x04 * 0x03
	mov [bx], ax
	mov ax, cs
	mov [bx + 2], ax
	
	; main body:
	
	mov ax, 0x1002
	mov es, ax
	mov ax, 0x0004
	mov bp, ax
	mov ax, 0xa5a5
	mov si, ax
	mov ax, 0x5a5a
	mov di, ax
	
	mov ax, 0x1920
	mov bx, 0x1080
	mov cx, 0x1010
	mov dx, 0xffff
	
	int 0x03
	
here: hlt
	jmp here
	
int03:
	;pusha
	push ax
	push bx
	push cx
	push dx
	push bp
	push si
	push di
	
	push ds
	push es

	;push ax
	;mov ax, 0x1000
	;mov ds, ax
	;pop ax
	
	mov [MON_REG_AREA_OFFSET], ax
	mov [MON_REG_AREA_OFFSET + 2], bx
	mov [MON_REG_AREA_OFFSET + 4], cx
	mov [MON_REG_AREA_OFFSET + 6], dx
	mov [MON_REG_AREA_OFFSET + 8], ds
	mov [MON_REG_AREA_OFFSET + 10], es
	mov [MON_REG_AREA_OFFSET + 12], di
	mov [MON_REG_AREA_OFFSET + 14], si
	mov [MON_REG_AREA_OFFSET + 16], bp
	mov [MON_REG_AREA_OFFSET + 18], cs
	
	; Saved values are from 0x00 - 0x10 offset.
	; Converted values (to hex) are from 0x20 - 0x30 offset.
	; Retrieving them from the saved values:
	cld
	mov ax, 0x0000
	mov es, ax
	mov ax, MON_HEX_REG_AREA_OFFSET
	mov di, ax
	; divider is 16:
	mov bx, 16
	
	; nibbleToHex4digit uses:
	; ax = input
	; bx = divider
	; dx = input (MSB dividend)
	; di = input pointer for storing, increases by 4 after calling.
	; need to reset cx back to 4 after using!
	
	; Convert the cs from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 18]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the bp from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 16]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the si from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 14]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the di from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 12]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the es from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 10]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the ds from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 8]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the dx from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 6]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the cx from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 4]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the bx from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET + 2]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; Convert the ax from integer to hex:
	mov ax, [MON_REG_AREA_OFFSET]
	mov cx, 0x0004
	mov dx, 0x00
	call nibbleToHex4digit
	
	; DI is all incremented to the max value here.
	
	mov ax, ax_label
	mov si, ax
	; printLabel uses:
	; ax = memory address of label (must be within the code segment!)
	; si = for loop to print the label
	call printLabel
	
	sub di, MON_HEX_REG_AREA_OFFSET
	mov ax, MON_HEX_REG_AREA_OFFSET
	add ax, di
	dec ax
	mov si, ax
	
	; Print AX=....:
	mov cx, 4
	; printHexDigits:
	; ax = memory address of label (must be within code segment!)
	; si = for loop to print the string
	; cx = counter, how many digits to print
	call printHexDigits
	
	call printOneSpace
	
	; Print BX=....:
	mov ax, bx_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print CX=....:
	mov ax, cx_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print DX=....:
	mov ax, dx_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printCR
	
	; Print DS=....:
	mov ax, ds_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print ES=....:
	mov ax, es_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print DI=....:
	mov ax, di_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print SI=....:
	mov ax, si_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printCR
	
	; Print BP=....:
	mov ax, bp_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printOneSpace
	
	; Print CS=....:
	mov ax, cs_label
	push si
	mov si, ax
	call printLabel
	pop si
	
	mov cx, 4
	call printHexDigits
	
	call printCR
	
	pop es
	pop ds
	
	;popa
	pop di
	pop si
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret
	
nibbleToHex4digit:
.nibbleToHexLoop: 
	div bx
	call .nibbleToHex
	push ax
	mov ax, dx
	stosb
	pop ax
	mov dx, 0
	loop .nibbleToHexLoop
	ret
	
.nibbleToHex: cmp dx, 10
	jl .lessThan10
	cmp dx, 16
	jl .between10and15
	jmp .invalidValue
	
.lessThan10: add dx, 48
	jmp .doneConvert
.between10and15: add dx, 55
	jmp .doneConvert
	
.invalidValue: mov dx, 0
	
.doneConvert: ret
	
printLabel:
.putLabelLoop:
	mov al, SERTX
	out STO_ADDR, al
	mov al, [si]
	cmp al, 0x00
	je .putLabelDone
	out EXC_WR_ADDR, al
	inc si
	jmp .putLabelLoop
.putLabelDone: xor si, si
	ret
	
printHexDigits:
.puts: mov al, SERTX
	out STO_ADDR, al
	mov al, [si]
	out EXC_WR_ADDR, al
	dec si
	loop .puts
	ret
	
printOneSpace: mov al, SERTX
	out STO_ADDR, al
	mov al, ' '
	out EXC_WR_ADDR, al
	ret
	
printCR: mov al, SERTX
	out STO_ADDR, al
	mov al, 0x0d
	out EXC_WR_ADDR, al
	mov al, SERTX
	out STO_ADDR, al
	mov al, 0x0a
	out EXC_WR_ADDR, al
	ret
	
	ax_label db "ax=", 0x00
	bx_label db "bx=", 0x00
	cx_label db "cx=", 0x00
	dx_label db "dx=", 0x00
	di_label db "di=", 0x00
	si_label db "si=", 0x00
	ds_label db "ds=", 0x00
	es_label db "es=", 0x00
	bp_label db "bp=", 0x00
	cs_label db "cs=", 0x00
