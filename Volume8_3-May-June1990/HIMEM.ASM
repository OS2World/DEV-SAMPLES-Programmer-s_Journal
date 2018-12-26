;HI-MEM.ASM
;This program contains a BIOS patch in a TSR running in HI-MEMORY.
;The module contains:
;********************
;       GATE_A20:This module is packed into the PSP before termination. It
;resides in normal memory as a TSR, traps calls to the BIOS extended memory
;block move function (INT 15H : AH = 87H) and gates address line 20 open after
;each call.
;
;       EUROTRS:Printer interface to the TSR 2100 printer.
;
;conditionals************************

TRUE    equ 0ffh
FALSE   equ 0

_80386  equ TRUE
TESTING equ FALSE

;equates*****************************

ON      equ 0ffh                ;Uniform codes for ON/OFF toggles
OFF     equ 00h

LF              EQU     0AH             ;ASCII LINEFEED
CR              EQU     0DH             ;ASCII RETURN


;-------------
;equates for the INT 2fH handler
;-------------
KERNEL_ID       equ 0FFh
EUROTRS_ID      equ KERNEL_ID
INSTALLED       equ 0FFh                ;indicates installed

;-------------
;function codes supported: ( placed by caller in AL )
;-------------
GET_INSTALLED_STATE     equ 0
;-------------
;This function is supported by EUROTRS
;-------------
STATUS                  equ 4           ;return ES:[DI] ---> STATUS_FLAG

;--------------
;8042 KEYBOARD CONTROLLER equates
;--------------

KB_STATUS_PORT  equ 64H
PORT_A          equ 60H

ENABLE_A20      equ 0DFH
DISABLE_A20     equ 0DDH
WRITE2_8042     equ 0D1H

SUCCESS         equ 0   ;RETURN CODES
FAILURE         equ 2   ;8042 could not perform the command
BUFFER_FULL     equ FAILURE

;macros*************

CALLF   macro
        db 09ah         ;code for a far call to the immediate following
                        ;dword pointer
        endm




;program**********************************************************************;
;
;ACHTUNG!!! BE VERY CAREFUL WITH ASSUME STATEMENTS THROUGHOUT!!!!
;EACH PROCEDURE (AND I MEAN EACH!) SHOULD HAVE AN ASSUME STATEMENT AS PART
;OF ITS HEADER. THINK OF IT AS PART OF THE PROCEDURE DECLARATION.
;
TSRGROUP        GROUP CODESEG,DATASEG,INITSEG

                TSR     equ TSRGROUP    ;for group overrides

;--------------
;SPECIFY THE LOAD ORDER FOR THE LINKER
;--------------
CODESEG SEGMENT BYTE PUBLIC 'PROG'
CODESEG ENDS
;
DATASEG SEGMENT BYTE PUBLIC 'DATA'
DATASEG ENDS
;
INITSEG SEGMENT BYTE PUBLIC 'INIT'
INITSEG ENDS
;

;--------------
;SOME USEFUL ADDRESSES IN PSP
;--------------
CODESEG SEGMENT BYTE PUBLIC 'PROG'
        ORG 2CH
ENVIRONMENT     dw ?

CODESEG ENDS

;--------------
;START OF ACTUAL PROGRAM SEGMENTS
;--------------
;
;--------------
DATASEG SEGMENT BYTE PUBLIC 'DATA'
                ASSUME DS:TSRGROUP

;--------------
;EUROTRS resident data area
;--------------
STATUS_FLAG     db ON

CONVERSION_TABLE        LABEL BYTE
;--------------
;This is a simple look-up table to convert IBM hi ASCII codes into codes 
;understood by my not so compatible printer.
;This is a translation table for codes 128 to 255 ONLY.
;To test this table replace each entry with a known character
;--------------
        DB 080H,0B8H,0BBH,083H,0B6H,0A1H,086H,0A2H
        DB 088H,089H,0BDH,0A9H,0AFH,0BAH,0B1H,08FH
D144    DB 090H,091H,092H,093H,0B7H,095H,096H,097H
        DB 098H,0B2H,0B3H,0B4H,0A3H,0B0H,09EH,0BFH
D160    DB 0A0H,0A1H,0A2H,0A3H,0A4H,0A5H,0A6H,0A7H
        DB 0A8H,0F0H,0F2H,0AEH,0ACH,0ADH,0AEH,0AFH
D176    DB 0EFH,0EFH,0EFH,0F5H,0F9H,0B5H,0B6H,0B7H
        DB 0B8H,0B9H,0BAH,0BBH,0BCH,0BDH,0BEH,0F2H
D192    DB 0F6H,0F8H,0F3H,0F4H,0F1H,0FAH,0C6H,0C7H
        DB 0C8H,0C9H,0CAH,0CBH,0CCH,0CDH,0CEH,0CFH
D208    DB 0D0H,0D1H,0D2H,0D3H,0D4H,0D5H,0D6H,0D7H
        DB 0D8H,0F7H,0F0H,0EFH,0E8H,0E9H,0EAH,0E7H
