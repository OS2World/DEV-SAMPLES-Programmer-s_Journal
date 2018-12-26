	title	link time code
	include	asm.inc

	.stack
	.data
pre_terminate_text	db	'Pre-terminate code active',13,10,'$'
	.data?
	extrn	argv:dword,argc:word

terminate_address	dd	?
	
	.code

_TERM1	segment byte public 'CODE'
_TERM1	ends
_TERM2	segment byte public 'CODE'
_TERM2	ends
CGROUP	group	_TEXT,_TERM1,_TERM2

	.code
	assume	cs:CGROUP
	extn	exit_program,startup,outchr_registers

;;	main
;
main	proc
	mov	ax,@data		; compensate for MS-LINK bug
	mov	ss,ax
	mov	sp,offset stack

	mov	ax,sp			; initialize segments, argv, argc, etc
	call	startup

	mov	ah,30h			; check dos version
	int	21h
	cmp	al,3
	jb	mai1			;  if before DOS3

	mov	ah,62h			; get PSP (requires DOS3)
	int	21h
	mov	ds,bx

	les	ax,ds:[0Ah]		; save current terminate address
	mov	wptr terminate_address[bp],ax
	mov	wptr terminate_address[bp+2],es

	mov	ds:[0Ch],cs		; set new termination address
	mov	wptr ds:[0Ah],offset pre_terminate_code

mai1:	jmp	exit_program
main	endp

_TERM1	segment
	assume	ds:@data,es:nothing,ss:nothing
pre_terminate_code:
	mov	ah,9
	mov	dx,@data
	mov	ds,dx
	lea	dx,pre_terminate_text
	int	21h
_TERM1	ends
_TERM2	segment
	mov	ax,@data
	mov	ds,ax
	jmp	terminate_address
_TERM2	ends

	end	main
