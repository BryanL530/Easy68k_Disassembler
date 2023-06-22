*-----------------------------------------------------------
* Title      : Code 4 - Various commands
* Written by : Bryan Lin
* Date       : 5/24
* Description: Decode NOP, JSR, RTS, LEA, NOT, and MOVEM
*-----------------------------------------------------------
CODE4
	* Move Opcode to register to inspect
	MOVE.L	A0,A2
	MOVE.W	(A2)+,D4
	
	* Check if this is NOP
	CMPI.W	#$4E71,D4
	BEQ		CMD_NOP
	
	* Check if this is RTS
	CMPI.W	#$4E75,D4
	BEQ		CMD_RTS
	
	* Get bit 8
	CLR.L	D5
	MOVE.W	D4,D5
	LSR.W	#8,D5
	ANDI.W	#1,D5
	
	CMPI.B	#1,D5
	BEQ		CMD_LEA		; LEA bit 8 is 1
	
	* Get bit 9
	CLR.L	D5
	MOVE.W	D4,D5
	ROL.W	#7,D5
	ANDI.W	#1,D5
	
	CMPI.B	#1,D5
	BNE		CMD_MOVEM	; MOVEM bit 9 is 0
	
	* Get bit 10 & 11
	CLR.L	D5
	MOVE.W	D4,D5
	ROL.W	#6,D5
	ANDI.W	#%11,D5
	
	CMPI.B	#%01,D5
	BEQ		CMD_NOT		; NOT bit 10-11 is %01
	
	CMPI.B	#%11,D5
	BEQ		CMD_JSR		; JSR bit 10-11 is %01
	
	BRA		PRINTUNKNOWN

* =============================================================================
*	MOVEM
* =============================================================================
CMD_MOVEM
	MOVE.L	#'MOVE',(A6)+
	MOVE.W	#'M.',(A6)+
	
	JSR		CMD_MOVEM_NORMALIZEMASK
	LSL.L	#8,D6						; Logical shift by a word
	LSL.L	#8,D6
	MOVE.W	D4,D6						; Combine List and Opcode
	MOVE.L	D6,D4						; D4 is now List.W + Opcode.W
	BRA		CMD_MOVEM_SIZE

* -----------------------------------------------------------------------------
*	MOVEM - Mask Handling
* -----------------------------------------------------------------------------
CMD_MOVEM_NORMALIZEMASK
	* Saves register list mask on MSB of D4
	CLR.L	D6
	MOVE.W	(A2)+,D6

	* Check if EA mode is -(An) 
	JSR		CODE4_EA_MODE
	CMPI.B	#%100,D5
	BNE		RTN				; RTN is a label with only RTS
	
	* Initialize Registers for loop
	CLR.L	D5				; USe D5 to store flipped maske value
	CLR.L	D7				; Use D7 as loop register
	
CMD_MOVEM_MASK_LOOP
	* Run this for 16 times
	CMPI.B	#16,D7
	BGE		CMD_MOVEM_MASK_END
	
	LSL.W	#1,D5
	BTST	D7,D6				; Test for nth bit in nth iteration
	BEQ		CMD_MOVEM_MASK_NEXT
	
	ADDQ.W	#1,D5
	
CMD_MOVEM_MASK_NEXT
	ADDQ.B	#1,D7				; Increment loop counter by 1
	BRA		CMD_MOVEM_MASK_LOOP	; Goes to next iteration

CMD_MOVEM_MASK_END
	CLR.L	D6					; Update D6 to flipped mask value
	MOVE.W	D5,D6
	RTS
	
* -----------------------------------------------------------------------------
*	MOVEM - Size Handling
* -----------------------------------------------------------------------------
CMD_MOVEM_SIZE
	* Test size bit
	BTST	#6,D4
	BEQ		CMD_MOVEM_WORD
	BRA		CMD_MOVEM_LONG
	
CMD_MOVEM_WORD
	MOVE.W	#'W ',(A6)+
	BRA		CMD_MOVEM_DIR
	
CMD_MOVEM_LONG
	MOVE.W	#'L ',(A6)+
	BRA		CMD_MOVEM_DIR

* -----------------------------------------------------------------------------
*	MOVEM - Transfer direction
* -----------------------------------------------------------------------------
CMD_MOVEM_DIR
	* Test direction bit
	BTST	#10,D4
	BEQ		CMD_MOVEM_R2M_P1
	BRA		CMD_MOVEM_M2R_P1
	
