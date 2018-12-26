	title	test 386 stack trap for assembly language
	dosseg
	.model	small
	.stack	100h

	.386p
	.code
	extrn	trap_memory_access:near

;;	main
;
main	proc
	mov	dx,STACK		; break on access to stack bottom+32
	mov	ax,32
	call	trap_memory_access

	mov	cx,80h			; overflow stack
mai1:	push	cx
	loop	mai1

	mov	ax,4C00h
	int	21h
main	endp

	end	main
