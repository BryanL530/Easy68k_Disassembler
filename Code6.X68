*-----------------------------------------------------------
* Title      : Code 6 - Branch
* Written by : Bryan Lin
* Date       : 5/24
* Description: Decode BRA, BGT, BLE, and BEQ
*-----------------------------------------------------------
CODE6
	MOVE.W	(A2)+,D4

	* Get Condition bits
	CLR.L	D5
	MOVE.W	D4,D5
	LSR.W	#8,D5
	ANDI.B	#$0F,D5

	CMPI.B	#%0000,D5	
	BEQ		CMD_BRA
	
	CMPI.B	#%1110,D5	
	BEQ		CMD_BGT
	
	CMPI.B	#%1111,D5	
	BEQ		CMD_BLE
	
	CMPI.B	#%0111,D5	
	BEQ		CMD_BEQ

	BRA		PRINTUNKNOWN

CMD_BRA
	MOVE.L	#'BRA ',(A6)+
	BRA		CMD_BRANCH_DISPLACEMENT

CMD_BGT
	MOVE.L	#'BGT.',(A6)+
	BRA		CMD_BRANCH_DISPLACEMENT

CMD_BLE
	MOVE.L	#'BLE.',(A6)+
	BRA		CMD_BRANCH_DISPLACEMENT

CMD_BEQ
	MOVE.L	#'BEQ.',(A6)+
	BRA		CMD_BRANCH_DISPLACEMENT

CMD_BRANCH_DISPLACEMENT
	* Get 8 bit displacement value
	CLR.L	D5
	MOVE.B	D4,D5
	
	* Branch based on displacement value
	CMPI.B	#$00,D5
	BEQ		CMD_BRANCH_WORD
	
	CMPI.B	#$FF,D5
	BEQ		CMD_BRANCH_LONG
	
	BRA		CMD_BRANCH_BYTE

CMD_BRANCH_BYTE
	MOVE.W	#'B ',(A6)+

	* Sign extend displacement value
	EXT.W	D5
	EXT.L	D5
	BRA		CMD_BRANCH_ADDR

CMD_BRANCH_WORD
	MOVE.W	#'W ',(A6)+

	* Get Word displacement value
	CLR.L	D5
	MOVE.W	(A2)+,D5
	EXT.L	D5			; Sign extend displacement
	BRA		CMD_BRANCH_ADDR
	
CMD_BRANCH_LONG
	MOVE.W	#'L ',(A6)+

	* Get Long displacement value
	CLR.L	D5
	MOVE.L	(A2)+,D5
	BRA		CMD_BRANCH_ADDR

CMD_BRANCH_ADDR
	* Get address branch to
	ADD.L	A0,D5
	ADDQ.L	#2,D5

	MOVE.B	#'$',(A6)+	
	
	* Initialize converter
	CLR.L	D3
	CLR.L	D7
	MOVE.B	#4,D7
	MOVE.L	D5,CNVTDATA
	JSR		V2A
	BRA		FIN_CMD

***

*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
