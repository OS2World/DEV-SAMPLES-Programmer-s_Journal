;XCALL.ASM
;(C) COPYRIGHT 1989 DANIEL GREENBERG
;
;General-purpose interrupt 2EH utility.  
;
;This must be converted into a COM file.
;SS assumed equal to CS
;
;Syntax: 
;	xcall {command}
;command is passed to the root COMMAND.COM where it is processed
;regardless of the presence of a secondary COMMAND.COM.
;

code  	segment para public 'code'
 	assume cs:code,ds:code
	org 100h
begin: jmp start

;---------------------------------------------------------------------------

;EQUATES
version_two_one		equ  020ah
version_two_one_one	equ  020bh
version_three_zero	equ  0300h
version_three_one	equ  030ah
version_three_two	equ  0314h
version_three_three	equ  031eh
version_four_zero	equ  0400h

owner_id		equ  16h	;Offset in PSP


;Following data structures delineate important COMMAND.COM variables, 
;by version:

command2x_data STRUC
TwoE_caller_ip		dw  ?
TwoE_caller_cs		dw  ?
TwoE_caller_psp		dw  ?
command_owner_id	dw  ?		;If this COMMAND not root this variable
command2x_data ENDS			; holds PSP of calling COMMAND. Else 
					; holds root COMMAND's own PSP.

command2_1_data STRUC
command2x_structure	db  8 dup (?)	;1st 8 bytes same as 2x structure
unkwn			db  5 dup (?)
batch_block_pointer2	dw  ?		;Seg address of batch file data block,
					;0000h = no batch file in progress
batch_fileptr		dd  ?		;Current file pointer in batch file
comspec2		db  40 dup (?)	;Path to disc copy of COMMAND.COM
transient_command2	dd  ?		;Transient COMMAND entry address
more_unkwn		db  6 dup (?)
exec_flag2		db  ?		;01 = application launched
still_more_unkwn	dw  ?
echo_flag2		db  ?		;0 = echo off
twoE_flag2		dw  ?	 	;0=no 2Eh in progress;81h=COMMAND reentered
					; 2eh string at offset 81h; 0ffffh=2eh
					; command processed, return 
					; to caller pending.
even_more_unkwn		db  6 dup (?)
for_flag2		db  ?		;01 = for loop in progress
command2_1_data ENDS

command3_data STRUC			;3.0 & 3.1 use same structure
command_twox_structure	db  8 dup (?)	;1st 8 bytes same structure as 2x
exit_routine3		dd  ?		;EXIT transfers control to this address
unkwn3			db  5 dup (?)
batch_block_pointer3	dw  ?		;Seg address of batch file data block
					; 0000h = no batch file in progress
comspec3		db  64 dup (?)	;Path to disc copy of COMMAND.COM
comspec_address3	dw  ?		;Offset of comspec string
comspec_end_address3	dw  ?		;Offset of end of comspec string
transient_command3	dd  ?		;Transient COMMAND entry address
more_unkwn3		db  6 dup (?)
exec_flag3_0		db  ?		;01 = application launched
still_more_unkwn3	dw  ?
echo_flag3_0		db  ?		;0 = echo off
twoE_flag3_0		dw  ?		;0=no 2Eh in progress;81h=COMMAND
					; reentered,2eh string at offset 81h;
					; 0ffffh=2eh command processed,return
					; to caller pending.
even_more_unkwn3	db  8 dup (?)	
for_flag3_0		db  ?		;01 = for loop in progress
for_block_pointer3_0	dw  ?		;Seg address of "for" process block
command3_data ENDS

command3_2_data STRUC
command_3_structure	db  91 dup (?)	;1st 91 bytes same struc as 3.0 
unkwn3_2		db  8 dup (?)
exec_flag3_2		db  ?		;01 = application launched
more_unkwn3_2		db  2 dup (?)
echo_flag3_2		db  ?		;0 = echo off
twoE_flag3_2		dw  ?		; 0=no 2Eh in progress;81h=COMMAND
					; reentered,2eh string at offset 81h;
					; 0ffffh=2eh command processed,return
					; to caller pending.	
