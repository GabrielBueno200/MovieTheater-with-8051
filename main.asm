;==========================================================
;                      HEADER;
;==========================================================
; This program seeks to automate a 
; movie theater using the 8051 
; microcontroller in the EdSim51 
; simulator
;========================================================

;========================================================
;                 IMPORTS SECTION
;========================================================
org 01A0h

;====================================
;            LCD IMPORTS
;====================================
writeString:
		MOV R2, #0
rot:
		MOV A, R2
 		MOVC A,@A+DPTR 		;Reads the memory code table
 		ACALL sendCharacter	;Sends data in A to LCD module
		INC R2
		JNZ rot				; if A is 0, then end of data has been reached - jump out of loop
 		RET

; --- Hardware Mapping (8051) ---
    RS      equ     P1.3    ;Reg Select linked with P1.3
    EN      equ     P1.2    ;Enable linked with P1.2


; initialize the display
; see instruction set for details
lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
					; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN			; |
	CLR EN			; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN			; |
	CLR EN			; | negative edge on E
					; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN	     	; |
	CLR EN			; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		    ; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN				; |
	CLR EN				; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN				; |
	CLR EN				; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET

;Positions the cursor in the desired row and column.
;Writes in the ACC the line and column address.
;|--------------------------------------------------------------------------------------|
;| row1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;| row2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
positionCursor:
	CLR RS	
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN		     	; |
	CLR EN			    ; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN				; |
	CLR EN				; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET


;Returns the cursor to the fisrt position without clear display
returnCursor:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN	     	; |
	CLR EN		    ; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


;Clears display
clearDisplay:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		    ; |
	CLR EN			; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay		; wait for BF to clear
	CALL delay		; wait for BF to clear
	CALL delay

	RET


delay:
	MOV R3, #0ffH
	DJNZ R3, $
	RET


;################################################################################################################
;################################################################################################################
;################################################################################################################
;################################################################################################################


;========================================================
;                  MAIN SECTION
;========================================================

; Jumps for the main function
org 0000h
	LJMP Main


; Main function
org 0040h
Main:
	ACALL showMovies
	ACALL lcd_init
	ACAll askForTheMovie
	;SJMP $
	SJMP $


;=======================================================
;              SERIAL CHANNEL SECTION
;=======================================================

; INTERRUPTION FOR RECEPTIONS
org 0023H
	CALL delay
	CJNE R7, #1, back 
		JB isOptionValid, back        ; |
		MOV A, SBUF                   ; |  Reads the bytes received
		CJNE A, #0Dh, storeUserOption ; |  Stores the value if diffent from 0D
		CLR RI                        ; |  Resets RI to receive new bytes
		RETI
		storeUserOption:
			MOV userOption, A  	; |  Writes the value in the userOption var
			MOV R0, #75h 		; |  Initial array address
			MOV R1, #4 			; |  Array size
			ACALL checkOption   ; |  checks if the user's choice is valid
			CLR RI              ; |  Resets RI to receive new bytes
			RETI
	back:
		RETI



org 0060h
	posRead EQU 70h    			; |  Variable to store the string positions
	userOption EQU 71h 			; |     "      "   "    "  movie chosen by the user   
	isOptionValid EQU F0		; |     "      " check if the user choice is valid
	areMoviesPrinted EQU R7		; |     "      "   "    "  "  movies were printed   


; subroutine to reset variables
resetVariables:
	CLR A
	MOV posRead, #0h
	RET

; subroutine to initialize variables
showMovies:
	CALL resetVariables
	MOV SCON, #50h  ;  |  Enable Serial Mode 1 and the port receiver
	MOV PCON, #80h  ;  |  SMOD bit = 1
	MOV TMOD, #20h  ;  |  CT1 mode 2
	MOV TH1, #243   ;  |  Initial value for count
	MOV TL1, #243   ;  |  Recharge amount
	SETB TR1        ;  |  Turn on the timer
	MOV IE, #90h    ;  |  Sets the serial interruption
	
	; | Array of available options for movies (address: 75h - 78h)
	MOV 75h, #'A'
	MOV 76h, #'B'	
	MOV 77h, #'C'	
	MOV 78h, #'D'	

	CLR isOptionValid			;| initialize the user's movie option
	MOV areMoviesPrinted, #0	;| initialize the variable to check if the list of movies has been printed
	

