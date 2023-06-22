*-----------------------------------------------------------
* Title      :	Code E - AS,LS,RO
* Written by :	Bryan Lin
* Date       :	5/22
* Description:	Decode ASd, LSd, and ROd
*-----------------------------------------------------------

CODEE
	MOVE.W	(A2)+,D4	; Move instruction to inspect
	
	* Get bit 6-7 for type of syntax
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$C0,D5		; Mask out NOT size
	LSR.B	#6,D5		; Shift to LSB
	
	* Check if operand is EA
	CMPI.B	#%11,D5
	BEQ		CODEE_OPEA
	BRA		CODEE_OPREG

CODEE_OPEA
	* Get command
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$0600,D5
	ROL.W	#7,D5
	BRA		CODEE_CMD

CODEE_OPREG
	* Get command
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$18,D5
	LSR.B	#3,D5
	BRA		CODEE_CMD

CODEE_CMD
	* Branch to according command
	CMPI.B	#%00,D5
	BEQ		CMD_AS
	
	CMPI.B	#%01,D5
	BEQ		CMD_LS

	CMPI.B	#%11,D5
	BEQ		CMD_RO

	BRA		PRINTUNKNOWN
	
CMD_AS
	MOVE.W	#'AS',(A6)+
	BRA		CODEE_DIR	

CMD_LS
	MOVE.W	#'LS',(A6)+
	BRA		CODEE_DIR
	
CMD_RO
	MOVE.W	#'RO',(A6)+
	BRA		CODEE_DIR

CODEE_DIR
	* Get direction bit
	CLR.L	D5
	MOVE.W	D4,D5
	ANDI.W	#$0100,D5
	LSR.W	#8,D5
	
	CMPI.B	#0,D5
	BEQ		CODEE_R
	BRA		CODEE_L
	
CODEE_L
	MOVE.B	#'L',(A6)+
	BRA		CODEE_SIZE

CODEE_R
	MOVE.B	#'R',(A6)+
	BRA		CODEE_SIZE
	
CODEE_SIZE
	* Get bit 6-7 for size
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$C0,D5		; Mask out NOT size
	LSR.B	#6,D5		; Shift to LSB
	
	* Check size and if it is EA operand
	CMPI.B	#%00,D5
	BEQ		CODEE_SIZE_BYTE

	CMPI.B	#%01,D5
	BEQ		CODEE_SIZE_WORD

	CMPI.B	#%10,D5
	BEQ		CODEE_SIZE_LONG

	CMPI.B	#%11,D5
	BEQ		CODEE_EA	

CODEE_SIZE_BYTE
	MOVE.B	#'.',(A6)+
	MOVE.B	#'B',(A6)+
	BRA		CODEE_IR

CODEE_SIZE_WORD
	MOVE.B	#'.',(A6)+
	MOVE.B	#'W',(A6)+
	BRA		CODEE_IR

CODEE_SIZE_LONG
	MOVE.B	#'.',(A6)+
	MOVE.B	#'L',(A6)+
	BRA		CODEE_IR
	
CODEE_IR
	MOVE.B	#' ',(A6)+

	* Get I/R bit
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$20,D5
	LSR.B	#5,D5
	
	* Check if source is immed or register
	CMPI.B	#0,D5
	BEQ		CODEE_IMMED
	BRA		CODEE_REG

CODEE_IMMED
	MOVE.B	#'#',(A6)+
	
	* Setup immed value jumptable
	LEA		IMMED_JT,A3
	CLR.L	D3
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	MULU.W	#6,D3
	JSR		(A3,D3)
	BRA		CODEE_D_REG

CODEE_REG
	* Get Register number
	CLR.L	D3
	MOVE.W	D4,D3
	ANDI.W	#$0E00,D3
	ROL.W	#7,D3
	JSR		DATA_REG_TXT
	BRA		CODEE_D_REG
	
CODEE_D_REG
	MOVE.B	#',',(A6)+
	
	* Get Register number
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	JSR		DATA_REG_TXT
	
	BRA		FIN_CMD
	
CODEE_EA
	MOVE.B	#' ',(A6)+
	MOVE.B	#' ',(A6)+
	MOVE.B	#' ',(A6)+
	
	* Get EA mode
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#$38,D5
	LSR.B	#3,D5
	
	* Branch to corresponding mode
	CMPI.B	#%010,D5
	BEQ		CODEE_EA_ADDR_IND
	
	CMPI.B	#%011,D5
	BEQ		CODEE_EA_ADDR_INC
	
	CMPI.B	#%100,D5
	BEQ		CODEE_EA_ADDR_DEC
	
	CMPI.B	#%111,D5
	BEQ		CODEE_EA_ABS
	
	BRA		PRINTUNKNOWN
	
CODEE_EA_ADDR_IND
	* Get Register number
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	JSR		ADDR_REG_IND_TXT
	
	BRA		FIN_CMD

CODEE_EA_ADDR_INC
	* Get Register number
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	JSR		ADDR_REG_INC_TXT
	
	BRA		FIN_CMD

CODEE_EA_ADDR_DEC
	* Get Register number
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	JSR		ADDR_REG_DEC_TXT
	
	BRA		FIN_CMD

CODEE_EA_ABS
	* Get Register number
	CLR.L	D5
	MOVE.B	D4,D5
	ANDI.B	#%111,D5
	
	* Branch to corresponding ABS length
	CMPI.B	#%000,D5
	BEQ		CODEE_EA_ABSWORD

	CMPI.B	#%001,D5
	BEQ		CODEE_EA_ABSLONG
	
	BRA		PRINTUNKNOWN
	
CODEE_EA_ABSWORD
	JSR		ABSWORD_TXT
	BRA		FIN_CMD

CODEE_EA_ABSLONG
	JSR		ABSLONG_TXT
	BRA		FIN_CMD

	SIMHALT

*****



*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
