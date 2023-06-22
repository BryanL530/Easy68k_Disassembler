*-----------------------------------------------------------
* Title      :	Code D - ADD
* Written by :	Bryan Lin
* Date       :	5/22
* Description:	Decode ADD (ADDA included)
*-----------------------------------------------------------
CODED
	MOVE.L	#'ADD.',(A6)+
	MOVE.W	(A2)+,D4
	BRA		CMD_ADD_SIZE

CMD_ADD_SIZE
	* Determine size of the operation
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$C0,D5
	LSR.B	#6,D5

	* Branching to corresponding size
	CMPI.B	#%00,D5
	BEQ		CMD_ADD_SIZE_B
	
	CMPI.B	#%01,D5
	BEQ		CMD_ADD_SIZE_W
	
	CMPI.B	#%10,D5
	BEQ		CMD_ADD_SIZE_L
	
	* Only #%11 left, which is a ADDA operation
	SUBQ.L	#1,A6		; Replace '.' with 'A'
	MOVE.B	#'A',(A6)+
	MOVE.B	#'.',(A6)+	; Add '.' after 'A'
	
	* Determine size of the operation (opcode: ADDA)
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$0100,D5
	LSR.W	#8,D5
	
	* Branch to corresponding size
	CMPI.B	#0,D5
	BEQ		CMD_ADD_SIZE_W
	BRA		CMD_ADD_SIZE_L
	
	
CMD_ADD_SIZE_B
	MOVE.B	#'B',(A6)+
	BRA		CMD_ADD_OPM

CMD_ADD_SIZE_W
	MOVE.B	#'W',(A6)+
	BRA		CMD_ADD_OPM
CMD_ADD_SIZE_L
	MOVE.B	#'L',(A6)+
	BRA		CMD_ADD_OPM

CMD_ADD_OPM
	MOVE.B	#' ',(A6)+

	* Test bit to determine operation syntax
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$01C0,D5
	LSR.W	#6,D5
	CMPI.B	#0,D5
	
	CMPI.B	#%111,D5
	BEQ		CMD_ADD_S_EA
	
	CMPI.B	#%011,D5
	BLE		CMD_ADD_S_EA
	BRA		CMD_ADD_D_EA

CMD_ADD_S_EA
	* Setup jump for destination
	LEA		CMD_ADD_S_EA_D,A4
	BRA		CMD_ADD_EA

CMD_ADD_S_EA_D
	MOVE.B	#',',(A6)+
	JSR		CMD_ADD_DATAREG
	BRA		FIN_CMD

CMD_ADD_D_EA
	JSR		CMD_ADD_DATAREG
	MOVE.B	#',',(A6)+
	
	* Setup jump for finish command
	LEA		FIN_CMD,A4
	BRA		CMD_ADD_EA

CMD_ADD_EA
	* Mask NOT EA mode
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$38,D5
	LSR.B	#3,D5
	
	* Check for the addressing mode
	CMPI.B	#%000,D5
	BEQ		CMD_ADD_EA_DATAREG
	
	CMPI.B	#%001,D5
	BEQ		CMD_ADD_EA_ADDRREG

	CMPI.B	#%010,D5
	BEQ		CMD_ADD_EA_ADDRREG_IND
	
	CMPI.B	#%011,D5
	BEQ		CMD_ADD_EA_ADDRREG_INC
	
	CMPI.B	#%100,D5
	BEQ		CMD_ADD_EA_ADDRREG_DEC
	
	CMPI.B	#%111,D5
	BEQ		CMD_ADD_EA_M7
	
	BRA		PRINTUNKNOWN

CMD_ADD_EA_DATAREG
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		DATA_REG_TXT
	JMP		(A4)

CMD_ADD_EA_ADDRREG
	CMPA.L	#FIN_CMD,A4		; Check if this is source operand
	BEQ		PRINTUNKNOWN	; Branch to error on immed destination

	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_TXT
	JMP		(A4)

CMD_ADD_EA_ADDRREG_IND
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_IND_TXT
	JMP		(A4)

CMD_ADD_EA_ADDRREG_INC
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_INC_TXT
	JMP		(A4)

CMD_ADD_EA_ADDRREG_DEC
	* Mask out NOT EA register
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#$07,D3
	JSR		ADDR_REG_DEC_TXT
	JMP		(A4)

CMD_ADD_EA_M7
	* Mask out NOT EA register
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$07,D5
	
	* Check EA register for M7 addressing mode
	CMPI.B	#%000,D5
	BEQ		CMD_ADD_EA_ABSWORD
	
	CMPI.B	#%001,D5
	BEQ		CMD_ADD_EA_ABSLONG

	CMPI.B	#%100,D5
	BEQ		CMD_ADD_EA_IMMED
	
	BRA		PRINTUNKNOWN

CMD_ADD_EA_ABSWORD
	JSR		ABSWORD_TXT
	JMP		(A4)

CMD_ADD_EA_ABSLONG
	JSR		ABSLONG_TXT
	JMP		(A4)

CMD_ADD_EA_IMMED
	CMPA.L	#FIN_CMD,A4		; Check if this is source operand
	BEQ		PRINTUNKNOWN	; Branch to error on immed destination

	* Obtain size of operation
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$01C0,D5
	LSR.W	#6,D5
	
	* Check size of operation for size of immed data
	CMPI.B	#%010,D5
	BEQ		CMD_ADD_EA_IMMED_LONG
	
	CMPI.B	#%111,D5
	BEQ		CMD_ADD_EA_IMMED_LONG

	BRA		CMD_ADD_EA_IMMED_WORD
	
CMD_ADD_EA_IMMED_WORD
	JSR		IMMED_WORD_TXT
	JMP		(A4)

CMD_ADD_EA_IMMED_LONG
	JSR		IMMED_LONG_TXT
	JMP		(A4)

CMD_ADD_DATAREG
	* Obtain data register number
	CLR.L	D3
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	
	* Check if this is an ADDA operation (An instad of Dn)
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$C0,D5
	LSR.B	#6,D5
	
	CMPI.B	#%11,D5
	BEQ		CMD_ADD_ADDRREG
	
	JSR		DATA_REG_TXT
	RTS
	
CMD_ADD_ADDRREG
	JSR		ADDR_REG_TXT
	RTS









*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
