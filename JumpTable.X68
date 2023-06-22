*------------------------------------------------------------------------------
* Title      :	Jump Table
* Written by :	Bryan Lin
* Date       :	5/19
* Description:	Jump to the corresponding opcode, along with helper function
*------------------------------------------------------------------------------

* =============================================================================
*	Find Jump Table
*		Find the corresponding jump table for the command
*	Notes:
*		This operation assumes A4 has the current processing command address
*		This operation also uses A5, but can be cleared after operation
* =============================================================================
*	Variable & Register
* =============================================================================
*	D3
*		Jump offset
*	A3
*		Jumptable base
* =============================================================================
DECODE
	JSR		CLRCMDTXT	; Empty contents of CMDTXT for this round of printing
	CLR.L	D4			; Clear D4 for this round of opcode inspection
	MOVEA.L	A0,A2		; Move A0 to A2 for new PC address after this round
	LEA		CMDTXT,A6	; Move CMDTXT to A6 for generate print
	
	* Setup for jumptable
	CLR.L	D3			; Makes sure D3 is clear at the start of operation
	MOVE.B	(A0),D3		; Moves Byte (bit 8 ~ 15 of opcode) to D3
	LSR.B	#4,D3		; Logical shift so there's only bit 12 ~ 15
	MULU.W	#6,D3		; x6 so the it goes to the corresponding jump table
	LEA		JMPTB,A3	; Load A5 with jump table value
	JMP		(A3 ,D3)	; Jump to corresponding opcode decoder

JMPTB
	JMP	CODE0
	JMP	CODE1
	JMP	CODE2
	JMP	CODE3
	JMP	CODE4
	JMP	CODE5
	JMP	CODE6
	JMP	CODE7
	JMP	CODE8
	JMP	CODE9
	JMP	CODEA
	JMP	CODEB
	JMP	CODEC
	JMP	CODED
	JMP	CODEE
	JMP	CODEF
	
	SIMHALT				; Shouldn't run into this

* Code not implemented (not required)	
CODE0
CODEA
CODEB
CODEF
	BRA		PRINTUNKNOWN

PRINTCMD
	* Print via trap
	LEA		CMDTXT,A1
	MOVE.B	#14,D0
	TRAP	#15
	
	MOVEA.L	A2,A0	; The command is legal, step over data read
	RTS				; Goes to next command

PRINTUNKNOWN
	LEA		UNKNOWNMSGDATA,A6
	MOVEA.L	A0,A2
	ADDQ.L	#2,A0
	JSR		IMMED_WORD_TXT
	
	LEA		UNKNOWNMSG,A1
	MOVE.B	#14,D0
	TRAP	#15
	RTS				; Goes to next command

CLRCMDTXT
	LEA		CMDTXT,A6
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	CLR.L	(A6)+
	RTS

DATA_REG_TXT
	MOVE.B	#'D',(A6)+
	JSR		REG_NUM_TXT
	RTS

ADDR_REG_TXT
	MOVE.B	#'A',(A6)+
	JSR		REG_NUM_TXT
	RTS

ADDR_REG_IND_TXT
	MOVE.B	#'(',(A6)+
	JSR		ADDR_REG_TXT
	MOVE.B	#')',(A6)+
	RTS

ADDR_REG_INC_TXT
	JSR		ADDR_REG_IND_TXT
	MOVE.B	#'+',(A6)+
	RTS
	
ADDR_REG_DEC_TXT
	MOVE.B	#'-',(A6)+
	JSR		ADDR_REG_IND_TXT
	RTS

ABSWORD_TXT
	MOVE.B	#'$',(A6)+

	* Initialze for V2A loop
	CLR.L	D3
	MOVE.B	#2,D7
	MOVE.W	(A2)+,CNVTDATA
	JSR		V2A
	RTS
	
ABSLONG_TXT
	MOVE.B	#'$',(A6)+

	* Initialze for V2A loop
	CLR.L	D3
	MOVE.B	#4,D7
	MOVE.L	(A2)+,CNVTDATA
	JSR		V2A
	RTS

IMMED_WORD_TXT
	MOVE.B	#'#',(A6)+
	MOVE.B	#'$',(A6)+

	* Initialze for V2A loop
	CLR.L	D3
	MOVE.B	#2,D7
	MOVE.W	(A2)+,CNVTDATA
	JSR		V2A
	RTS
	
IMMED_LONG_TXT
	MOVE.B	#'#',(A6)+
	MOVE.B	#'$',(A6)+

	* Initialze for V2A loop
	CLR.L	D3
	MOVE.B	#4,D7
	MOVE.L	(A2)+,CNVTDATA
	JSR		V2A
	RTS

REG_NUM_TXT
	* Obtain register number via V2A Jumptable
	LEA		V2AJT,A3
	MULU.W	#6,D3
	JSR		(A3,D3)
	RTS

FIN_CMD
	MOVE.B	#LF,(A6)+
	MOVE.B	#CR,(A6)+
	BRA		PRINTCMD
	
IMMED_JT
	MOVE.B	#'8',(A6)+
	RTS
	MOVE.B	#'1',(A6)+
	RTS
	MOVE.B	#'2',(A6)+
	RTS
	MOVE.B	#'3',(A6)+
	RTS
	MOVE.B	#'4',(A6)+
	RTS
	MOVE.B	#'5',(A6)+
	RTS
	MOVE.B	#'6',(A6)+
	RTS
	MOVE.B	#'7',(A6)+
	RTS


UNKNOWNMSG
	DC.B	'Data '
UNKNOWNMSGDATA
	DS.B	6
	DC.B	LF,CR,0

	SIMHALT
	
	





































*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
