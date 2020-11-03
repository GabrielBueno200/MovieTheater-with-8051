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
org 02A0h

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


;====================================
;            KEYPAD IMPORTS
;====================================

readKeypad:
	MOV R0, #0			; clear R0 - the first key is key0

	; scan row0
	MOV P0, #0FFh	
	CLR P0.0			; clear row0
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row1
	SETB P0.0			; set row0
	CLR P0.1			; clear row1
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row2
	SETB P0.1			; set row1
	CLR P0.2			; clear row2
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
	; scan row3
	SETB P0.2			; set row2
	CLR P0.3			; clear row3
	CALL colScan		; call column-scan subroutine
	JB F0, finish		; | if F0 is set, jump to end of program 
						; | (because the pressed key was found and its number is in  R0)
finish:
	RET

; column-scan subroutine
colScan:
	JNB P0.4, gotKey	; if col0 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.5, gotKey	; if col1 is cleared - key found
	INC R0				; otherwise move to next key
	JNB P0.6, gotKey	; if col2 is cleared - key found
	INC R0				; otherwise move to next key
	RET					; return from subroutine - key not found
gotKey:
	SETB F0				; key found - set F0
	RET					; and return from subroutine


;################################################################################################################
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
			ACALL checkMovieOption   ; |  checks if the user's choice is valid
			CLR RI              ; |  Resets RI to receive new bytes
			RETI
	back:
		RETI



org 0060h
	posRead EQU 70h    			; |  Variable to store the string positions
	userOption EQU 71h 			; |  Variable to store the  movie chosen by the user   
	keyAscii EQU 72h            ; |  Variable to make userOption-keyAscii and return a index in the aray that represents the movie selected
	isOptionValid EQU F0		; |  Variable to check if the user choice is valid
	areMoviesPrinted EQU R7		; |  Variable to check if the  movies were printed 
	firstTimeChoosingSeat EQU R5; |	 Variable to check if the user is choosing the seat for the first time (to display LCD alerts correctly)
	choseAvailableSeat EQU B.0  ; |  Variable to check if the user selected an available seat
	


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

	; | Array of available keypad buttons (address: 44h - 4Bh)
	MOV 44H, #'7'
	MOV 45H, #'6'
	MOV 46H, #'5'
	MOV 47H, #'4'
	MOV 48H, #'3'
	MOV 49H, #'2'
	MOV 4AH, #'1'
	MOV 4BH, #'0'		

	; | Array of available seat options (address: 30h - 37h)
	MOV 30h, #'0'
	MOV 31h, #'1'	
	MOV 32h, #'2'
	MOV 33h, #'3'
	MOV 34h, #'4'
	MOV 35h, #'5'
	MOV 36h, #'6'
	MOV 37h, #'7'
				
	
	MOV firstTimeChoosingSeat, #0	;| initializes the variable responsible for
 									;| checking if the user is choosing a movie for the first time

	CLR isOptionValid				;| initializes the user's movie option
	MOV areMoviesPrinted, #0		;| initializes the variable to check if the list of movies has been printed
	

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



;=======================================================
;                    ARRAYS SECTION
;=======================================================	

checkMovieOption: 
	CJNE R1, #0, CONTINUE			; |  Prevents a possible array overflow: If equals 0, the subroutine 
									;    has read the entire array, then breaks the loop
		CLR isOptionValid			; |  If the entire array was read by the subroutine, 
									;    no values match with the user's option
		CLR RI
		ACALL alertInvalidOption		
		RET		
	CONTINUE:		
		MOV A, @R0																		; |  Gets the array current element by indirect addressing
		INC R0																			; |  Increments the array position 
		DEC R1																			; |  Checks the number of positions read (until equals zero)
		CJNE A, userOption, checkMovieOption						; |  If the current element is equals the user's option, validate it
			SETB isOptionValid																; |  Sets isOptionValid var
			ACALL showSeatOptions															; |  Shows available seats
			RET

checkSeatOption:
	CJNE R2, #0, CONT				; |  Prevents a possible array overflow: If equals 0, the subroutine 
									;    has read the entire array, then breaks the loop
		CJNE firstTimeChoosingSeat, #1, leave ; |  If the user isn't choosing the seat for the first time ;
																				;    and has selected an unavailable option, alerts
		INC firstTimeChoosingSeat												; |  else if user has selected an unavailable for the first time, increments  
		RET		
	CONT:		
		MOV A, @R1						; |  Gets the array current element by indirect addressing
		INC R1							; |  Increments the array position 
		DEC R2							; |  Checks the number of positions read (until equals zero)
		CJNE A, 38h, checkSeatOption	; |  If the current element is equals the user's seat option, validate it
			DEC R1						; | 
			MOV @R1, #'-'				; | Put the character '-' in array to inform that the seat was selected 
			MOV R1, #30H				; | 30h = available seats array initial address
			ACALL turnOnLeds			; | turn on the leds linked with the user's seat option
			SETB choseAvailableSeat

		RET
	leave:
		ACALL alertInvalidOption
		MOV R1, #30h
		ACALL turnOnLeds
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
ORG 0150h

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
	
	INC firstTimeChoosingSeat
	MOV P2, #255
	
	waitUserChoice:
		CLR choseAvailableSeat
		MOV R1, #30h
		ACALL turnOnLeds
		ACALL readKeypad			; | reads the user's input
		JNB F0, waitUserChoice		; | if F0 is clear (invalid seat option), jump to waitUserChoice
		MOV A, #40h					; | if not, reads the value of the option
		ADD A, R0
		MOV R0, A
		MOV A, @R0
		MOV 38h, A					; | stores user option at address 38h
		MOV R1, #30H				; | initial address of available seats array
		MOV R2, #8H					; | array length
		ACALL checkSeatOption		; | checks if it's a valid seat option
		JB choseAvailableSeat, chronometer ; | if so, set the valid option variable
		CLR F0
		JMP waitUserChoice
			

	SJMP $
	
	RET
	afts1:
		db "Select a"
		db 0
	afts2: 
		db "seat"
		db 0

