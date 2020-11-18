	ORG	00H
	MOV	P1, #11111111B
	MOV	P0, #00000000B
	MOV	P3, #00000000B
	MOV	DPTR, #LABEL
MAIN:	CLR	P3.7
	SETB	P3.6
	CLR	P3.5
	SETB	P3.5
WAIT:	JB	P3.4, WAIT
	CLR	P3.7
	CLR	P3.6
	MOV	A, P1
	MOV	B, #10D
	DIV	AB
	MOV	B, #2D
	MUL	AB
	MOV	B, #10D
	DIV	AB
	SETB	P3.2
	ACALL	DISPLAY
	MOV	P0, A
	ACALL	DELAY
	MOV	P0, #10000000B
	ACALL	DELAY
	MOV	A, B
	CLR	P3.2
	SETB	P3.1
	ACALL	DISPLAY
	MOV	P0, A
	ACALL	DELAY
	CLR	P3.1
	SJMP	MAIN
DELAY:	MOV	R3, #02H
DEL1:	MOV	R2, #0FAH
DEL2:	DJNZ	R2, DEL1
	DJNZ	R3, DEL2
	RET
DISPLAY:	MOVC	A, @A+DPTR
	RET
LABEL:	DB	3FH
	DB	06H
	DB	5BH
	DB	4FH
	DB	66H
	DB	6DH
	DB	7DH
	DB	07H
	DB	7FH
	DB	6FH
	END

	ORG 20H
MOV P1,#11111111B ; initiates P1 as the input port
MAIN: CLR P3.7 ; makes CS=0
      SETB P3.6 ; makes RD high
      CLR P3.5 ; makes WR low
      SETB P3.5 ; low to high pulse to WR for starting conversion
WAIT: JB P3.4,WAIT ; polls until INTR=0
      CLR P3.7 ; ensures CS=0
      CLR P3.6 ; high to low pulse to RD for reading the data from ADC
      MOV A,P1 ; moves the digital data to accumulator
      CPL A ; complements the digital data (*see the notes)
      MOV P0,A ; outputs the data to P0 for the LEDs
      SJMP MAIN ; jumps back to the MAIN program
      END

      ORG 40H ; initial starting address
MOV P1,#00000000B ; clears port 1
MOV R6,#1H ; stores "1"
MOV R7,#6H ; stores "6"
MOV P3,#00000000B ; clears port 3
MOV DPTR,#LABEL1 ; loads the adress of line 29 to DPTR
MAIN: MOV A,R6 ; "1" is moved to accumulator
SETB P3.0 ; activates 1st display
ACALL DISPLAY ; calls the display sub routine for getting the pattern for "1"
MOV P1,A ; moves the pattern for "1" into port 1
ACALL DELAY ; calls the 1ms delay
CLR P3.0 ; deactivates the 1st display
MOV A,R7 ; "2" is moved to accumulator
SETB P3.1 ; activates 2nd display
ACALL DISPLAY ; calls the display sub routine for getting the pattern for "2"
MOV P1,A ; moves the pattern for "2" into port 1
ACALL DELAY ; calls the 1ms delay
CLR P3.1 ; deactivates the 2nd display
SJMP MAIN ; jumps back to main and cycle is repeated
DELAY: MOV R3,#02H
DEL1: MOV R2,#0FAH
DEL2: DJNZ R2,DEL2
DJNZ R3,DEL1
RET
DISPLAY: MOVC A,@A+DPTR ; adds the byte in A to the address in DPTR and loads A with data present in the resultant address
RET
LABEL1:DB 3FH
DB 06H
DB 5BH
DB 4FH
DB 66H
DB 6DH
DB 7DH
DB 07H
DB 7FH
DB 6FH

END