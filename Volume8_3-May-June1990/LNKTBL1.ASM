	title	listing one - link time table
	include	asm.inc

	.stack
	.data
	.data?
	extrn	argv:dword,argc:word

CMD_DAT	segment byte public 'CONST'
command_table label byte
	db	'one',0,'two',0
CMD_DAT ends
CMD_END	segment byte public 'CONST'
	db	0
CMD_END ends
DGROUP	group	CMD_DAT,CMD_END

	.code
	extn	outchr_asciiz,outchr_space,exit_program,startup

;;	main
;
main	proc
	mov	ax,@data		; compensate for MS-LINK bug
	mov	ss,ax
	mov	sp,offset stack

	mov	ax,sp			; initialize segments, argv, argc, etc
	call	startup

	mov	cx,argc[bp]
	jcxz	mai3			;  if no arguments

	mov	ax,@data
	mov	ds,ax

	mov	bx,0
mai1:	lea	si,command_table

	les	di,argv[bp]
	mov	di,es:[di+bx]
	add	bx,2

	call	search_asciiz_table
	jc	mai2
	call	outchr_asciiz
	call	outchr_space

mai2:	loop	mai1

mai3:	jmp	exit_program
main	endp


;;	search asciiz table
;
;	entry	DS:SI	asciiz table
;		ES:DI	search string
;	exit	SI	matching table entry
;		Cf	if search string not found
;	uses	AX
;
search_asciiz_table proc
	jmp	sat2

sat1:	call	strcmp			; compare search string with table
	je	sat3			;  if match
	call	strskp			;  else skip table entry

sat2:	cmp	bptr [si],NULL_CHAR	; check for end of table
	jne	sat1			;  if more table entries
	stc				;  else indicate string not found

sat3:	ret
search_asciiz_table endp


;;	strcmp
;
;	entry	DS:SI	string 1
;		ES:DI	string 2
;	exit	Zf	if equal (Cf=0)
;		Cf	if string 2 > string 1
;	uses	AX
;
strcmp	proc
	pushm	di,si
scp1:	lodsb
	mov	ah,es:[di]
	inc	di
	or	ax,ax
	jz	scp2			; if end of both strings (equal)
	cmp	al,ah
	je	scp1			; if strings equal so far
scp2:	popm	si,di
	ret
strcmp	endp


;;	strskp
;
;	entry	DS:SI	string pointer
;	exit	SI	updated to byte past NULL
;	uses	AX
;
strskp	proc
	lodsb
	cmp	al,0
	jne	strskp
	ret
strskp	endp

	end	main