D224    DB 0E0H,0B9H,0E2H,0E3H,0E4H,0E5H,0A5H,0E7H
        DB 0E8H,0E9H,0EAH,0EBH,0ECH,0EDH,0EEH,0EFH
D240    DB 0F0H,0F1H,0F2H,0F3H,0F4H,0F5H,0F6H,0A6H
        DB 0A7H,0F9H,0FAH,0FBH,0FCH,0FDH,0FEH,020H

DATASEG ENDS

;

CODESEG SEGMENT BYTE PUBLIC 'PROG'
                ASSUME CS:TSRGROUP,DS:TSRGROUP ;ES:TSRGROUP,SS:TSRGROUP
                ORG 10H ;THE FIRST 16 BYTES OF THE SEGMENT @ 0FFFFH ARE IN ROM

INT_17H label dword     ;BIOS Print routine
INT_17H_OFF     dw ?
INT_17H_SEG     dw ?

INT_2FH label dword     ;DOS multiplex interrupt
INT_2FH_OFF     dw ?
INT_2FH_SEG     dw ?

        ORG 5CH         ;BELOW THIS ADDRESS IS FOR DOS

INT_15H label dword     ;storage for the address of INT 15H to chain to
INT_15H_OFF     dw ?
INT_15H_SEG     dw ?

TARGET  label byte      ;target for the moved INT 15H handler

ZZZ     LABEL BYTE      ;N.B. THIS LABEL MUST BE AT AN OFFSET < 100H - GATE_A20_SIZE
        PUBLIC  ZZZ

;--------------
;RESIDENT CODE
;--------------
                ORG 100H

BEGIN:          jmp SETUP

                        ;----------------------;
                        ; MULTIPLEX  INTERRUPT ;
                        ;----------------------;


INT_2FH_HANDLER proc far
;--------------
;Look for the ID of KERNEL and the individual modules.
;--------------
        cmp ah,KERNEL_ID
        je MINE

        jmp CS:[INT_2FH]

MINE:   or al,al
        jnz INVALID_FUNCTION

        mov al,INSTALLED
INVALID_FUNCTION:
        iret

EUROTRS:
;------------
;       ENTRY:  AH = EUROTRS_ID
;------------
        cmp al,STATUS           ;only STATUS and RETURN_INSTALLED_STATE
        jne MINE                ;are supported by EUROTRS

        push CS
        pop ES                  ;return ES:[DI] ---> STATUS_FLAG
        mov di,offset TSR:[STATUS_FLAG]
        iret

INT_2FH_HANDLER endp


                        ;----------------------;
                        ;       EUROTRS        ;
                        ;----------------------;

INT_17H_HANDLER proc far
;--------------
;Interface to the TRS 2100 printer.
;--------------

                ASSUME DS:NOTHING,ES:NOTHING

        cmp CS:[STATUS_FLAG],ON
        jne DONE

        cmp ah,0                        ;PRINTER OUTPUT?
        jne DONE                        ;NO

        test al,80H                     ;HI ASCII CODE?
        jz DONE                         ;NO

        and al,7FH                      ;YES, CLOBBER THE HI BIT AND TRANSLATE
        push bx                         ;REG RETTEN
        mov bx,offset TSR:[CONVERSION_TABLE]    ;CS:[BX] ---> CONVERSION TABLE
        xlat byte ptr CS:[bx]           ;CONVERT
        pop bx
                
DONE:   jmp  CS:[INT_17H]               ;PASS ON THE TRANSLATED CODE

INT_17H_HANDLER endp


CODESEG ENDS
;
INITSEG SEGMENT BYTE PUBLIC 'INIT'
                ASSUME CS:TSRGROUP,DS:TSRGROUP
;--------------
;Throwaway code and data for the initialization of the resident portion
;--------------

;--------------
;INITDATA
;--------------
PROMPT          db 'KER386 installed. Bye!',CR,LF,'$'

LOADED_MSG      db 'KER386 is already loaded. Aborting!',CR,LF,'$'

BAD_DOS_MSG     db 'KER386 requires DOS 3.0 or higher. Aborting!',CR,LF,'$'

HARDERROR_MSG   db 'Cannot load KER386!',CR,LF,'$'
;--------------
;INITCODE
;--------------
SETUP:  mov ah,30h              ;be sure DOS version is ok
        int 21h
        cmp al,3
        jae VERSION_OK

        mov dx,offset TSR:[BAD_DOS_MSG]
        jmp short ABORT_EXIT

VERSION_OK:
        mov ax,KERNEL_ID shl 8
        int 2Fh
        or al,al
        jz CONTINUE

ABORT:  mov dx,offset TSR:[LOADED_MSG]
ABORT_EXIT:
        mov ah,09h              ;DOS display ASCII string function
        int 21h

        int 20h

