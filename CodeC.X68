*-----------------------------------------------------------
* Title      :	Code C - And
* Written by :	Bryan Lin
* Date       :	5/21
* Description:	Decode AND
*-----------------------------------------------------------   
CODEC
	MOVE.L	#'AND.',(A6)+
	MOVE.W	(A2)+,D4
	BRA		CMD_AND_SIZE

CMD_AND_SIZE
	* Determine size of the operation
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$00C0,D5
	LSR.W	#6,D5

	* Branching to corresponding size
	CMPI.B	#%00,D5
	BEQ		CMD_AND_SIZE_B
	
	CMPI.B	#%01,D5
	BEQ		CMD_AND_SIZE_W
	
	CMPI.B	#%10,D5
	BEQ		CMD_AND_SIZE_L
	
	BRA		PRINTUNKNOWN	; %11 is illegal size
	
CMD_AND_SIZE_B
	MOVE.W	#'B ',(A6)+
	BRA		CMD_AND_OPM

CMD_AND_SIZE_W
	MOVE.W	#'W ',(A6)+
	BRA		CMD_AND_OPM
CMD_AND_SIZE_L
	MOVE.W	#'L ',(A6)+
	BRA		CMD_AND_OPM

CMD_AND_OPM
	* Test bit to determine operation syntax
	MOVE.W	D4,D5
	ANDI.W	#$0100,D5
	LSR.W	#8,D5
	CMPI.B	#0,D5
	BEQ		CMD_AND_S_EA
	BRA		CMD_AND_D_EA

CMD_AND_S_EA
	* Setup jump for destination
	LEA		CMD_AND_S_EA_D,A4
	BRA		CMD_AND_EA

CMD_AND_S_EA_D
	MOVE.B	#',',(A6)+
	JSR		CMD_AND_DATAREG
	BRA		FIN_CMD

CMD_AND_D_EA
	JSR		CMD_AND_DATAREG
	MOVE.B	#',',(A6)+
	
	* Setup jump for finish command
	LEA		FIN_CMD,A4
	BRA		CMD_AND_EA

CMD_AND_EA
	* Mask NOT EA mode
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$38,D5
	LSR.B	#3,D5
	
	* Check for the addressing mode
	CMPI.B	#%000,D5
	BEQ		CMD_AND_EA_DATAREG

	CMPI.B	#%010,D5
	BEQ		CMD_AND_EA_ADDRREG_IND
	
	CMPI.B	#%011,D5
	BEQ		CMD_AND_EA_ADDRREG_INC
	
	CMPI.B	#%100,D5
	BEQ		CMD_AND_EA_ADDRREG_DEC
	
	CMPI.B	#%111,D5
	BEQ		CMD_AND_EA_M7
	
	BRA		PRINTUNKNOWN

CMD_AND_EA_DATAREG
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		DATA_REG_TXT
	JMP		(A4)

CMD_AND_EA_ADDRREG_IND
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_IND_TXT
	JMP		(A4)

CMD_AND_EA_ADDRREG_INC
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_INC_TXT
	JMP		(A4)

CMD_AND_EA_ADDRREG_DEC
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_DEC_TXT
	JMP		(A4)

CMD_AND_EA_M7
	* Mask out NOT EA register
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$07,D5
	
	* Check EA register for M7 addressing mode
	CMPI.B	#%000,D5
	BEQ		CMD_AND_EA_ABSWORD
	
	CMPI.B	#%001,D5
	BEQ		CMD_AND_EA_ABSLONG

	CMPI.B	#%100,D5
	BEQ		CMD_AND_EA_IMMED
	
	BRA		PRINTUNKNOWN

CMD_AND_EA_ABSWORD
	JSR		ABSWORD_TXT
	JMP		(A4)

CMD_AND_EA_ABSLONG
	JSR		ABSLONG_TXT
	JMP		(A4)

CMD_AND_EA_IMMED
	CMPA.L	#FIN_CMD,A4		; Check if this is source operand
	BEQ		PRINTUNKNOWN	; Branch to error on immed destination

	* Obtain size of operation
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$C0,D5
	LSR.B	#6,D5
	
	* Check size of operation for size of immed data
	CMPI.B	#%10,D5
	BEQ		CMD_AND_EA_IMMED_LONG
	BRA		CMD_AND_EA_IMMED_WORD
	
CMD_AND_EA_IMMED_WORD
	JSR		IMMED_WORD_TXT
	JMP		(A4)

CMD_AND_EA_IMMED_LONG
	JSR		IMMED_LONG_TXT
	JMP		(A4)

CMD_AND_DATAREG
	CLR.L	D3
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		DATA_REG_TXT
	RTS







*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