still_more_unkwn3_2	db  8 dup (?)
for_flag3_2		db  ?		;01 = for loop in progress
for_block_pointer3_2	dw  ?		;Seg address of "for" process block
command3_2_data ENDS

command3_3_data STRUC
com_three_structure	db  91 dup (?)	;1st 91 bytes same struc as 3.0.
unkwn3_3		db  8 dup (?)
exec_flag3_3		db  ?		;01 = application launched
more_unkwn3_3		db  3 dup (?)	
echo_flag3_3		db  ?		;0 = echo off; 01 = echo on
twoE_flag3_3		dw  ?		;0=no 2Eh in progress;81h=COMMAND
					; reentered,2eh string at offset 81h;
					; 0ffffh=2eh command processed,return
					; to caller pending.
still_more_unkwn3_3	db  9 dup (?)
for_flag3_3		db  ?		;01 = for loop in progress
for_block_pointer3_3	dw  ?		;Seg address of "for" process block
batch_counter3_3	dw  ?		;Incremented on each nested batch "call" 
command3_3_data ENDS

command4_0_data STRUC
com_twox_data_structure	db  8 dup (?)	;1st 8 bytes same structure as 2x
exit_routine4_0		dd  ?		;EXIT transfers control to this address
unkwn4_0		db  5 dup (?)
batch_block_pointer4_0	dw  ?		;Seg address of batch file data block;
					;  0000h = no batch file in progress
comspec4_0		db  64 dup (?)	;Path to disc copy of COMMAND.COM
comspec_string_end4_0	dw  ?		;Offset of end of comspec string
transient_command4_0	dd  ?		;Transient COMMAND entry address
more_unkwn4_0		db  8 dup (?)
Exec_flag4_0		db  ?		;01 = application launched
still_more_unkwn4_0	db  5 dup (?)
echo_flag4_0		db  ?		;0 = echo off; 01 = echo on
twoE_flag_etc		dw  ?		;0=no 2Eh in progress;81h=COMMAND
					; reentered,2eh string at offset 81h;
					; 0ffffh=2eh command processed,return
					; to caller pending.
even_more_unkwn4_0	db  9 dup (?)
for_flag4_0		db  ?		;01 = for loop in progress
for_block_pointer4_0	dw  ?		;Seg address of "for" process block
batch_counter4_0	dw  ?		;Incremented on each nested batch "call"
command4_0_data ENDS
 
;This structure delineates first 6 bytes of batch file data block (ver 3.3+):
batch_block STRUC				
unknown			db  ?
prev_echo_flag		db  ?		;0 = echo off; 01 = echo on
previous_batch_blk	dw  ?		;Calling batch file block, if any
previous_for_blk	dw  ?		;Calling for loop data block, if any
batch_block ENDS			

for_flag_address	dw  ?
batch_ptr_address	dw  ?


;We save COMMAND's info on previous 2Eh caller here. Later restore this to
;COMMAND.COM so on our exit COMMAND will return control to previous caller:
previous_2e_psp		dw  ?
previous_2e_ip		dw  ?
previous_2e_cs		dw  ?
previous_2e_flag	dw  ?
twoE_flagoffset		dw  ?

;We save COMMAND's flags and pointers here prior to 2Eh call and restore this
;info to COMMAND after call.  This allows COMMAND.COM to continue normal
;execution after our exit:
old_batch_block 	dw  ?		
old_batch_fileptr	dd  ?		;Used in DOS 2.x only
old_batch_counter	dw  ?
old_echo_flag		db  ?
old_for_flag		db  ?		
old_for_block		dw  ?		;Not used in DOS 2.x

stk_ptr			dw  ?
version			dw  ?

first			db  0		;0=no previous active int 2eh
error			db  0		;0=ok, 1=error during xcalled batch file
					; or for loop

batch_terminate_mes	db  0dh,0ah,"Cannot restore XCALL'ed batch file "
			db  "after Ctrl-break or critical error.",0dh,0ah
			db  "Batch file will be terminated.",0dh,0ah,"$"

;Note on register usage: First subroutine sets es:di equal to segment:offset
;of data area for root COMMAND.COM.  After that, es:di are preserved across
;subroutines.

