*-----------------------------------------------------------
* Title      : Code 5 - ADDQ
* Written by : Bryan Lin
* Date       : 5/22
* Description: Decode ADDQ
*-----------------------------------------------------------
    
CODE5
	MOVE.W	(A2)+,D4
	MOVE.L	#'ADDQ',(A6)+
	
	* Get operation size bit
	CLR.L	D5
	MOVE.B	D4,D5
	LSR.B	#6,D5
	ANDI.B	#%11,D5
	
	* Branch to according size
	CMPI.B	#%00,D5
	BEQ		CMD_ADDQ_BYTE

	CMPI.B	#%01,D5
	BEQ		CMD_ADDQ_WORD
	
	CMPI.B	#%10,D5
	BEQ		CMD_ADDQ_LONG
	
	BRA		PRINTUNKNOWN
	
CMD_ADDQ_BYTE
	MOVE.W	#'.B',(A6)+
	BRA		CMD_ADDQ_IMMED

CMD_ADDQ_WORD
	MOVE.W	#'.W',(A6)+
	BRA		CMD_ADDQ_IMMED
	
CMD_ADDQ_LONG
	MOVE.W	#'.L',(A6)+
	BRA		CMD_ADDQ_IMMED
	
CMD_ADDQ_IMMED
	MOVE.W	#' #',(A6)+
	
	* Get DAtA bit
	CLR.L	D3
	MOVE.W	D4,D3
	ROL.W	#7,D3
	ANDI.W	#%111,D3
	
	* Setup jumptable
	LEA		IMMED_JT,A3
	MULU.W	#6,D3
	JSR		(A3,D3)
	
	MOVE.B	#',',(A6)+
	BRA		CMD_ADDQ_EA

CMD_ADDQ_EA
	* Get EA mode
	CLR.L	D5
	MOVE.B	D4,D5
	LSR.B	#3,D5
	ANDI.B	#%111,D5
	
	* Branch to corresponding mode
	CMPI.B	#%000,D5
	BEQ		CMD_ADDQ_DATAREG
	
	CMPI.B	#%001,D5
	BEQ		CMD_ADDQ_ADDRREG
	
	CMPI.B	#%010,D5
	BEQ		CMD_ADDQ_ADDRREG_IND
	
	CMPI.B	#%011,D5
	BEQ		CMD_ADDQ_ADDRREG_INC
	
	CMPI.B	#%100,D5
	BEQ		CMD_ADDQ_ADDRREG_DEC
	
	CMPI.B	#%111,D5
	BEQ		CMD_ADDQ_M7
	
	BRA		PRINTUNKNOWN
	
CMD_ADDQ_DATAREG
	JSR		CMD_ADDQ_EA_REG
	JSR		DATA_REG_TXT
	BRA		FIN_CMD

CMD_ADDQ_ADDRREG
	* Check operation size
	CLR.L	D5
	MOVE.B	D4,D5
	LSR.B	#6,D5
	ANDI.B	#%11,D5
	
	CMPI.B	#%00,D5			; Byte operation is illegal
	BEQ		PRINTUNKNOWN

	JSR		CMD_ADDQ_EA_REG
	JSR		ADDR_REG_TXT
	BRA		FIN_CMD
	
CMD_ADDQ_ADDRREG_IND
	JSR		CMD_ADDQ_EA_REG
	JSR		ADDR_REG_IND_TXT
	BRA		FIN_CMD

CMD_ADDQ_ADDRREG_INC
	JSR		CMD_ADDQ_EA_REG
	JSR		ADDR_REG_INC_TXT
	BRA		FIN_CMD

CMD_ADDQ_ADDRREG_DEC
	JSR		CMD_ADDQ_EA_REG
	JSR		ADDR_REG_DEC_TXT
	BRA		FIN_CMD

CMD_ADDQ_M7
	JSR		CMD_ADDQ_EA_REG
	
	* Branch to corresponding abs addressing
	CMPI.B	#%000,D3
	BEQ		CMD_ADDQ_ABSWORD

	CMPI.B	#%001,D3
	BEQ		CMD_ADDQ_ABSLONG

	BRA		PRINTUNKNOWN
	
CMD_ADDQ_ABSWORD
	JSR		ABSWORD_TXT
	BRA		FIN_CMD

CMD_ADDQ_ABSLONG
	JSR		ABSLONG_TXT
	BRA		FIN_CMD

CMD_ADDQ_EA_REG
	* Get EA reg value
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	RTS



*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
