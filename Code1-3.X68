*-----------------------------------------------------------
* Title      :	Code 1 ~ 3
* Written by :	Bryan Lin
* Date       :	5/20
* Description:	Decode MOVE and MOVEA
*-----------------------------------------------------------

CODE1
	* Code1 can only be MOVE.B if not illegal
	MOVE.L	#'MOVE',(A6)+
	MOVE.W	#'.B',(A6)+
	
	* Check if this is a MOVEA (Illegal in byte operation)
	MOVE.W	(A0),D5			; Move Opcode to D5
	ANDI.W	#$01C0,D5		; Mask out NOT destination mode
	CMPI.W	#$0040,D5		: Check if destination is An
	BEQ		PRINTUNKNOWN
	
	BRA		CMD_MOVE_S	

CODE2
	MOVE.L	#'MOVE',(A6)+
	JSR		ISMOVEA
	MOVE.B	#'.',(A6)+
	MOVE.B	#'L',(A6)+
	BRA		CMD_MOVE_S

CODE3
	MOVE.L	#'MOVE',(A6)+
	JSR		ISMOVEA
	MOVE.B	#'.',(A6)+
	MOVE.B	#'W',(A6)+
	BRA		CMD_MOVE_S

ISMOVEA
	MOVE.W	(A0),D5
	ANDI.W	#$01C0,D5		; Mask out NOT destination mode
	CMPI.W	#$0040,D5		: Check if destination is An
	BNE		RTN				; RTN is labeled RTS
	
	MOVE.B	#'A',(A6)+
	RTS
	
CMD_MOVE_S
	MOVE.W	(A2)+,D4
	MOVE.B	#' ',(A6)+
	
	* Inspect Source Mode
	CLR.L	D5
	MOVE.B	D4,D5			; Move Opcode to D5
	ANDI.W	#$0038,D5		; Mask out NOT source mode
	LSR.W	#3,D5			; Shift Soure mode to LSB
	
	* Branch to according source label
	CMPI.B	#%000,D5
	BEQ		CMD_MOVE_S_DATAREG

	CMPI.B	#%001,D5
	BEQ		CMD_MOVE_S_ADDRREG

	CMPI.B	#%010,D5
	BEQ		CMD_MOVE_S_ADDRREG_INDIRECT

	CMPI.B	#%011,D5
	BEQ		CMD_MOVE_S_ADDRREG_INCREMENT

	CMPI.B	#%100,D5
	BEQ		CMD_MOVE_S_ADDRREG_DECREMENT

	CMPI.B	#%111,D5
	BEQ		CMD_MOVE_S_M7
	
	BRA		PRINTUNKNOWN	; Branch to unknown for all invalid register

CMD_MOVE_S_DATAREG
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#%111,D3
	JSR		DATA_REG_TXT
	BRA		CMD_MOVE_DESTINATION
	
CMD_MOVE_S_ADDRREG
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#%111,D3
	JSR		ADDR_REG_IND_TXT
	BRA		CMD_MOVE_DESTINATION

CMD_MOVE_S_ADDRREG_INDIRECT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#%111,D3
	JSR		ADDR_REG_IND_TXT
	BRA		CMD_MOVE_DESTINATION


CMD_MOVE_S_ADDRREG_INCREMENT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#%111,D3
	JSR		ADDR_REG_INC_TXT
	BRA		CMD_MOVE_DESTINATION

CMD_MOVE_S_ADDRREG_DECREMENT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#%111,D3
	JSR		ADDR_REG_DEC_TXT
	BRA		CMD_MOVE_DESTINATION

CMD_MOVE_S_M7
	* Obtain register value
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#%111,D5
	
	* Find addressing mode based on register value
	CMPI.B	#%000,D5
	BEQ		CMD_MOVE_S_ABSWORD

	CMPI.B	#%001,D5
	BEQ		CMD_MOVE_S_ABSLONG
	
	CMPI.B	#%100,D5
	BEQ		CMD_MOVE_S_IMMEDIATE
	
	BRA		PRINTUNKNOWN

CMD_MOVE_S_ABSWORD
	JSR		ABSWORD_TXT
	BRA		CMD_MOVE_DESTINATION

CMD_MOVE_S_ABSLONG
	JSR		ABSLONG_TXT
	BRA		CMD_MOVE_DESTINATION
	
CMD_MOVE_S_IMMEDIATE
	* Check for operation size to determine immediate size
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$F000,D5
	ROL.W	#4,D5
	
	* Branch to long immediate if it is long operation
	CMPI.B	#%0010,D5
	BEQ		CMD_MOVE_S_IMMED_LONG
	BRA		CMD_MOVE_S_IMMED_WORD
	
CMD_MOVE_S_IMMED_WORD
	JSR		IMMED_WORD_TXT
	BRA		CMD_MOVE_DESTINATION
	
CMD_MOVE_S_IMMED_LONG
	JSR		IMMED_LONG_TXT
	BRA		CMD_MOVE_DESTINATION
	
CMD_MOVE_DESTINATION
	MOVE.B	#',',(A6)+
	
	* Inspect Source Mode
	CLR.L	D5
	MOVE.W	D4,D5			; Move Opcode to D5
	ANDI.W	#$01C0,D5		; Mask out NOT source mode
	LSR.W	#6,D5			; Shift Soure mode to LSB
	
	* Branch to according destination label
	CMPI.B	#%000,D5
	BEQ		CMD_MOVE_D_DATAREG

	CMPI.B	#%001,D5
	BEQ		CMD_MOVE_D_ADDRREG

	CMPI.B	#%010,D5
	BEQ		CMD_MOVE_D_ADDRREG_INDIRECT

	CMPI.B	#%011,D5
	BEQ		CMD_MOVE_D_ADDRREG_INCREMENT

	CMPI.B	#%100,D5
	BEQ		CMD_MOVE_D_ADDRREG_DECREMENT

	CMPI.B	#%111,D5
	BEQ		CMD_MOVE_D_M7
	
	BRA		PRINTUNKNOWN	; Branch to unknown for all invalid register
	
CMD_MOVE_D_DATAREG
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		DATA_REG_TXT
	BRA		FIN_CMD

CMD_MOVE_D_ADDRREG
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		ADDR_REG_TXT
	BRA		FIN_CMD

CMD_MOVE_D_ADDRREG_INDIRECT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		ADDR_REG_IND_TXT
	BRA		FIN_CMD

CMD_MOVE_D_ADDRREG_INCREMENT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		ADDR_REG_INC_TXT
	BRA		FIN_CMD

CMD_MOVE_D_ADDRREG_DECREMENT
	* Obtain register number
	CLR.L	D3			; Empty D3 before insert jump offset
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		ADDR_REG_DEC_TXT
	BRA		FIN_CMD

CMD_MOVE_D_M7
	* Obtain register value
	CLR.L	D5			; Empty D3 before insert jump offset
	MOVE.W	D4,D5
	ANDI.W	#$0E00,D5
	ROL.W	#7,D5

	* Find abs size based on register value
	CMPI.B	#%000,D5
	BEQ		CMD_MOVE_D_ABSWORD
	
	CMPI.B	#%001,D5
	BEQ		CMD_MOVE_D_ABSLONG
	BRA		PRINTUNKNOWN

CMD_MOVE_D_ABSWORD
	JSR		ABSWORD_TXT
	BRA		FIN_CMD
	
CMD_MOVE_D_ABSLONG
	JSR		ABSLONG_TXT
	BRA		FIN_CMD





*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