;===============================================================================
reduce_memory:
	int 21h

	push di				;di=offset of COMMAND's data area.
	mov stk_ptr,sp			;Save_stack

	int 2eh				;Reenter root COMMAND.COM.


	mov ax,cs			;Restore registers & stack.
	cli
	mov ss,ax
	mov sp,cs:stk_ptr
	sti
	mov ds,ax
	pop di				
	pop es				;es:di=seg:offset of COMMAND's data area

;------------------------------------------------------------------------------
	call check_error		;Hard error or ctrl-c during batch file?
	cmp error,01			;If so, need to flush disc buffers.
	jnz x1
	mov ah,0dh
	int 21h				;Disc reset.

x1:	call restore_batch_state	;Restore previous batch file, if any.
	call reset_for			;Restore for loop, if necessary
	cmp first,01 
	jz x2

	call restore_previous_2e	;Restore COMMAND's info on previous 
	jmp x3				; XCALL if any.  (This gurantees that
					; COMMAND.COM will return control to
					; previous XCALL after our exit.)

x2:	call reset_echo_flag		;Restore echo state

x3:	mov ah,4ch			;Return to COMMAND.COM.
	int 21h


;------------------------------------------------------------------------------
;This routine determines if a ctrl-c or hard error occurred during an
;xcall'ed batch file or for loop.  If so, the interrupted batch and for blocks
;are released and COMMAND's pointers are set to zero. Call with ES=COMMAND seg.
;------------------------------------------------------------------------------
check_error proc near
	mov bx,batch_ptr_address	;If COMMAND'S batch ptr clear, no error.
	cmp word ptr es:[bx],0000h
	jz check_for_flag

	mov error,01
	cmp version,version_three_one
	jge terminate_batch
	mov dx,offset batch_terminate_mes  ;The only way xcall can gain
	mov ah,9			; control after a ctrl-c in
	int 21h				; batch file under 2.x-3.0 is if
					; user answered no to "Terminate
					; Batch file?"
terminate_batch:	
	mov bx,word ptr es:[bx]		;Get batch block address.
	cmp version,version_three_three
	jge terminate_batch3_3    

	call release_command_block	;Release batch block

	mov bx,batch_ptr_address	;Clear COMMAND's batch blk ptr
	mov word ptr es:[bx],0000h
	jmp check_for_flag

terminate_batch3_3:
	call release_batch_block3_3	;Release batch block(s)

check_for_flag:
	mov bx,for_flag_address		;Get for flag offset
	cmp byte ptr es:[bx],00h	;If flag set there was an error
	jz ce1
	mov error,01
	mov byte ptr es:[bx],00h	;Clear for flag

ce1:	cmp version,version_three_zero	
	jge check_for_block		;Under versions 3.x, for block may be
	ret				;allocated, even if for flag clear.

check_for_block:
	cmp word ptr es:[bx+1],0000h	;Is for block clear?
	jnz release_for_block
	ret

release_for_block:			;No, so deallocate block.
	mov error,01
	mov bx,word ptr es:[bx+1]	;Get "for" block address
	call release_command_block	;Release for block
	mov word ptr es:[bx+1],0000h	;Clear for block pointer
	ret
check_error endp

;------------------------------------------------------------------------------
;Release_command_block deallocates a memory block owned by COMMAND.COM.
;Call with BX=segment of block to release and ES=COMMAND.COM segment.
;------------------------------------------------------------------------------
release_command_block proc near	
	push bx
	mov bx,es			;es=COMMAND.COM's psp.
	mov ah,50h			;Set current psp to COMMAND's psp.
	int 21h
	pop bx				

	push es				

	mov es,bx			;Deallocate memory block
	mov ah,49h			
	int 21h

	mov bx,cs
	mov ah,50h			;Reset psp.
	int 21h

	pop es
	ret
release_command_block endp

