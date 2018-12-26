;			LAST UPDATE NOVEMBER 1989
;
;		ASSEMBLER:	TASM 1.0
;		LINKER:		TLINK 2.0
;	ASSEMBBLE WITH:
;		TASM BIOS
;		TLINK BIOS /T
;
;conditionals**************

TRUE	equ 0FFH
FALSE	equ 000H

_80386	equ TRUE

;group info*****************

TSRGROUP	GROUP CODESEG,DATASEG,INITSEG

TSR	equ TSRGROUP	;for group overrides

;includes****************


;equates*******************

ROM_SEG	equ 0F000H

ON	equ 0FFH
OFF	equ 0


;------------------
;interrupt control port of 8259 PIC
;------------------
INT_CONTROL	equ 20h
EOI		equ 20h		;End Of Interrupt code

;--------------
;8042 KEYBOARD CONTROLLER equates
;--------------

STATUS_PORT	equ 64H
PORT_A		equ 60H

ENABLE_A20	equ 0DFH
DISABLE_A20	equ 0DDH
WRITE2_8042	equ 0D1H
READ_FROM_8042	equ 0D0H

SUCCESS		equ 0	;RETURN CODES
FAILURE		equ 2	;8042 could not perform the command

OUTPUT_BUFFER_FULL	equ 1
INPUT_BUFFER_FULL	equ 2

CMOS_PORT		equ 70H

;--------------------
;DATA_SEG_TYPES
;--------------------
DATA_SEGMENT		equ 8 SHL 1
WRITABLE		equ 1 SHL 1	;BIT 0 = ACCESSED BIT
EXPAND_DOWN		equ 2 SHL 1	;FOR STACK SEGMENTS

;--------------------
;CODE_SEG_TYPES
;--------------------
CODE_SEGMENT		equ 12 SHL 1
READABLE		equ 1 SHL 1	;BIT 0 = ACCESSED BIT
CONFORMING		equ 2 SHL 1	;USED BY PROTECTION MECHANISM
					;SEE MORSE,ISAACSON,ALBERT PAGE 215
;--------------------
;SYSTEM AND GATE DESCRIPTOR TYPES
;--------------------
AVAIL_286_TSS		equ 1 SHL 1	;BIT 0 = ACCESSED BIT
LOCAL_DESCRIPTOR_TABLE	equ 2 SHL 1
CALL_GATE		equ 4 SHL 1
TASK_GATE		equ 5 SHL 1
_286_INT_GATE		equ 6 SHL 1
_286_TRAP_GATE		equ 7 SHL 1
AVAIL_386_TSS		equ 9 SHL 1
_386_CALL_GATE		equ 0CH SHL 1
_386_INT_GATE		equ 0EH SHL 1
_386_TRAP_GATE		equ 0FH SHL 1

;-------------------
;PRIVILIDGE LEVELS
;-------------------
KERNAL			equ 0 SHL 5
SYSTEM			equ 1 SHL 5
EXTENSIONS		equ 2 SHL 5
APPLICATION		equ 3 SHL 5

PRESENT			equ 1 SHL 7


;macros********************

JMPF	macro
	db 0EAH		;jump far immediate
	endm

JMPS	macro TARGET
	jmp short TARGET
	endm

SEG_DESCRIPTOR	macro BASE,LIMIT,GRANULARITY,ACCESS_RIGHTS
;--------------------
;BASE IS A 32 BIT PHYSICAL ADDRESS
;LIMIT IS A 20 BIT QUANTITY
;	IF GRANULARITY = 0 LIMIT IS IN BYTES
;	IF GRANULARITY = 1 LIMIT IS IN PAGES = 4096 = 2^12 BYTES, SO 32 BIT BYTE LIMIT
;--------------------
	dw 0FFFFH AND LIMIT			;LO 16 BITS OF SEG LIMIT
	dw 0FFFFH AND BASE			;LO 16 BITS OF BASE ADDRESS
	dw ( (BASE SHR 16) AND 0FFH ) + ( (ACCESS_RIGHTS) SHL 8)
