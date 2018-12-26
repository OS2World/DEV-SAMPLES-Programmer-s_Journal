	title	386 memory protect
	.model	small

	.data
original_int1	label	dword
	dw	trap_interrupt,@code

terminate_address label	dword
	dw	terminate_program,@code

stack_over_text	db	'Stack overflow at CS:IP==$'


	.386p
	.code


;;	outchr
;
;	entry	AL	character to display
;	uses	AX
;
outchr	proc
	push	dx
	mov	dl,al
	mov	ah,2
	int	21h
	pop	dx
	ret
outchr	endp


;;	outchr hex word
;
;	entry	AX	word
;	uses	AX
;
outchr_hex_word proc
	push	ax
	mov	al,ah
	call	ohw1
	pop	ax
ohw1:	push	ax
	sar	al,1
	sar	al,1
	sar	al,1
	sar	al,1
	call	ohw2
	pop	ax
ohw2:	and	al,0Fh
	add	al,90h
	daa
	adc	al,40h
	daa
	jmp	outchr
outchr_hex_word endp


;;	terminate program
;
terminate_program proc
	mov	eax,0			; disable breakpoints
	mov	dr7,eax

	mov	ax,@data		; restore original interrupt 1
	mov	ds,ax
	mov	eax,original_int1
	mov	dx,0
	mov	es,dx
	mov	es:[4],eax

	jmp	terminate_address	; goto original terminate address
terminate_program endp


;;	trap interrupt
;
trap_interrupt proc
	mov	eax,0			; disable breakpoints
	mov	dr7,eax

	mov	ah,9			; *Stack overflow at CS:IP==*
	mov	dx,@data
	mov	ds,dx
	lea	dx,stack_over_text
	int	21h

	pop	dx			; display CS:IP
	pop	ax
	call	outchr_hex_word
	mov	al,':'
	call	outchr
	mov	ax,dx
	call	outchr_hex_word

	mov	ax,4C01h		; exit program
	int	21h
trap_interrupt endp


;;	trap memory access
;
;	entry	DX:AX	real address to protect
;	uses	EAX,BX,EDX,ES
;
trap_memory_access proc
	push	ds
	movzx	eax,ax			; convert real-mode dword address
	movzx	edx,dx			;  to linear address
	shl	edx,4
	add	edx,eax

	mov	ah,30h			; check dos version
	int	21h
	cmp	al,3
	jb	tma3			;  if before DOS3

	mov	ah,62h			; get PSP (requires DOS3)
	int	21h
	mov	es,bx

	mov	ax,@data		; set terminate address at PSP:0Ah
	mov	ds,ax
	mov	eax,terminate_address
	cmp	ax,offset terminate_program
	jne	tma1			;  if terminate address set already
	xchg	eax,es:[0Ah]
	mov	terminate_address,eax

tma1:	mov	ax,0			; set trap interrupt vector
	mov	es,ax
	mov	eax,original_int1
	cmp	ax,offset trap_interrupt
	jne	tma2			;  if set already
	xchg	eax,es:[4]
	mov	original_int1,eax

tma2:	mov	dr0,edx			; enable global breakpoint 0 for any
	mov	eax,070202h		;  16 bit read or write to linear adr
	mov	dr7,eax

tma3:	pop	ds
	ret
trap_memory_access endp

	public	trap_memory_access,trap_interrupt,terminate_program

	end