movieStarted:
	ACALL clearDisplay
	MOV A, #03h							; |  Start position in the 3rd column at 1st row
	ACALL positionCursor
	MOV DPTR,#MovieStarted_ROW1			; |  DPTR = begin of the phrase in the 3rd column
	ACALL writeString

	MOV A, #44h							; |  Start position in the 1st column at 2nd row
	ACALL positionCursor
	MOV DPTR,#MovieStarted_ROW2			; |  DPTR = begin of the phrase in the 1st column
    ACALL writeString
	
	RET
	MovieStarted_ROW1: db "The movie"
							   db 0
	MovieStarted_ROW2: db "started"
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

chronometer:
	ACALL clearDisplay
	MOV A, #03h					; |  Start position in the 3rd column at 1st row
	ACALL positionCursor
	MOV DPTR,#countTime_ROW1	; |  DPTR = begin of the phrase in the 3rd column
	ACALL writeString
	
	MOV A, userOption			; | Move to A the selected movie
	MOV keyAscii, #40h			; | Default value to make the default operation
	SUBB A, keyAscii			; | Put in A the index(+1) of the selected movie
 	DEC A
	MOV DPTR, #moviesTime
	MOVC A, @A+DPTR

	MOV keyAscii, A
	
	COUNT:
		MOV A, #46h				; |  Start position in the 1st column at 2nd row
		ACALL positionCursor
		MOV A, keyAscii
		ADD A, #30h
    	ACALL sendCharacter

		ACALL waitCount

	DJNZ keyAscii, COUNT
		MOV A, #46h				; |  Start position in the 1st column at 2nd row
		ACALL positionCursor
		MOV A, keyAscii
		ADD A, #30h
    	ACALL sendCharacter

		ACALL waitCount
	RET
	waitCount:
		MOV R4, #10h
		repeat:
			MOV R3, #0FFh
			DJNZ R3, $
		DJNZ R4, repeat
		RET
	moviesTime: 				; |  Time until the movies starts
		db 8h, 9h, 5h, 7h
	countTime_ROW1: 
		db "Starts in"
		db 0


;=======================================================
;              SWITCH/LEDS SECTION
;=======================================================
org 041Ah
showSeatOptions:
	ACALL askForTheSeat
	ACALL movieStarted
	LJMP showMovie
	SJMP $

; Reads the entire seats array and turn on the LEDs if the user option is valid
turnOnLeds:
	led0: 
		CJNE @R1, #'0', valid0
			SETB P2.0
			INC R1
	led1: 
		CJNE @R1, #'1', valid1
			SETB P2.1
			INC R1
	led2: 
		CJNE @R1, #'2', valid2
			SETB P2.2
			INC R1
	led3: 
		CJNE @R1, #'3', valid3
			SETB P2.3
			INC R1
	led4: 
		CJNE @R1, #'4', valid4
			SETB P2.4
			INC R1
	led5: 
		CJNE @R1, #'5', valid5
			SETB P2.5
			INC R1
	led6: 
		CJNE @R1, #'6', valid6
			SETB P2.6
			INC R1
	led7: 
		CJNE @R1, #'7', valid7
			SETB P2.7
			RET

	validateLed:
		valid0: 
			CLR P2.0 
			INC R1
			AJMP led1
		valid1:
			CLR P2.1
			INC R1 
			AJMP led2
		valid2:
			CLR P2.2 
			INC R1 
			AJMP led3
		valid3:
			CLR P2.3
			INC R1
			AJMP led4
		valid4: 
			CLR P2.4 
			INC R1 
			AJMP led5
		valid5: 
			CLR P2.5 
			INC R1 
			AJMP led6
		valid6: 
			CLR P2.6 
			INC R1
			AJMP led7
		valid7: 
			CLR P2.7 
			RET

org 049Ah
showMovie:
	CLR P0.7	; enables the DAC WR line
loop: 
	MOV P1, A	; moves data in the accumulator to the ADC inputs (on P1)
	ADD A, #8	; increases accumulator by 8
	JMP loop	; jumps back to loop