;N.B. TASM BUG! NEED ( ) AROUND ACCESS_RIGHTS OR MACRO DOES NOT EXPAND CORRECTLY
						;BITS 16 - 23 OF BASE
						;ACCESS_RIGHTS
	dw ( (LIMIT SHR 16) AND 0FH) + (GRANULARITY SHL 7) + ( (BASE SHR 16) AND 0FF00H)
						;HI NIBBLE OF LIMIT
						;GRANULARITY IN BIT 7
						;HI BYTE OF BASE
	endm


;structures****************

XMBMOVE_GDT	struc
	UNUSABLE	dq ?
	XMBMOVE_GDT_PTR	dq ?	;points to GDT, gives segment limit, etc.
	SOURCE_DESC	dq ?	;descriptor for source
	TARGET_DESC	dq ?	;ditto target
	BIOS_CS		dq ?	;CS descriptor filled in by BIOS
	BIOS_SS		dq ?	;ditto for SS
XMBMOVE_GDT	ends


DESCRIPTOR	struc
;-----------------------------------------------------------------------------;
;  simplified Segment Descriptor (entry in a Global/Local Descriptor Table)   ;
;-----------------------------------------------------------------------------;
SEGMENT_LIMIT	dw ?
SEGMENT_BASE	dw ?	;24 BIT physical address
		dw ?
		dw ?
DESCRIPTOR	ends


;dummy segments************

ROM	segment at 0F000H

ROM	ends

;

INT_VECTORS_SEG	segment at 0000H
	ORG 15*4
INT_15H_VECTOR	dd ?
INT_VECTORS_SEG	ends


;publics*******************



;--------------
;SPECIFY THE LOAD ORDER FOR THE LINKER
;--------------
;
CODESEG	SEGMENT BYTE PUBLIC 'PROG'
CODESEG	ENDS
;
DATASEG	SEGMENT BYTE PUBLIC 'DATA'
DATASEG	ENDS
;
INITSEG	SEGMENT BYTE PUBLIC 'INIT'
INITSEG	ENDS
;
;--------------
;START OF ACTUAL PROGRAM SEGMENTS
;--------------
;
;--------------
DATASEG	SEGMENT BYTE PUBLIC 'DATA'
		ASSUME DS:TSRGROUP
;--------------
;Resident data area
;--------------
;


;
LAST_BYTE	label byte		;mark the end of resident data and code
;
DATASEG	ENDS

;

CODESEG	SEGMENT BYTE PUBLIC 'PROG'
		ASSUME CS:TSRGROUP,DS:TSRGROUP ;ES:TSRGROUP,SS:TSRGROUP
		ORG 100H
;--------------
;RESIDENT CODE
;TSR OVERRIDE AUF ALLE DATAVARIABLEN IM DATASEGMENT NICHT VERGESSEN!!!
;--------------
BEGIN:		jmp SETUP

			;---------------------------;
			;EXTENDED MEMORY BLOCK MOVE ;
			;---------------------------;

INT_15H_HANDLER	proc far
;---------------
;Trap calls to the extended memory block move function, and replace with our
;own routine.
;	ENTRY:	GATE_A20 IS OPEN
;		SEGMENT LIMIT ON DS AND ES RELAXED TO 4 GIGABYTE
;		AH = FUNCTION CODE
;----------------
	cmp ah,87h		;EXTENDED MEMORY BLOCK MOVE?
	je XMBMOVE		;YES

	jmpf			;NO, PASS ON THE INTERRUPT
INT_15H	label dword
INT_15H_OFF	dw ?
INT_15H_SEG	dw ?

XMBMOVE:
;----------------
;	ENTRY:	AL = EXTENDED MEMORY BLOCK MOVE CODE
;		CX = # WORDS TO MOVE
;		ES:[SI] ---> GDT TO USE
;	EXIT:	AX = 0 ===> NO ERROR
;		ZR & NC ===> DITTO
;----------------
.386
	push ecx
	push esi
	push edi
.8086
	push DS
	push ES
	pushf
	STI