;subroutine to print movies in the serial port
writeMovies:
	MOV DPTR, #moviesList ; |  Stores movies in the DPTR register
	MOV A, posRead        ; |  like the variable i in a For to print the whole string
	MOVC A, @A+DPTR       ; |  Reads the current string letter
	JZ break              ; |  Breaks if the movies are printed
	MOV SBUF, A           ; |  Transmits the content in A
	JNB TI, $             ; |  Waits the end of the transmission
	CLR TI                ; |  Cleans the end of transmission indicator
	INC posRead           ; |  Increments the string position
	SJMP writeMovies      ; |  Repeats to print next line

break:
	CLR A
	MOV areMoviesPrinted, #1    ;  |  When transmission ends, all the movies were printed
	RET 				        ;  |  Breaks the loop if all movies have been shown



	

checkOption:
	; |  Prevents a possible array overflow
	CJNE R1, #0, CONTINUE		; |  If equals 0, the subroutine has read the entire array, then breaks the loop
		CLR isOptionValid			; |  If the entire array was read by the subroutine, no values match with the user's option
		ACALL alertInvalidOption		
		RET		
	CONTINUE:		
		MOV A, @R0							; |  Gets the array current element by indirect addressing
		INC R0								; |  Increments the array position 
		DEC R1								; |  Checks the number of positions read (until equals zero)
		CJNE A, userOption, checkOption		; |  If the current element is equals the user's option, validate it
		SETB isOptionValid					; |  Sets isOptionValid var
		ACALL showSeatOptions				; |  Shows available seats
		RET

; movies list: names and start times
moviesList:
	db "A » Dune - Starts in 2m" 
	db '\n'
	db "B » 007-Again - Starts in 1m"
	db 0


;========================================================
;               LCD DISPLAY SECTION
;========================================================
ORG 0100h

; Asks for the movie in the lcd display
askForTheMovie:
	MOV A, #04h 			; |  Start position in the first column
	ACALL positionCursor
	MOV DPTR,#aftm1	        ; |  DPTR = begin of the phrase in the first column
	ACALL writeString
	MOV A, #45h				; |  Start position in the second column
	ACALL positionCursor
	MOV DPTR,#aftm2 	    ; |  DPTR = begin of the phrase in the second column
    ACALL writeString

	RET
	aftm1:
		db "Select a"
		db 0
	aftm2: 
		db "movie"
		db 0

; Asks for the seat in the lcd display
askForTheSeat:
	ACALL clearDisplay
	MOV A, #04h 			; |  Start position in the 5th column
	ACALL positionCursor
	MOV DPTR,#afts1	        ; |  DPTR = begin of the phrase in the 5th column
	ACALL writeString
	MOV A, #46h  			; |  Start position in the second column
	ACALL positionCursor
	MOV DPTR,#afts2 	    ; |  DPTR = begin of the phrase in the second column
    ACALL writeString
	
	SJMP $
	RET
	afts1:
		db "Select a"
		db 0
	afts2: 
		db "seat"
		db 0

; Alerts user if option isn't valid 
alertInvalidOption:
	ACALL clearDisplay
	MOV A, #03h										; |  Start position in the 3rd column at 1st row
	ACALL positionCursor
	MOV DPTR,#InvalidOptionMessage_ROW1				; |  DPTR = begin of the phrase in the 3rd column
	ACALL writeString

	MOV A, #40h											; |  Start position in the 1st column at 2nd row
	ACALL positionCursor
	MOV DPTR,#InvalidOptionMessage_ROW2    ; |  DPTR = begin of the phrase in the 1st column
    ACALL writeString
	


	RET
	InvalidOptionMessage_ROW1: db "Choose an"
							   db 0
	InvalidOptionMessage_ROW2: db "available option"
							   db 0

;=======================================================
;              SWITCH/LEDS SECTION
;=======================================================
org 029Ah
showSeatOptions:
	ACALL askForTheSeat
	SJMP $