;------------------------------------------------------------------------------
;This procedure deallocates COMMAND's (3.3+) current batch block.  If the 
;current batch file was call'ed from another (previous) for loop or batch file,
;these too are deallocated.  This continues until chain of all calling batch
;and for processes have been deallocated.  Then psp and echo are reset.
;Call with BX=address of current batch data block for interrupted batch process
;and ES=COMMAND.COM segment.
;------------------------------------------------------------------------------
release_batch_block3_3 proc near
	push bx				;Make current psp = COMMAND.COM
	mov bx,es			
	mov ah,50h			
	int 21h
	pop bx				

chk_calling_for:			;Was this batch file called
	push es 			; from a for loop?			
	push di 			
	xor di,di
	mov es,bx			;Now es = current batch block.
	mov bx,es:[di].previous_for_blk	
	cmp bx,0000 			;bx=calling for loop, if any
	jz lose_current_block		

	push es				;Deallocate calling "for" block
	mov es,bx
	mov ah,49h 			
	int 21h 
	pop es

;Save info on echo & calling batch & then deallocate current batch block:
lose_current_block:			
	mov dl,byte ptr es:[di].prev_echo_flag	;Save previous echo status.
	mov bx,es:[di].previous_batch_blk	;Save seg of previous batch blk

	mov ah,49h 			;Deallocate current batch block
	int 21h 

	pop di 				;es:di =COMMAND'S data area seg:offset
	pop es 

	mov es:[di].batch_block_pointer3,bx	;Set COMMAND batch ptr=previous
						; (calling) batch file,if any.
	dec word ptr es:[di].batch_counter3_3	;Decrement COMMANDS's counter.
	jnz chk_calling_for			;If more left do them.

	mov byte ptr es:[di].echo_flag3_3,dl	;Restore previous echo state.

	mov bx,cs			;Reset psp.
	mov ah,50h		
	int 21h
	ret
release_batch_block3_3 endp

;-------------------------------------------------------------------------------
;Restore_batch_state restores COMMAND.COM's batch block pointer. Call with
;ES = COMMAND'S seg & DI = offset of COMMAND's data area.
;-------------------------------------------------------------------------------

restore_batch_state proc near

	mov bx,batch_ptr_address	;Reset COMMAND's batch ptr to what it
	mov ax,old_batch_block		; was before INT 2Eh
	mov word ptr es:[bx],ax

	cmp version,version_three_zero
	jae rbs_3x 

	mov ax,word ptr old_batch_fileptr  ;If version 2.x we also have to 
	mov word ptr es:[bx+2],ax	; restore the file pointer.
	mov ax,word ptr old_batch_fileptr+2
	mov word ptr es:[bx+4],ax
	ret

rbs_3x:
	cmp version,version_three_three
	jb rbs1
					;If 3.3+ we also have to restore the
	mov ax,old_batch_counter	; batch counter.
	mov word ptr es:[di].batch_counter3_3,ax
	
rbs1: ret

restore_batch_state endp

;-------------------------------------------------------------------------------
;Reset_for resets the for flag and (in versions 3.0+) the pointer to the for
;processing block.  Call with ES = COMMAND'S segment.
;-------------------------------------------------------------------------------
reset_for proc near
	mov al,byte ptr old_for_flag
	mov bx,for_flag_address
	mov byte ptr es:[bx],al
	cmp version,version_three_zero	;No for block in ver. 2.x
	jge rf1
	ret

rf1: 	mov ax,old_for_block
	mov word ptr es:[bx+1],ax
	ret
reset_for endp

;-------------------------------------------------------------------------------
;Restore_previous_2e restores COMMAND'S info on previous 2Eh caller.  This
;allows COMMAND.COM to return control to previous caller on our exit. Call with
;ES:DI = seg:offset of COMMAND'S data area.
;-------------------------------------------------------------------------------
restore_previous_2e proc near
	mov ax,previous_2e_psp		;Reset COMMAND 2eh info on caller's psp	
	mov es:[di].twoe_caller_psp,ax
	mov ax,previous_2e_ip
	mov es:[di].twoe_caller_ip,ax	;Reset COMMAND 2eh info on caller's ip
	mov ax,previous_2e_cs
	mov es:[di].twoe_caller_cs,ax	;Reset COMMAND 2eh info on caller's cs
	mov bx,twoE_flagoffset		;Restore COMMAND 2eh flag.
	mov ax,previous_2e_flag
	mov word ptr es:[bx],ax
	ret