.386
	mov edi,dword ptr ES:[si].TARGET_DESC.SEGMENT_BASE
	and edi,0FFFFFFH		;mask off hi byte
	mov esi,dword ptr ES:[si].SOURCE_DESC.SEGMENT_BASE
	and esi,0FFFFFFH		;ditto
.8086
	xor ax,ax
	mov DS,ax
	mov ES,ax
;-----------------------
;	DS:[ESI] ---> SOURCE
;	ES:[EDI] ---> TARGET	
;-----------------------
	CLD
.386
	movzx ecx,cx			;zero hi word
	shr ecx,1			;convert word count to dword count
;------------------------
;Since the next instruction uses an address size of 32 bits the register ECX
;is used for the count. LOGO, BUT BE WARNED!
;------------------------
	rep movs dword ptr [edi],dword ptr [esi]
;------------------------
;move the odd word if need be: do not empty prefetch queue with a branch
;------------------------
	rcl ecx,1				;recover remainder mod 2 of word count
	rep movs word ptr [edi],word ptr [esi]	;move last word in odd case
.8086
	popf
XMBMOVE_X:
	pop ES
	pop DS
.386
	pop edi
	pop esi
	pop ecx
.8086
	xor ax,ax		;set no error condition
				;pretty cockey what?
	RETF 2

INT_15H_HANDLER	endp


CODESEG	ENDS

;

INITSEG	SEGMENT BYTE PUBLIC 'INIT'
		ASSUME CS:TSRGROUP,DS:TSRGROUP
;--------------
;Throwaway code and data for the initilization of the resident portion
;--------------
;--------------
;INITDATA
;--------------

;-------------------
;GLOBAL DESCRIPTOR TABLE FOR FOURGIG_SEG GIG!
;-------------------

GDT_PTR	label pword	;6 bytes of data for lgdt
GDT_LIMIT	dw ?
GDT_ADDRESS	dd ?

GDT	label word
;-----------------
;THIS GLOBAL DESCRIPTOR TABLE IS SUITABLE TO RUN A COM FILE IN PROTECTED MODE.
;SEG_DESCRIPTOR IS A MACRO IN STD_MACS.
;-----------------
		dw 4 dup (0)		;FIRST DESCRIPTOR UNUSABLE
CS_DESCRIPTOR	equ $ - GDT
	SEG_DESCRIPTOR 00000000H, 000FFFFH, 0, PRESENT+CODE_SEGMENT+READABLE
DS_DESCRIPTOR	equ $ - GDT
	SEG_DESCRIPTOR 00000000H, 000FFFFH, 0, PRESENT+DATA_SEGMENT+WRITABLE
FOURGIG_DESCRIPTOR	equ $ - GDT
	SEG_DESCRIPTOR 00000000H, 07FFFFFH, 1, PRESENT+DATA_SEGMENT+WRITABLE

GDT_END	label byte

BAD_CPU_MSG	db 'XTRABIOS needs an 80386 or 80486 to run. Aborting!',07,'$'


;-----------------
;INIT CODE
;-----------------

SETUP:	call CHK4386
	jnz INIT_1

	mov dx,offset TSR:[BAD_CPU_MSG]
	mov ah,09
	int 21H
	int 20H

INIT_1:	call GATE_A20
;--------------------
;one could error check here
;--------------------
INIT_2:
	call FOURGIG_SEGS
;------------------------
;and here
;------------------------
INSTALL:
;-------------------
;get the addresses of the interrupts we trap and place them in our code.
;-------------------
	xor ax,ax
	mov ES,ax
		ASSUME ES:INT_VECTORS_SEG
.386
	mov eax,ES:[INT_15H_VECTOR]
	mov [INT_15H],eax
.8086

COPY2ROM:
;----------------
;copy our BIOS to ROM
;----------------
	call OPEN_SHADOW_ROM

	mov ax,SEG ROM
	mov ES,ax
		ASSUME ES:ROM
	xor si,si
	xor di,di
	mov cx,offset TSR:LAST_BYTE
	CLD
	rep movsb

	call CLOSE_SHADOW_ROM