CMD_MOVEM_R2M_P1
	LEA		CMD_MOVEM_R2M_P2,A4	; Jump to P2 after LIST branch
	BRA		CMD_MOVEM_LIST
	
CMD_MOVEM_R2M_P2
	MOVE.B	#',',(A6)+
	LEA		FIN_CMD,A4			; Jump to finish after EA branch
	BRA		CMD_MOVEM_EA

CMD_MOVEM_M2R_P1
	LEA		CMD_MOVEM_M2R_P2,A4	; Jump to P2 after EA branch
	BRA		CMD_MOVEM_EA
	
CMD_MOVEM_M2R_P2
	MOVE.B	#',',(A6)+
	LEA		FIN_CMD,A4			; Jump to finish after LIST branch
	BRA		CMD_MOVEM_LIST
* -----------------------------------------------------------------------------
*	MOVEM - REG LIST Handling
* -----------------------------------------------------------------------------
*	Variable:
*		D5 - Uses to save last txt out, where
*			* D5.B == #%00 is Nothing
*			* D5.B == #%01 is Register
*			* D5.B == #%10 is '/'
*			* D5.B == #%11 is '-'
* -----------------------------------------------------------------------------
CMD_MOVEM_LIST
	* Rotate data to be OPcode + Mask
	ROL.L	#8,D4
	ROL.L	#8,D4
		
	* Initialize registers
	LEA		MOVEM_JT,A3
	CLR.L	D5
	CLR.L	D7
	
CMD_MOVEM_LIST_LOOP
	CMPI.B	#16,D7
	BGE		CMD_MOVEM_LIST_FIN
	
	CMPI.B	#8,D7
	BEQ		CMD_MOVEM_LIST_REG_SPLIT

	* Check if register bit is set
	BTST	D7,D4
	BNE		CMD_MOVEM_LIST_BIT_SET
	BRA		CMD_MOVEM_LIST_BIT_CLR

CMD_MOVEM_LIST_REG_SPLIT
	* Check last txt out
	CMPI.B	#%00,D5		; Check if last out is Nothing
	BEQ		CMD_MOVEM_LIST_NEXT
	
	CMPI.B	#%10,D5		; Check if last out is '/'
	BEQ		CMD_MOVEM_LIST_NEXT
	
	* Edit loop count to split register list
	SUBQ.B	#1,D7		; Reduce count by 1
	
	CMPI.B	#%01,D5		; Check if last out is Register
	BEQ		CMD_MOVEM_LIST_TXT_SLASH

	CMPI.B	#%11,D5		; Check if last out is '-'
	BEQ		CMD_MOVEM_LIST_TXT_REG

	BRA		PRINTUNKNOWN

CMD_MOVEM_LIST_BIT_SET
	* Check last txt out
	CMPI.B	#%00,D5		; Check if last out is Nothing
	BEQ		CMD_MOVEM_LIST_TXT_REG
	
	CMPI.B	#%01,D5		; Check if last out is Register
	BEQ		CMD_MOVEM_LIST_TXT_DASH

	CMPI.B	#%10,D5		; Check if last out is '/'
	BEQ		CMD_MOVEM_LIST_TXT_REG

	CMPI.B	#%11,D5		; Check if last out is '-'
	BEQ		CMD_MOVEM_LIST_NEXT

	BRA		PRINTUNKNOWN	
		
CMD_MOVEM_LIST_BIT_CLR
	* Check last txt out
	CMPI.B	#%00,D5		; Check if last out is Nothing
	BEQ		CMD_MOVEM_LIST_NEXT
	
	CMPI.B	#%01,D5		; Check if last out is Register
	BEQ		CMD_MOVEM_LIST_TXT_SLASH

	CMPI.B	#%10,D5		; Check if last out is '/'
	BEQ		CMD_MOVEM_LIST_NEXT

	CMPI.B	#%11,D5		; Check if last out is '-'
	BEQ		CMD_MOVEM_LIST_PREV_REG

	BRA		PRINTUNKNOWN

CMD_MOVEM_LIST_PREV_REG
	SUBQ.B	#1,D7
	BRA		CMD_MOVEM_LIST_TXT_REG

