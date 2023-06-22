*------------------------------------------------------------------------------
* Title      :	Read Input
* Written by :	Bryan
* Date       :	5/9
* Description:	Reads user defined memory location range
*------------------------------------------------------------------------------

* =============================================================================
*	Read User Selected Memory Region
* =============================================================================
*	Input
*		Reqeust two capitalized 8 hexadecimal for the user, saving the address
*		in STARTADDR and ENDADDR.
*	Notes:
*		At the end of the operation, any data in any given register can be
*		erased.
* =============================================================================
INPUT
	* Print message for first loction
	LEA		PROMPTMSG,A1
	MOVE.B	#14,D0
	TRAP	#15

	* Read Input
	LEA		INPUTVAL,A1
	LEA		STARTADDR,A2
	MOVE	#2,D0
	TRAP	#15
	JSR		CONVERT

	* Print message for second location
	LEA		SECONDMSG,A1
	MOVE.B	#14,D0
	TRAP	#15

	* Read Input
	LEA		INPUTVAL,A1
	LEA		ENDADDR,A2
	MOVE	#2,D0
	TRAP	#15
	JSR		CONVERT
	RTS					; Return to main (end of INPUT function)

* =============================================================================
*	Process User Input
* =============================================================================
CONVERT
	MOVE.B	(A1)+,D6	; Move char to convert
	CMP.B	#0,D6		; Check if char is null
	BEQ		ENDCNVT		; End conversion
	
	LSL.L	#4,D7		; Shifts D7 by a hex
	
	CMP.B	#'9',D6		; Checks if it is an alphabet
	BGT		CNVTALPHA	; Branch to alpha conversion
	
	SUBI.B	#'0',D6		; Convert ascii char to value
	ADD.B	D6,D7		; Add newly convert value to the whole value
	BRA		CONVERT
	
CNVTALPHA
	SUBI.B	#'A',D6		; Convert ascii char to value
	ADDI.B	#10,D6
	ADD.B	D6,D7		; Add newly convert value to whole value
	BRA		CONVERT
	
ENDCNVT
	MOVE.L	D7,(A2)		; Move converted address
	RTS					; Return

* =============================================================================
*	Variables and Constants
* =============================================================================
LF	EQU	$0A
CR	EQU	$0D

INPUTVAL	DS.B	9	; User input (8 char + null terminator)
STARTADDR	DC.L	0	; User prompted starting location
ENDADDR		DC.L	0	; User prompted ending location

PROMPTMSG	DC.B	'All inputs should be 8 hexadecimals!',CR,LF
			DC.B	'All alphabet should be capitalized!',CR,LF
			DC.B	'Enter a starting location:',CR,LF,0
			
SECONDMSG	DC.B	'Enter an ending location:',CR,LF,0







*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