;------------------
;point interrupt vectors at our xtrabios handlers
;------------------
	xor ax,ax
	mov DS,ax
		ASSUME DS:INT_VECTORS_SEG
	CLI
.386
	mov [INT_15H_VECTOR],ROM_SEG SHL 16 + offset TSR:INT_15H_HANDLER
.8086
	STI
	int 20H






		ASSUME DS:TSRGROUP




OPEN_SHADOW_ROM	proc near
;---------------------------
;Flip bits in 8042 status register
;---------------------------
	CLI			;Disable interrupts
	call GET_PORT_A		;get 8042 status in AL
	or al,10h		;flip bit 4 on
	and al,0F7h		;bit 3 off
	call WRITE2_PORT_A	;send it to 8042
	STI			;Enable interrupts
	RET
OPEN_SHADOW_ROM	endp


CLOSE_SHADOW_ROM	proc near
;---------------------------
;Flip bits 3 and 4 of keyboard data port on.
;	EXIT:	AL = CURRENT STATUS
;---------------------------
	CLI			;Disable interrupts
	call GET_PORT_A		;get keyboard controller status in AL
	or al,18h		;flip bits 3 and 4 on
	call WRITE2_PORT_A	;send it
	STI			;Enable interrupts
	RET
CLOSE_SHADOW_ROM	endp



WRITE2_PORT_A	proc near
;------------------------
;	ENTRY:	AL = CODE TO SEND TO 8042
;-------------------------
	mov ah,al		;save command
	CLI
	call EMPTY_8042		;be sure 8042 input buffer is empty

	mov al,WRITE2_8042	;enable the 8042 for a command
	out STATUS_PORT,al
	call EMPTY_8042

	mov al,ah		;get the command
	out PORT_A,al		;send it to the 8042
	call EMPTY_8042
WRITE2_PORT_A_X:
	RET
WRITE2_PORT_A	endp


GET_PORT_A	proc near
;-------------------
;	EXIT:	AL = 8042 KEYBOARD CONTROLLER STATUS
;-------------------
	call EMPTY_8042		;wait for keyboard buffer to empty
	mov al,READ_FROM_8042	;al = 0D0h, read 8042 out port
	out STATUS_PORT,al	;port 64h, kybd cntrlr functn
GPA_LOOP:
	in al,STATUS_PORT	;port 64h, keyboard status
	test al,OUTPUT_BUFFER_FULL
	jz GPA_LOOP		;keep waiting until data appears

	in al,PORT_A		;get data for sw1 in AL
	RET			;return it
GET_PORT_A	endp


EMPTY_8042	proc near
;---------------
;This routine waits for the 8042 input buffer to empty
;	ENTRY:	NONE
;	EXIT:	8042 STATUS PORT EMPTY
;N.B. THIS COULD LEAD TO AN INFINITE LOOP ON A DEFECTIVE 8042
;---------------
EMPTY_LOOP:
	in al,STATUS_PORT
	test al,INPUT_BUFFER_FULL
	jnz EMPTY_LOOP

	RET
EMPTY_8042	endp

GATE_A20	proc near
;------------------------
;	ENTRY:	NONE
;	EXIT:	AL = STATUS CODE
;-------------------------
	CLI
	call EMPTY_8042		;be sure 8042 input buffer is empty

	mov al,WRITE2_8042	;enable the 8042 for a command
	out STATUS_PORT,al
	call EMPTY_8042

	mov al,ENABLE_A20	;get the command
	out PORT_A,al		;send it to the 8042
	call EMPTY_8042
GATE_A20_X:
	RET
GATE_A20	endp


CHK4386	proc near
;-----------------
;make sure we are running on an 80386
;	RETURN:	NZ ===> 80386
;		Z ===> ERROR
;-----------------
	push sp		;8086 pushs the NEW stack pointer
	pop ax
	sub ax,2
	cmp sp,ax	;was new stack pointer pushed?
	je CHK4386_X	;YES

;----------------
;If we get here it is an 80286 or an 80386.
;Try to set the hi bits in the flags.
;----------------
	mov ax,0f000H
	push ax
	popf
	pushf
	pop ax
	and ax,0f000h
