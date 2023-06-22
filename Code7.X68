*-----------------------------------------------------------
* Title      : Code 7 - MOVEQ
* Written by : Bryan Lin
* Date       : 5/23
* Description: Decode the MOVEQ
*-----------------------------------------------------------

CODE7
	MOVE.L	#'MOVE',(A6)+
	MOVE.L	#'Q #$',(A6)+
	MOVE.W	(A2)+,D4
	
	* Setup V2A for data
	MOVE.B	D4,CNVTDATA
	CLR.L	D7
	ADDQ.B	#1,D7
	JSR		V2A
	
	MOVE.B	#',',(A6)+
	
	* Get Register number
	CLR.L	D3
	MOVE.W	D4,D3
	ROL.W	#7,D3
	ANDI.W	#%111,D3
	JSR		DATA_REG_TXT

	BRA		FIN_CMD

*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