CMD_MOVEM_LIST_TXT_REG
	* Output register
	CLR.L	D3
	MOVE.B	D7,D3
	MULU.W	#6,D3
	JSR		(A3,D3)
	
	* Update last out
	MOVE.B	#%01,D5
	BRA		CMD_MOVEM_LIST_NEXT
	
CMD_MOVEM_LIST_TXT_SLASH
	* Output '/' and update last out
	MOVE.B	#'/',(A6)+
	MOVE.B	#%10,D5
	BRA		CMD_MOVEM_LIST_NEXT
	
CMD_MOVEM_LIST_TXT_DASH
	* Output '-' and update last out
	MOVE.B	#'-',(A6)+
	MOVE.B	#%11,D5
	BRA		CMD_MOVEM_LIST_NEXT
	
CMD_MOVEM_LIST_NEXT
	ADDQ.B	#1,D7
	BRA		CMD_MOVEM_LIST_LOOP
	
CMD_MOVEM_LIST_FIN
	* Check last txt out
	CMPI.B	#%00,D5		; Check if last out is Nothing
	BEQ		PRINTUNKNOWN

	CMPI.B	#%10,D5		; Check if last out is '/'
	BEQ		CMD_MOVEM_LIST_LAST_SLASH

	CMPI.B	#%11,D5		; Check if last out is '-'
	BEQ		CMD_MOVEM_LIST_PREV_REG

	* Rotate data back to MASK + OPcode
	ROR.L	#8,D4
	ROR.L	#8,D4
	JMP		(A4)
	
CMD_MOVEM_LIST_LAST_SLASH
	SUBA.L	#1,A6		; Write over '/' with some other data
	
	* Rotate data back to MASK + OPcode
	ROR.L	#8,D4
	ROR.L	#8,D4
	JMP		(A4)
	
MOVEM_JT
	JMP		D_REG_0
	JMP		D_REG_1
	JMP		D_REG_2
	JMP		D_REG_3
	JMP		D_REG_4
	JMP		D_REG_5
	JMP		D_REG_6
	JMP		D_REG_7
	JMP		A_REG_0
	JMP		A_REG_1
	JMP		A_REG_2
	JMP		A_REG_3
	JMP		A_REG_4
	JMP		A_REG_5
	JMP		A_REG_6
	JMP		A_REG_7

D_REG_0
	MOVE.B	#'D',(A6)+
	MOVE.B	#'0',(A6)+
	RTS
D_REG_1
	MOVE.B	#'D',(A6)+
	MOVE.B	#'1',(A6)+
	RTS
D_REG_2
	MOVE.B	#'D',(A6)+
	MOVE.B	#'2',(A6)+
	RTS
D_REG_3
	MOVE.B	#'D',(A6)+
	MOVE.B	#'3',(A6)+
	RTS
D_REG_4
	MOVE.B	#'D',(A6)+
	MOVE.B	#'4',(A6)+
	RTS
D_REG_5
	MOVE.B	#'D',(A6)+
	MOVE.B	#'5',(A6)+
	RTS
D_REG_6
	MOVE.B	#'D',(A6)+
	MOVE.B	#'6',(A6)+
	RTS
D_REG_7
	MOVE.B	#'D',(A6)+
	MOVE.B	#'7',(A6)+
	RTS
	
A_REG_0
	MOVE.B	#'A',(A6)+
	MOVE.B	#'0',(A6)+
	RTS
A_REG_1
	MOVE.B	#'A',(A6)+
	MOVE.B	#'1',(A6)+
	RTS
A_REG_2
	MOVE.B	#'A',(A6)+
	MOVE.B	#'2',(A6)+
	RTS
A_REG_3
	MOVE.B	#'A',(A6)+
	MOVE.B	#'3',(A6)+
	RTS
A_REG_4
	MOVE.B	#'A',(A6)+
	MOVE.B	#'4',(A6)+
	RTS
A_REG_5
	MOVE.B	#'A',(A6)+
	MOVE.B	#'5',(A6)+
	RTS
A_REG_6
	MOVE.B	#'A',(A6)+
	MOVE.B	#'6',(A6)+
	RTS
A_REG_7
	MOVE.B	#'A',(A6)+
	MOVE.B	#'7',(A6)+
	RTS