;-----------------------
;If Z then it is not  386
;-----------------------
CHK4386_X:
	RET
CHK4386	endp


FOURGIG_SEGS	proc near
;------------
;	ENTRY:	NONE
;	EXIT:	DS,ES,FS,GS SEG LIMITS RELAXED TO 4 GIGABYTE
;		ALL REGISTERS PRESERVED
;------------
.386
	pushad
	push GS
	push FS
.8086
	push ES
	push DS
	pushf			;store flags for return from protected mode


	mov ax,CS		;get our segment address
;----------------
;WARNING!!!!!!	SELF MODIFYING CODE.
;----------------
	mov [THIS_CODESEG],ax	;store it as part of far jump instruction!!
.386
	movzx eax,ax
	shl eax,4		;make it a linear address: N.B. ONLY 20 BITS THOUGH
;-----------------
;INITIALIZE CS, DS DESCRIPTOR BASE ADDRESSES
;-----------------
	or dword ptr [GDT + CS_DESCRIPTOR  + 2],eax
	or dword ptr [GDT + DS_DESCRIPTOR  + 2],eax
;-----------------
;INITIALIZE PTR FOR LGDT
;-----------------
	add eax, offset TSR:[GDT]	;linear address of GDT
	mov [GDT_ADDRESS],eax		;store
.8086
	mov [GDT_LIMIT],offset TSR:[GDT_END] - TSR:[GDT] - 1	


;-----------
;Turn off ALL interrupts: even NMI. IDT will be invalid in protected mode.
;-----------
	CLI			;easy part
;-----------
;now hard part: NMI (see AT ROM BIOS LISTING 5-52)
;-----------
	in al,CMOS_PORT
	mov ch,al		;save current setting
	and ch,80H		;isolate the current NMI bit
	or al,80H		;set bit 15 to turn OFF NMIs
	out CMOS_PORT,al	;do it

	mov bx,CS		;save current code segment

;-------------
;switch to protected mode
;-------------
.386P
	lgdt CS:[GDT_PTR]	;load GDTR
	mov eax,CR0		;get control word
	or al,01B		;set protected mode bit
	mov CR0,eax		;switch modes
;--------------
;now executing in protected mode
;--------------
	jmpf			;clear prefetch queue
	dw offset TSR:[PROTECTED_MODE]
	dw CS_DESCRIPTOR	;in this protected mode segment
.8086
PROTECTED_MODE:
;-------------
;LOAD UP SOME REGISTERS
;-------------
	mov ax,DS_DESCRIPTOR
	mov SS,ax		;point SS at a valid stack segment
;-------------
;set segment limit for DS,ES,FS,GS to 4 gigabytes
;-------------
	mov ax,FOURGIG_DESCRIPTOR
	mov DS,ax
	mov ES,ax
.386
	mov FS,ax
	mov GS,ax
.8086
;-------------
;return to REAL mode
;-------------
.386P
	mov eax,CR0
	and al,NOT 01B		;turn off protected mode bit
	mov CR0,eax
.8086
;--------------
;clear prefetch queue: relies on self modification!!!!!!!
;--------------
	jmpf			;clear the prefetch queue!!!!!
THIS_LABEL	label word
	dw offset TSR:[RETURN2REALITY]
THIS_CODESEG	label word
 	dw ?
.8086

RETURN2REALITY:
;--------------
;restore segment registers
;--------------
	mov SS,bx		;bx = CS from real mode
	mov DS,bx
	mov ES,bx
	xor ax,ax
.386
	mov FS,ax
	mov GS,ax
.8086
;--------------
;restore NMI setting
;--------------
	in al,CMOS_PORT
	and al,7FH		;turn off NMI bit
	or al,ch		;restore old value
	out CMOS_PORT,al	;of NMI bit

	popf			;and flags
	pop DS
	pop ES
.386
	pop FS
	pop GS
	popad
.386
	RET

FOURGIG_SEGS	endp




INITSEG	ENDS
	END BEGIN
