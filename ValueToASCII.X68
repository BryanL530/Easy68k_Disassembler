*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


* =============================================================================
*	V2A - Value to ASCII
* ============================================================================= 
*	Varaiables & Registers
*		All registers are free after use
* ----------------------------------------------------------------------------- 
*	CNVTDATA
*		A reserved long to save the value to convert
*	D3
*		Jump offset for jumptable
*	D7
*		Kept the count of byte to convert
*	A3
*		Based address for jumptable
*	A5
*		Used to navigate CNVTDATA
*	A6
*		Conversion output
* ============================================================================= 
V2A
	LEA		CNVTDATA,A5	; Setup value to navigate
	LEA		V2AJT,A3	; setup jumptable base address

V2ALOOP
	CMPI.B	#0,D7		; Check if the count of hex needed to convert to ASCII
	BGT		V2ACNVT		; Branch to process 
	RTS
	
V2ACNVT
	* Using Jumptable to write in values
	CLR.L	D3			; Make sure D3 is clear
	MOVE.B	(A5) ,D3	; Move the checking byte	
	LSR.B	#4 ,D3		; Cleanup so only one hex is inspected
	MULU.W	#6 ,D3		; Setup value for jumptable
	JSR		(A3, D3)

	CLR.L	D3			; Make sure D3 is clear
	MOVE.B	(A5)+ ,D3	; Move the checking byte	
	ANDI.B	#$0F ,D3	; Cleanup so only one hex is inspected
	MULU.W	#6 ,D3		; Setup value for jumptable
	JSR		(A3, D3)

	SUBQ.B	#1 ,D7		; Goes to the next loop
	BRA	V2ALOOP
	
V2AJT
	MOVE.B	#'0' ,(A6)+
	RTS
	MOVE.B	#'1' ,(A6)+
	RTS
	MOVE.B	#'2' ,(A6)+
	RTS
	MOVE.B	#'3' ,(A6)+
	RTS
	MOVE.B	#'4' ,(A6)+
	RTS
	MOVE.B	#'5' ,(A6)+
	RTS
	MOVE.B	#'6' ,(A6)+
	RTS
	MOVE.B	#'7' ,(A6)+
	RTS
	MOVE.B	#'8' ,(A6)+
	RTS
	MOVE.B	#'9' ,(A6)+
	RTS
	MOVE.B	#'A' ,(A6)+
	RTS
	MOVE.B	#'B' ,(A6)+
	RTS
	MOVE.B	#'C' ,(A6)+
	RTS
	MOVE.B	#'D' ,(A6)+
	RTS
	MOVE.B	#'E' ,(A6)+
	RTS
	MOVE.B	#'F' ,(A6)+
	RTS

	SIMHALT

CNVTDATA
	DC.L	0		; Reserve a long



*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
