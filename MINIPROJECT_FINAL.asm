
PA:    EQU 80H    ; LED output
PB:    EQU 81H    ; 7-segment display
PC:    EQU 82H    ; Keypad input
CTRL:  EQU 83H    ; 8255 control register

        ORG 0000H
	JMP MAIN
	ORG 002CH
	JMP SHOWVOTE

MAIN:
        LXI SP, 3FFFH
	MVI A, 00001110B
	SIM 
	EI

        ; Configure 8255: Port A & B = output, C = input
        MVI A, 89H
	OUT CTRL

	MVI A, 00H
	STA VOTEA
	STA VOTEB
	STA VOTEC
	OUT PA
	OUT PB
	OUT PC
START:
	;JMP CHKCODE
CHKKP:
	MVI A, 00H ; SHOW 0 7SEG
	OUT PB

	IN PC		;CHECK ANY KEYPRESS
	ANI 10H
	JZ CHKKP	;LOOP IF NO KEYPRESS

	IN PC
	;CPI 60H		;KEY 1 PRESSED
	CPI 00010000B 		;KEY 1 PRESSED
	JZ SELECT1

	;CPI 61H		;KEY 2
	CPI 00010001B		;KEY 2
	JZ SELECT2

	;CPI 62H		;KEY 3
	CPI 00010010B		;KEY 3
	JZ SELECT3

	JMP CHKKP	;IGNORE OTHER KEY
	HLT

CHKCODE:
	IN PC         ; read from keypad
	ANI 10H       ; is any key pressed? (Row signal)
	JZ CHKCODE      ; if not, keep checking

	IN PC         ; read again
	;ANI 0FFH      ; keep full byte (upper = row, lower = column)
	OUT PB        ; show raw keycode directly on 7-segment
	JMP CHKCODE


; --- Select candidate ---

SELECT1:
	; Increment vote
	LDA VOTEA
	INR A
	STA VOTEA

	; Show 'A'
	MVI A, 0CH      ; Index of 'A' in your table (77H)
	CALL LOOK
	OUT PB
	CALL CONFIRMLED	;LED TO CONFIRM VOTE REGISTERED
	CALL DELAY      

	; Show vote count
	LDA VOTEA
	DCR A		;TO GET 7SEG INDEX
	CALL LOOK
	OUT PB
	CALL DELAY

	JMP START

SELECT2:
        ; Increment vote
	LDA VOTEB
	INR A
	STA VOTEB

	; Show 'B'
	MVI A, 0DH      ; Index of 'B' in your table 
	CALL LOOK
	OUT PB
	CALL CONFIRMLED
	CALL DELAY      

	; Show vote count
	LDA VOTEB
	DCR A
	CALL LOOK
	OUT PB
	CALL DELAY

	JMP START

SELECT3:
         ; Increment vote
	LDA VOTEC
	INR A
	STA VOTEC

	; Show 'C'
	MVI A, 0EH      ; Index of 'C' in your table 
	CALL LOOK
	OUT PB
	CALL CONFIRMLED
	CALL DELAY      

	; Show vote count
	LDA VOTEC
	DCR A
	CALL LOOK
	OUT PB
	CALL DELAY

	JMP START

SHOWVOTE:
;------ LED TO CONFIRM INTRPT------
	MVI A, 10101010B
	OUT PA
	CALL DELAY
	MVI A, 01010101B
	OUT PA
	CALL DELAY
	MVI A, 10101010B
	OUT PA
	CALL DELAY
	
;------ CAND A VOTE------
	; Show 'A'
	MVI A, 0CH      
	CALL LOOK
	OUT PB
	CALL DELAYL      ;LONGER DELAY
	LDA VOTEA
	DCR A
	CALL LOOK
	OUT PB
	CALL DELAYL
	
	
;------ CAND B VOTE------
	; Show 'B'
	MVI A, 0DH       
	CALL LOOK
	OUT PB
	CALL DELAYL    
	LDA VOTEB
	DCR A
	CALL LOOK
	OUT PB
	CALL DELAYL
	

;------ CAND C VOTE------
	; Show 'C'
	MVI A, 0EH      
	CALL LOOK
	OUT PB
	CALL DELAYL      
	LDA VOTEC
	DCR A
	CALL LOOK
	OUT PB
	CALL DELAYL
	

;----------------------
	EI
	RET

CONFIRMLED:
	; Blink LED 3 times
	MVI B, 03H

LEDLOOP:
	MVI A, 0FFH
        OUT PA
        CALL DELAY
        MVI A, 00H
        OUT PA
        CALL DELAY
        DCR B
        JNZ LEDLOOP

        RET

LEDLOOP_FAST:
	MVI B, 05H
	MVI A, 0FFH
        OUT PA
        CALL DELAY
        MVI A, 00H
        OUT PA
        CALL DELAY
        DCR B
        JNZ LEDLOOP_FAST

        RET

; --- Convert number to 7-segment ---
LOOK:
        LXI H, DATA7SEG
        ADD L
        MOV L, A
        MOV A, M
        RET

; --- Delay Routine ---
DELAYL:
	MVI C, 50H
	JMP DL_LOOP
DELAY:
        MVI C, 20H
DL_LOOP:
        DCR C
        JNZ DL_LOOP
        RET

; --- Var & Tables ---

        ORG 2000H
DATA7SEG:
        ;DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H
        ;DB 7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 71H
	;DFB 	06H, 5BH, 4FH, 77H, 66H, 6DH, 7DH, 7CH, 07H, 7FH, 6FH, 39H, 62H, 3FH, 76H, 5EH
	DFB 	06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 62H, 3FH, 76H, 77H, 7CH, 39H, 5EH
VOTEA:   	DFS 1    ; Vote count for candidate A
VOTEB:   	DFS 1    ; Vote count for candidate B
VOTEC:   	DFS 1    ; Vote count for candidate C
