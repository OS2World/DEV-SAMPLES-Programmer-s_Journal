	title	test 386 stack trap for microsoft c
	.model	small
	.data
	extrn	STKHQQ:word
	.386p
	.code
	public	_protect_msc_stack
	extrn	trap_memory_access:near

;;	_protect msc stack
;
_protect_msc_stack proc
	mov	dx,ss			; ss:STKHQQ is stack bottom for
	mov	ax,@data		;  microsoft c
	mov	es,ax
	mov	ax,STKHQQ
	call	trap_memory_access
	ret
_protect_msc_stack endp

	end
