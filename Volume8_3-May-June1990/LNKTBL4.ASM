	.model small
	.data
listing4_text	db	'Listing 4 terminate code',13,10,'$'

_TERM1	segment byte public 'CODE'
	mov	ah,9
	mov	dx,@data		; display terminate message
	mov	ds,dx
	lea	dx,listing4_text
	int	21h
_TERM1	ends

	end
