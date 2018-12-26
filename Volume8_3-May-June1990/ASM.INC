	.xlist
	page	63,128

	.model	small
	ASSUME	ds:nothing
;	includelib lib


bptr			equ	byte ptr
wptr			equ	word ptr
dptr			equ	dword ptr


FILENAME_MAX		equ	80

NULL_POINTER		equ	0

NULL_CHAR		equ	0
TAB_CHAR		equ	9
EOL_CHAR		equ	10	; end of line
LF_CHAR			equ	10	; linefeed
CR_CHAR			equ	13	; carriage return
SPACE_CHAR		equ	' '


	IFNDEF	.date	; if not OPTASM
	.sall		; don't show macro contents

extb	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	extrn	xx:byte
	else
	exitm
	endif
	endm
	endm

extd	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	extrn	xx:dword
	else
	exitm
	endif
	endm
	endm

extn	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	extrn	xx:near
	else
	exitm
	endif
	endm
	endm

extw	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	extrn	xx:word
	else
	exitm
	endif
	endm
	endm

pushm	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	push	xx
	else
	exitm
	endif
	endm
	endm

popm	macro	a,b,c,d,e,f,g,h,i,j,k
	irp	xx,<a,b,c,d,e,f,g,h,i,j,k>
	ifnb	<xx>
	pop	xx
	else
	exitm
	endif
	endm
	endm

	ENDIF		; end MASM/TASM macros

	.list		; end of asmdef.equ