CONTINUE:
        call GATE_A20           ;open up the first 64 KB above 1 MEG
        or al,al
        jz INSTALL

        mov dx,offset TSR:[HARDERROR_MSG]
        jmp short ABORT_EXIT

INSTALL:
;-----------------
;Move the essential functions to HI RAM
;-----------------
        mov si,10h
        mov di,si
        mov ax,0FFFFh
        mov ES,ax
        mov cx,offset TSR:[THE_END] - 10h
        CLD
        rep movsb

        CALLF                   ;call the routine at the address in the next dword
        dw offset TSR:[HI_RAM_ENTRY]
        dw 0FFFFH
;-------------------
;The code in HI RAM ends with a RETF, so control returns here after the call.
;-------------------
        mov ax,CS
        mov DS,ax       ;restore DS to CS
;-------------------
;get and save the address of the INT 15H routine
;-------------------
        mov ax,3515h    ;get the address of INT 15h from DOS
        int 21h
        mov [INT_15H_OFF],bx
        mov [INT_15H_SEG],ES

        mov ax,DS       ;restore ES to DS=CS
        mov ES,ax
;-------------------
;Move the code for gate_a20 into the PSP and establish residency.
;-------------------
        mov si,offset TSR:[INT_15H_HANDLER]
        mov di,offset TSR:[TARGET]
        mov cx,GATE_A20_SIZE
        CLD
        rep movsb
;--------------------
;now reset the interrupt routine
;--------------------
        mov ax,2515h
        mov dx,offset TSR:[TARGET]
        int 21h
;-------------
;free up the environment segment
;-------------
        mov ES,TSR:[ENVIRONMENT]
        mov ah,49h
        int 21h
;-------------
;establish TSR status
;-------------
        mov dx,0FFH
        int 27h

;-----------------------------------------------------------------------------;
;                       INIT ENTRY POINT IN HI MEMORY                         ;
;-----------------------------------------------------------------------------;

HI_RAM_ENTRY:
;------------------
;This is the entry point called by the original copy of the code after the move
;to high memory.
;------------------
        mov ax,CS
        mov DS,ax
        mov ES,ax
;-----------
;chain into INT 2Fh chain
;----------
        mov ax,352Fh
        int 21h
        mov [INT_2FH_SEG],ES
        mov [INT_2FH_OFF],bx
        mov ax,252Fh
        mov dx,offset TSR:[INT_2FH_HANDLER]
        int 21h
;-------------
;now Bios PRINT INTERRUPT
;-------------
        mov ax,3517h    ;get the address of INT 15h from DOS
        int 21h
        mov [INT_17H_OFF],bx
        mov [INT_17H_SEG],es
        mov ax,2517h
        mov dx,offset TSR:[INT_17H_HANDLER]
        int 21h

RETURN2CALLER:
        RETF                            ;RETURN TO CODE IN NORMAL MEMORY

;-----------------
;The next label marks the end of code transferred to hi memory
;-----------------
THE_END label byte

;------------------
;This code is packed into the PSP before termination.
;------------------

INT_15H_HANDLER proc far
;---------------
;Patch the BIOS EXTENDED MEMORY BLOCK MOVE function to gate address line 20.
;---------------
        cmp ah,87H              ;BIOS extended memory block move function
        je REGATE_A20

        jmp CS:[INT_15H]        ;N.B. must be "relocatable"

REGATE_A20:
        pushf                   ;simulate an interrupt
        call CS:[INT_15H]       ;must be "relocatable"

        pushf                   ;save the flags from the BIOS call
        call GATE_A20
        popf
        RETF 2          ;throw away user flags and return flags from BIOS call.

INT_15H_HANDLER endp


GATE_A20        proc near
;------------------------
;       ENTRY:  NONE
;       EXIT:   AL = STATUS CODE
;-------------------------
        push ax
        CLI
        call EMPTY_8042         ;be sure 8042 input buffer is empty
        jnz GATE_A20_X          ;quit if no go

        mov al,WRITE2_8042      ;enable the 8042 for a command
        out KB_STATUS_PORT,al
        call EMPTY_8042
        jnz GATE_A20_X

        mov al,ENABLE_A20       ;get the command
        out PORT_A,al           ;send it to the 8042
        call EMPTY_8042
GATE_A20_X:
        pop ax
        RET
GATE_A20        endp

EMPTY_8042      proc near
;---------------
;This routine waits for the 8042 input buffer to empty
;       ENTRY:  NONE (AX SAVED BY CALLER)
;       EXIT:   AL = RETURN CODE (SUCCESS or FAILURE)
;---------------
        push cx                 ;save scratch register
        xor cx,cx               ;set up a time out counter
EMPTY_LOOP:
        in al,KB_STATUS_PORT
        and al,BUFFER_FULL
        loopnz EMPTY_LOOP
        pop cx
        RET
EMPTY_8042      endp


GATE_A20_SIZE   equ $ - INT_15H_HANDLER

INITSEG ENDS
        END BEGIN
