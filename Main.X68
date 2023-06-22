*-----------------------------------------------------------
* Title      :	Disassembler Driver
* Written by :	Bryan Lin
* Date       :	5/19 (Last modified)
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
MAIN
	* Obtain memory region
	JSR		INPUT
	MOVEA.L	STARTADDR,A0	; Starts to loop for information
	
	* Prepare to print memory
	MOVE.B	#11,D0			; Using trap task 11
	CLR.L	D1
	MOVE.W	#$FF00,D1		; Value for clear screen
	TRAP	#15
	CLR.L	D2				; Clear loop counter register
	
	
READLOOP
	* Check if current address is in range
	CMPA.L	ENDADDR,A0
	BGE		ENDSIM
	
	* Convert memory region to ascii
	MOVE.L	#4,D7		; Converting 4 bytes
	MOVE.L	A0,CNVTDATA	; Move Memory location to convert
	LEA		ADDR,A6
	JSR		V2A
	
	* Print converted memory region
	LEA		ADDR,A1
	MOVE.B	#14,D0
	TRAP	#15

	JSR		DECODE

	* Loop management
	ADDQ.B	#1,D2		; Increment loop counter
	CMPI.B	#25,D2		; Check if D2 < 25
	BLT		READLOOP	; If true, loop again
	BRA		WAITENTR	; If not, go to WAITENR
	
WAITENTR
	* Print next page message
	LEA		NEXTPG,A1
	MOVE.B	#14,D0
	TRAP	#15
	
	* Read a char
	MOVE.B	#5,D0
	TRAP	#15
	CMPI.B	#CR,D1
	BNE		WAITENTR

	* Clear Screen for next page via trap task
	CLR.L	D2			; Reset loop counter
	MOVE.B	#11,D0
	MOVE.W	#$FF00,D1
	TRAP	#15
	BRA		READLOOP

ENDSIM
	* Print prompt message
	LEA		QUITMSG,A1
	MOVE.B	#14,D0
	TRAP	#15
	
	* Retrieving any keyboard inputto quit
	MOVE.B	#5,D0
	TRAP	#15
	
	SIMHALT
	
RTN
	RTS

* =============================================================================
*	Load other componenets
* =============================================================================
LF	EQU	$0A
CR	EQU	$0D
HT	EQU	$09

ADDR
	DCB.B	8,0			; Reserve space for 8 char
	DC.B	HT,0		; Follow the address by a space and null-terminator
NEXTPG	
	DC.B	'Press Enter to load the next page...',LF,CR,0
QUITMSG
	DC.B	'Press any key to quit...',LF,CR,0
CMDTXT
	DCB.B	40,0

	INCLUDE	'ReadInput.X68'
	INCLUDE 'ValueToASCII.X68'
	INCLUDE	'JumpTable.X68'
	INCLUDE	'Code1-3.X68'
	INCLUDE	'Code4.X68'
	INCLUDE	'Code5.X68'
	INCLUDE	'Code6.X68'
	INCLUDE	'Code7.X68'
	INCLUDE	'Code8.X68'
	INCLUDE	'Code9.X68'
	INCLUDE	'CodeC.X68'
	INCLUDE	'CodeD.X68'
	INCLUDE	'CodeE.X68'
	INCLUDE	'demo_test.X68'
	
	
    END    MAIN		; last line of source


























*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