* -----------------------------------------------------------------------------
*	MOVEM - EA
* -----------------------------------------------------------------------------
CMD_MOVEM_EA
	JSR		CODE4_EA_MODE		; Get EA mode
	
	* Branch based on addressing mode
	CMPI.B	#%010,D5
	BEQ		CMD_MOVEM_EA_ADDRREG_IND

	CMPI.B	#%011,D5
	BEQ		CMD_MOVEM_EA_ADDRREG_INC

	CMPI.B	#%100,D5
	BEQ		CMD_MOVEM_EA_ADDRREG_DEC
	
	CMPI.B	#%111,D5
	BEQ		CMD_MOVEM_EA_M7
	
	BRA		PRINTUNKNOWN

CMD_MOVEM_EA_ADDRREG_IND
	JSR		CODE4_EA_REG
	JSR		ADDR_REG_IND_TXT
	JMP		(A4)

CMD_MOVEM_EA_ADDRREG_INC
	* Check if this is a M2R transfer
	BTST	#10,D4
	BEQ		PRINTUNKNOWN

	JSR		CODE4_EA_REG
	JSR		ADDR_REG_INC_TXT
	JMP		(A4)

CMD_MOVEM_EA_ADDRREG_DEC
	* Check if this is a R2M transfer
	BTST	#10,D4
	BNE		PRINTUNKNOWN

	JSR		CODE4_EA_REG
	JSR		ADDR_REG_DEC_TXT
	JMP		(A4)

CMD_MOVEM_EA_M7
	JSR		CODE4_EA_REG
	
	* Branch based on EA register value
	CMPI.B	#%000,D3
	BEQ		CMD_MOVEM_EA_ABSWORD
	
	CMPI.B	#%001,D3
	BEQ		CMD_MOVEM_EA_ABSLONG
	
	BRA		PRINTUNKNOWN
	
CMD_MOVEM_EA_ABSWORD
	JSR		ABSWORD_TXT
	JMP		(A4)
	
CMD_MOVEM_EA_ABSLONG
	JSR		ABSLONG_TXT
	JMP		(A4)
	

* =============================================================================
*	NOT
* =============================================================================
CMD_NOT
	MOVE.L	#'NOT.',(A6)+
	
	* Get size bits
	CLR.L	D5
	MOVE.B	D4,D5
	LSR.B	#6,D5
	ANDI.B	#%11,D5
	
	* Branch to corresponding size
	CMPI.B	#%00,D5
	BEQ		CMD_NOT_BYTE
	
	CMPI.B	#%01,D5
	BEQ		CMD_NOT_WORD
	
	CMPI.B	#%10,D5
	BEQ		CMD_NOT_LONG
	
	BRA		PRINTUNKNOWN
	
CMD_NOT_BYTE
	MOVE.W	#'B ',(A6)+
	BRA		CMD_NOT_EA
	
CMD_NOT_WORD
	MOVE.W	#'W ',(A6)+
	BRA		CMD_NOT_EA

CMD_NOT_LONG
	MOVE.W	#'L ',(A6)+
	BRA		CMD_NOT_EA

CMD_NOT_EA
	JSR		CODE4_EA_MODE	; Get EA mode
	
	* Branch to corresponding mode
	CMPI.B	#%000,D5
	BEQ		CMD_NOT_EA_DATAREG

	CMPI.B	#%010,D5
	BEQ		CMD_NOT_EA_ADDRREG_IND

	CMPI.B	#%011,D5
	BEQ		CMD_NOT_EA_ADDRREG_INC

	CMPI.B	#%100,D5
	BEQ		CMD_NOT_EA_ADDRREG_DEC

	CMPI.B	#%111,D5
	BEQ		CMD_NOT_EA_M7
	
	BRA		PRINTUNKNOWN
	
CMD_NOT_EA_DATAREG
	JSR		CODE4_EA_REG		; Get EA reg value
	JSR		DATA_REG_TXT		; Output text
	BRA		FIN_CMD
	
CMD_NOT_EA_ADDRREG_IND
	JSR		CODE4_EA_REG		; Get EA reg value
	JSR		ADDR_REG_IND_TXT	; Output text
	BRA		FIN_CMD
	
CMD_NOT_EA_ADDRREG_INC
	JSR		CODE4_EA_REG		; Get EA reg value
	JSR		ADDR_REG_INC_TXT	; Output text
	BRA		FIN_CMD
	
CMD_NOT_EA_ADDRREG_DEC
	JSR		CODE4_EA_REG		; Get EA reg value
	JSR		ADDR_REG_DEC_TXT	; Output text
	BRA		FIN_CMD
	