restore_previous_2e endp

;-------------------------------------------------------------------------------
;Reset_echo_flag restores COMMAND's echo flag (2.1 - 3.2). to what it was 
;prior to INT 2Eh.  Call with ES:DI = seg:offset of COMMAND'S data area.
;-------------------------------------------------------------------------------
reset_echo_flag proc near
	cmp version,version_three_three
	jge ref2
	mov al,byte ptr old_echo_flag
	cmp version,version_three_two 
	jge ref_3_2 
	cmp version,version_three_zero
	jge ref_3_0

;version 2 - restore echo to what it was prior to xcall:
	mov byte ptr es:[di].echo_flag2,al
	ret

ref_3_0:					;(For 3.0 & 3.1)
	mov byte ptr es:[di].echo_flag3_0,al
	ret

ref_3_2:
	mov byte ptr es:[di].echo_flag3_2,al

ref2:
	ret
reset_echo_flag endp


even
stack_space		db  64 dup  (?)
endhere			label byte	

;==============================================================================
;ERROR ROUTINES
error1mes		db "Requires DOS 2.1 or later.",0dh,0ah,"$"
error2mes		db "Error: Interrupt 2Eh vector has been "
			db "altered.",0dh,0ah,"$"
error1:
	mov dx,offset error1mes 
	mov ah,09h 
	int 21h 
	int 20h

error2:
	mov dx,offset error2mes 
	mov ah,09h
	int 21h

	mov ah,4ch			;Terminate.
	int 21h 


;==============================================================================

start label near 

	mov ah,30h			;Get version.
	int 21h
	xchg ah,al
	cmp ax,version_two_one 		;Exit if not 2.1 or later.
	jb error1 

	mov version,ax

	call check_vector		;Get 2eh vector - points to COMMAND?
	jc error2			;If not, exit.

	mov di,es:[bx+3]		;Int 2eh vector offset + 3 = address 
					; of COMMAND's data area.
					;es:di now = COMMAND'S data area.

	call check_command_string	;Check for redirection.
	call save_previous_2eh		;Check if another 2eh in progress	
	call save_batch_state		;Check if batch file in progress
	call save_echo_state		;Save contents of echo flag
	call save_for_state		;Check if for loop in progress

	mov si,80h			;Point si to command string.

	mov sp,offset endhere		;Move stack to safe area so we can
					; reduce memory allocation.

	push es				;Save COMMAND's segment
	mov ax,cs			;Set up to reduce memory allocation
	mov es,ax
	mov ah,04ah 
	mov bx,(offset endhere-(offset begin-100h)+15)/16
	jmp reduce_memory

;===============================================================================

;------------------------------------------------------------------------------
;Check_vector determines if the int 2Eh vector points to COMMAND.COM. If so, it
;returns ES:BX pointing to segment:offset of 2Eh handler, otherwise it sets 
;the carry flag.
;-------------------------------------------------------------------------------
check_vector proc near
	xor ax,ax			;Get interrupt 2eh vector.
	mov es,ax 
	mov bx,2eh * 4
	les bx,es:[bx] 			;es:bx = segment:offset.

	mov ax,es			;Does 2eh vector point to COMMAND.COM?
	cmp word ptr es:[owner_id],ax	;  (COMMAND.COM owns itself.)
	jz cv1
	stc				;If not, set carry.
	ret
cv1: 	clc
	ret
check_vector endp

;-------------------------------------------------------------------------------;Check_command_string removes first & last quotation marks from command
;string.  This lets xcall pass redirection request to COMMAND.COM. This
;routine saves DI & ES.
;-------------------------------------------------------------------------------
check_command_string proc near		
	push di
	push es
	mov ax,ds
	mov es,ax

	xor ch,ch
	mov cl,byte ptr ds:[080h]	;Length of command tail stored at 80h
	jcxz end_check			;All done if no command tail
	cld				;Check for first quotation mark -
	mov al,'"'			; replace with null (20h) if present.
	mov di,82h			;Command tail starts at 82h.
	repne scasb
	jnz end_check
	mov byte ptr [di-1],20h
			
	std				;Change direction & check for
	add di,cx			; last quotation mark.
	dec di
	dec di
	repne scasb
	cld 
	jnz end_check
	mov byte ptr [di+1],20h

