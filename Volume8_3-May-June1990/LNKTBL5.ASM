	title	listing five
	include	asm.inc
	.stack
	.data
one	db	'one$'
two	db	'two$'
three	db	'three$'

table   macro p1,p2
    _TABLE segment
        dw      p1
    _TABLE ends
        dw      p2
        endm

_TABLE segment word public 'DATA'
search_keys	label word
_TABLE ends
DGROUP	group	_TABLE
    
table_offsets	label word
	table	1, one
	table	2, two
	table	3, three

	.code

;;	main
;
main	proc
	mov	ax,@data
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,offset stack
	mov	bp,0

	mov	ax,2			; search for 2 in search_keys
	mov	cx,3			;  (table has 3 entries)
	lea	di,search_keys
	repne	scasw
	jne	mai1			;  if not found

	sub	di,offset search_keys	; get corresponding offset from table
	lea	si,[di-size search_keys]
	mov	dx,table_offsets[bp+si]

	mov	ah,9			; display matching string on console
	int	21h

mai1:	mov	ax,4C00h
	int	21h
main	endp

	end	main