CMD_NOT_EA_M7
	JSR		CODE4_EA_REG		; Get EA reg value
	
	* Branch to corresponding addressing mode
	CMPI.B	#%000,D3
	BEQ		CMD_NOT_EA_ABSWORD
	
	CMPI.B	#%001,D3
	BEQ		CMD_NOT_EA_ABSLONG

	BRA		PRINTUNKNOWN
	
CMD_NOT_EA_ABSWORD
	JSR		ABSWORD_TXT
	BRA		FIN_CMD

CMD_NOT_EA_ABSLONG
	JSR		ABSLONG_TXT
	BRA		FIN_CMD

* =============================================================================
*	LEA
* =============================================================================
CMD_LEA
	MOVE.L	#'LEA ',(A6)+
	
	JSR		CODE4_EA_MODE
	
	* Branch to corresponding mode
	CMPI.B	#%010,D5
	BEQ		CMD_LEA_EA_ADDRREG_IND
	
	CMPI.B	#%111,D5
	BEQ		CMD_LEA_EA_M7
	
	BRA		PRINTUNKNOWN

CMD_LEA_EA_ADDRREG_IND
	JSR		CODE4_EA_REG
	JSR		ADDR_REG_IND_TXT
	BRA		CMD_LEA_ADDRREG

CMD_LEA_EA_M7
	JSR		CODE4_EA_REG
	
	* Branch to corresponding abs addressing mode
	CMPI.B	#%000,D3
	BEQ		CMD_LEA_EA_ABSWORD
	
	CMPI.B	#%001,D3
	BEQ		CMD_LEA_EA_ABSLONG
	
	BRA		PRINTUNKNOWN

CMD_LEA_EA_ABSWORD
	JSR		ABSWORD_TXT
	BRA		CMD_LEA_ADDRREG

CMD_LEA_EA_ABSLONG
	JSR		ABSLONG_TXT
	BRA		CMD_LEA_ADDRREG

CMD_LEA_ADDRREG
	MOVE.B	#',',(A6)+

	* Get LEA register number
	CLR.L	D3
	MOVE.W	D4,D3
	ROL.W	#7,D3
	ANDI.W	#%111,D3
	
	JSR		ADDR_REG_TXT
	BRA		FIN_CMD
	
* =============================================================================
*	JSR
* =============================================================================
CMD_JSR
	MOVE.L	#'JSR ',(A6)+
	JSR		CODE4_EA_MODE
	
	* Branch to corresponding mode
	CMPI.B	#%010,D5
	BEQ		CMD_JSR_EA_ADDRREG_IND
	
	CMPI.B	#%111,D5
	BEQ		CMD_JSR_EA_M7
	
	BRA		PRINTUNKNOWN

CMD_JSR_EA_ADDRREG_IND
	JSR		CODE4_EA_REG		; Get register value
	JSR		ADDR_REG_IND_TXT	; Convert to text
	BRA		FIN_CMD

CMD_JSR_EA_M7
	JSR		CODE4_EA_REG		; Get register value
	
	* Branch to corresponding abs addressing mode
	CMPI.B	#%000,D3
	BEQ		CMD_JSR_EA_ABSWORD
	
	CMPI.B	#%001,D3
	BEQ		CMD_JSR_EA_ABSLONG
	
	BRA		PRINTUNKNOWN

CMD_JSR_EA_ABSWORD
	JSR		ABSWORD_TXT
	BRA		FIN_CMD

CMD_JSR_EA_ABSLONG
	JSR		ABSLONG_TXT
	BRA		FIN_CMD
	
* =============================================================================
*	NOP, RTS
* =============================================================================
CMD_NOP
	MOVE.L	#'NOP ',(A6)+
	BRA		FIN_CMD
	
CMD_RTS
	MOVE.L	#'RTS ',(A6)+
	BRA		FIN_CMD

* =============================================================================
*	Util functions
* =============================================================================
CODE4_EA_MODE
	* Get EA mode
	CLR.L	D5
	MOVE.B	D4,D5
	LSR.B	#3,D5
	ANDI.B	#%111,D5
	
	RTS
	
CODE4_EA_REG
	* Get EA REG
	CLR.L	D3
	MOVE.B	D4,D3
	ANDI.B	#%111,D3
	
	RTS












*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