end_check:
	pop es
	pop di
	ret
check_command_string endp

;------------------------------------------------------------------------------
;This routine determines if an Int 2Eh is already in progress and, if so,
;saves the offset and contents of COMMAND.COM's 2Eh flag and address 
;information on previous 2Eh caller.  If an int 2Eh is not in progress a flag 
;("first") is set to indicate this. Call with ES=COMMAND.COM segment and
;DI = offset of COMMAND's data area.
;------------------------------------------------------------------------------
save_previous_2eh proc near
	mov bx,es:[bx+27h]    		;Offset for Int 2eh vector + 27h =
	cmp word ptr es:[bx],0000h	; address of COMMAND's 2eh flag.  
	jz sp1				;Is it set?
	mov ax,es:[bx]

	mov twoe_flagoffset,bx		;Save address of 2eh flag.
	mov previous_2e_flag,ax		;Save contents of 2eh flag.
	mov ax,es:[di].twoe_caller_psp	;Save previous 2eh caller's psp.
	mov previous_2e_psp,ax		 
	mov ax,es:[di].twoe_caller_ip	;Save previous 2eh caller's ip.
	mov previous_2e_ip,ax		
	mov ax,es:[di].twoe_caller_cs	;Save previous 2eh caller's cs.
	mov previous_2e_cs,ax	
	ret

sp1:	mov first,01			;No, we are first 2eh caller.
	ret
save_previous_2eh endp

;------------------------------------------------------------------------------
;Save_batch_state determines if a batch file is in progress and, if so,
;saves the offset and contents of COMMAND's batch file data block pointer.
;The pointer is then set to zero. Call with ES = COMMAND.COM segment &
;DI = offset of COMMAND's data area.
;------------------------------------------------------------------------------
save_batch_state proc near
	cmp version,version_three_zero
	jae sbs1 

;For 2.10 & 2.11:
	mov bx,offset batch_block_pointer2  ;Save address of batch pointer
	add bx,di
	mov batch_ptr_address,bx
					;Is a batch process pending?
	cmp word ptr es:[bx],0000h
	jz sbs_end
	mov ax,word ptr es:[bx]
	mov old_batch_block,ax		;Save current batch pointer.
	mov word ptr es:[bx],0000h	;Zero block pointer.
	mov ax,word ptr es:[di].batch_fileptr	;Save batch fileptr.
	mov word ptr old_batch_fileptr,ax
	mov ax,word ptr es:[di].batch_fileptr+2
	mov word ptr old_batch_fileptr+2,ax
	mov word ptr es:[di].batch_fileptr,0000h  ;Zero batch fileptr.
	mov word ptr es:[di].batch_fileptr+2,0000h 
	ret

;for version 3 and later:
sbs1:		
	mov bx,offset batch_block_pointer3  ;Save offset of batch pointer
	add bx,di
	mov batch_ptr_address,bx
	cmp word ptr es:[bx],0000h	;Batch process pending?
	jz sbs_end
	mov ax,es:[bx]	
	mov old_batch_block,ax		;Save current batch pointer.
	mov word ptr es:[bx],0000h	;Reset COMMAND's batch pointer.

	cmp version,version_three_three	;If 3.3+ save "call" counter.
	jb sbs_end 
		
	mov ax,word ptr es:[di].batch_counter3_3
	mov old_batch_counter,ax
					;Zero batch call counter.
	mov word ptr es:[di].batch_counter3_3,0000h 

sbs_end:
	ret
save_batch_state endp


;------------------------------------------------------------------------------
;Save_echo_state saves the echo flag for versions 2.1 - 3.2. 
;Call with ES = COMMAND.COM segment & DI = offset of COMMAND's data area.
;------------------------------------------------------------------------------
save_echo_state proc near
	cmp version,version_three_three
	jge ses4  
	cmp version,version_three_two
	jge ses2
	cmp version,version_three_zero
	jge ses1

