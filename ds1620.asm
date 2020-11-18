;***************************************************************************
;Program DS1620.ASM
;
;Revision History
;09/28/94 (KLS)  Created
;***************************************************************************    
;This program interfaces a DS1620 to an 8051 code compatible processor.
;Data is transferred through the micro's serial port, using synchronous
;communication (mode 0).  The following connections are used by this program:
;
;Micro            DS1620
;P3.1  (TXD)	  Pin 2  (CLK/CONV*)
;P3.0  (RXD)	  Pin 1  (DQ)
;P1.0		  Pin 3  (RST*)
;
;Be sure to check the timing specifications for the processor in question and
;the DS1620 to determine the maximum processor speed permitted by the
;interface.  The maximum clock rate supported by the DS1620 is 4 MHz.
;***************************************************************************
;
	   P0	equ  80H
	   P1	equ  90H
	   P2	equ  0A0H
	   P3	equ  0B0H
	   TMOD equ  89H
	   TCON equ  88H
	   TH0	equ  8CH
	   TL0	equ  8AH
	   IE	equ  0A8H
	   SBUF equ  99h
	   REN	equ  9Ch
	   RI	equ  98h
	   TI	equ  99h

;Vector table
	   cseg at 0	       ;Reset vector.
	   ajmp START

	   cseg at 0Bh	       ;Timer 0 interrupt vector.
	   ajmp TMR0_INT

;Begin Code segment
	   cseg at 30

START:	   MOV	R0,#04H 	;Initialize the timer counter.
	   MOV	P1,#0h		;Clear P1.0 to reset DS1620
	   MOV	P3,#03h 	;Set P3.1 & P3.0 high to use serial port.
	   MOV	TMOD,#01
	   MOV	TH0,#0		;Clear timer 0.
	   MOV	TL0,#0
	   MOV	TCON,#00010000B ;Set timer 0 to mode 3
	   MOV	IE,#82H 	;Enable timer 0 interrupt.

;Now configure the DS1620
	   MOV	 A,#0CH 	;Address Configuration Byte
	   CALL  OUT_CMD

	   MOV	 A,#03H 	;Set Configuration byte = cpu & One Shot Mode
	   CALL  OUT_DATA

	   MOV	 A,#0EEH	;Initiate first temp conversion.
	   CALL  OUT_CMD

	   jmp	 $		;Loop here and wait for timer interrupts.

;************************************************************************
; TMR0_INT - This routine is called to give the 1 second delay needed to
;	     give the DS1620 time to complete the conversion.  It is called
;	     several times before reading the temp because the 16-bit counter
;	     cannot generate a 1 second delay.	For code simplicity, the
;	     delay generated is longer that 1 second, but this does not
;	     affect the DS1620, and the data is still valid.  To optimize this
;	     routine, calculate the desired number of loops based on the
;	     processor speed.
;
;	     When the count has finally expired, it will read two bytes
;	     from the DS1620 and store them in R1 and R2.
;************************************************************************
TMR0_INT:  DJNZ  R0,NOACTION	;Extra long timer to give >1s.
	   MOV	 R0, #04H	;Reset time loop.

	   MOV	 A,#0AAH	;Read temp command.
	   CALL  OUT_CMD

	   CALL  IN_DATA	;Get LSB of temp.
	   MOV	 R1,A		;Save LSB.

	   CALL  IN_DATA	;Get MSB/MSb of temp.
	   MOV	 R2,A		;Save MSB.

	   MOV	 A,#0EEH	;Start another temp conversion
	   CALL  OUT_CMD

NOACTION: RETI

;************************************************************************
; OUT_CMD - This routine sends data out to the DS1620.	The OUT_DATA
;	    routine is the same as OUT_DATA, except that it is
;	    only necessary to toggle the reset line before sending commands.
;************************************************************************
OUT_CMD:   ANL	 P1,#0FEH    ;Toggle DS1620 Reset
	   ORL	 P1,#01H
OUT_DATA:  MOV	 SBUF,A      ;Move out byte.
	   JNB	 TI,$	     ;Wait until data has been transmitted.
	   CLR	 TI	     ;Clear TI.
	   RET

;************************************************************************
; IN_DATA - This routine reads a data byte from the DS1620.
;************************************************************************
IN_DATA:   SETB  REN	     ;Enable receiver to clock in data
	   JNB	 RI,$	     ;Wait until data has been received
	   MOV	 A,SBUF      ;Save data byte.
	   CLR	 REN	     ;Disable receiver to prevent another reception.
	   CLR	 RI	     ;Clear RI.
	   RET

 END	  ;End of program