;for version 2.x:
	mov cl,byte ptr es:[di].echo_flag2
	jmp ses3

ses1:					;for 3.0 & 3.1
	mov cl,byte ptr es:[di].echo_flag3_0
	jmp ses3

ses2:					;for 3.2
	mov cl,byte ptr es:[di].echo_flag3_2

ses3: 
	mov old_echo_flag,cl

ses4:
	ret
save_echo_state endp

;------------------------------------------------------------------------------
;Save_for_state saves the offset address of COMMAND's "for" block, checks if a 
;"for" loop is being executed and, if so, saves and then clears the for flag
;and the pointer to the for process block. Call with ES=COMMAND.COM segment
;and DI=offset of COMMAND's data area.
;------------------------------------------------------------------------------

save_for_state proc near
	cmp version,version_four_zero
	jge sf_4_0
	cmp version,version_three_three
	jge sf_3_3
	cmp version,version_three_two
	jge sf_3_2
	cmp version,version_three_zero
	jge sf_3_0
	jmp sf_2_1	

sf_4_0:					;4.0 & 4.01 
	mov ax,offset for_flag4_0	;Get offset of for flag.
	add ax,di
	mov for_flag_address,ax

	mov cl,es:[di].for_flag4_0	;Get contents of for flag.
	cmp cl,00			;If 0 then no for loop in progress.
	jz sf2	
	mov ax,es:[di].for_block_pointer4_0	;Get for data block pointer.

	mov byte ptr es:[di].for_flag4_0,00h	;Clear for flag & block pointer.
	mov word ptr es:[di].for_block_pointer4_0,0000h

sf1:
	mov old_for_flag,cl		;Save for flag.
	mov old_for_block,ax		;Save for block.  
sf2:	ret

sf_3_3:					;3.3 
	mov ax,offset for_flag3_3	;Get offset of for flag.
	add ax,di
	mov for_flag_address,ax

	mov cl,es:[di].for_flag3_3	;Get contents of for flag.
	cmp cl,00			;If 0 then no for loop in progress.
	jz sf2
	mov ax,es:[di].for_block_pointer3_3	;Get for data block pointer.

	mov byte ptr es:[di].for_flag3_3,00h	;Clear for flag & block pointer
	mov word ptr es:[di].for_block_pointer3_3,0000h
	jmp sf1

sf_3_2:					;3.2
	mov ax,offset for_flag3_2	;Get offset of for flag.
	add ax,di
	mov for_flag_address,ax

	mov cl,es:[di].for_flag3_2	;Get contents of for flag.
	cmp cl,00h			;If 0 then no for loop in progress.
	jz sf2
	mov ax,es:[di].for_block_pointer3_2	;Get for data block pointer.

	mov byte ptr es:[di].for_flag3_2,00h	;Clear for flag & block pointer.
	mov word ptr es:[di].for_block_pointer3_2,0000h
	jmp sf1

sf_3_0:					;3.0 & 3.1
	mov ax,offset for_flag3_0	;Get offset of for flag.
	add ax,di
	mov for_flag_address,ax
	
	mov cl,es:[di].for_flag3_0	;Get contents of for flag
	cmp cl,00h			;If 0 then no for loop in
	jz sf2
	mov ax,es:[di].for_block_pointer3_0	;Get for data block pointer.
	
	mov byte ptr es:[di].for_flag3_0,00h	;Clear for flag & block pointer.
	mov word ptr es:[di].for_block_pointer3_0,0000h
	jmp sf1

sf_2_1:					;2.1 & 2.11
	mov ax,offset for_flag2		;Get offset of for flag.
	add ax,di
	mov for_flag_address,ax

	mov cl,es:[di].for_flag2	;Get contents of for flag.
	cmp cl,00h			;If 0 then no for loop in progress.
	jz sf2

	mov byte ptr es:[di].for_flag2,00h	;Clear the for flag
	xor ax,ax				;No for data blk in ver 2.x.
	jmp sf1
save_for_state endp

code ends
	end begin
	END
