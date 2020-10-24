;==========================================================================================================
;                      HEADER;
;==========================================================================================================
; This program seeks to automate a 
; movie theater using the 8051 
; microcontroller in the EdSim51 
; simulator
;==========================================================================================================


;==========================================================================================================
;                  MAIN SECTION
;==========================================================================================================

; Jumps for the main function
org 0000h
	LJMP Main


; Main function
org 0080h
Main:
	ACALL showMovies
	ACALL lcd_init
	ACALL askForTheMovie
	SJMP $

;==========================================================================================================
;              SERIAL CHANNEL SECTION
;==========================================================================================================

; INTERRUPTION FOR RECEPTIONS
org 0023H
	CJNE R7, #1, back 
		MOV A, SBUF                   ; |  Reads the bytes received
		CJNE A, #0Dh, storeUserOption ; | Stores the value if diffent from 0D
		CLR RI                        ; |  Resets RI to receive new bytes
		RETI
		storeUserOption:
			MOV userOption, A  			; |  Writes the value in the userOption var
			MOV R0, #75h 				; |  Initial array address
			MOV R2, #4 					; |  Array size
			ACALL checkOption
			;CJNE R6, #1, alertInvalidOption
			CLR RI             			; |  Resets RI to receive new bytes
			RETI
	back:
		RETI



org 00A0h
	posRead EQU 70h    ; |  Variable to store the string positions
	userOption EQU 71h ; |     "      "   "    "  movie chosen by the user   
	isOptionValid EQU R6
	areMoviesPrinted EQU R7


; subroutine to reset variables
cleanVariables:
	CLR A
	MOV posRead, #0h
	RET

; subroutine to initialize variables
showMovies:
	CALL cleanVariables
	MOV SCON, #50h  ;  |  Enable Serial Mode 1 and the port receiver
	MOV PCON, #80h  ;  |  SMOD bit = 1
	MOV TMOD, #20h  ;  |  CT1 mode 2
	MOV TH1, #243   ;  |  Initial value for count
	MOV TL1, #243   ;  |  Recharge amount
	SETB TR1        ;  |  Turn on the timer
	MOV IE, #90h    ;  |  Sets the serial interruption

	MOV 75h, #'A'
	MOV 76h, #'B'
	MOV 77h, #'C'
	MOV 78h, #'E'
	MOV isOptionValid, #0
	MOV areMoviesPrinted, #0
	

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
	MOV areMoviesPrinted, #1
	RET ;  |  Breaks the loop if all movies have been shown


checkOption:
	ACALL COMP_SIZE
	MOV A, @R0
	INC R0
	DEC R2
	CJNE A, userOption, checkOption
	MOV isOptionValid, #1
	RET

COMP_SIZE:
	CJNE R2, #1, ARR_SIZE
	MOV isOptionValid, #0
	RET

ARR_SIZE:
	RET



InvalidOptionMessage: db "Please, choose an available option!"

	
; movies list: names and start times
moviesList:
	db "1 » Dune - Starts in 2m" 
	db '\n'
	db "2 » 007-Again - Starts in 1m"
	db 0

;==========================================================================================================
;                  LCD DISPLAY SECTION
;==========================================================================================================
org 01A0h

; Ask for the movie in the lcd display
askForTheMovie:
	MOV A, #02h ; |  Start position in the first column
	ACALL posicionaCursor
	MOV DPTR,#aftm1	        ; |  DPTR = begin of the phrase in the first column
	ACALL escreveString
	MOV A, #45h ; |  Start position in the second column
	ACALL posicionaCursor
	MOV DPTR,#aftm2 	    ; |  DPTR = begin of the phrase in the second column
    ACALL escreveString
	RET
	aftm1:
		db "Selecione um"
		db 0
	aftm2: 
		db "filme"
		db 0

; Ask for the seat in the lcd display
askForTheSeat:
	MOV A, #01h ; |  Start position in the first column
	ACALL posicionaCursor
	MOV DPTR,#afts1	        ; |  DPTR = begin of the phrase in the first column
	ACALL escreveString
	MOV A, #44h  ; |  Start position in the second column
	ACALL posicionaCursor
	MOV DPTR,#afts2 	    ; |  DPTR = begin of the phrase in the second column
    ACALL escreveString
	RET
	afts1:
		db "Selecione uma"
		db 0
	afts2: 
		db "poltrona"
		db 0

escreveString:
		MOV R2, #0
rot:
		MOV A, R2
 		MOVC A,@A+DPTR 		;lê a tabela da memória de programa
 		ACALL sendCharacter	; send data in A to LCD module
		INC R2
		JNZ rot		; if A is 0, then end of data has been reached - jump out of loop
 		RET

; --- Mapeamento de Hardware (8051) ---
    RS      equ     P1.3    ;Reg Select ligado em P1.3
    EN      equ     P1.2    ;Enable ligado em P1.2

; initialise the display
; see instruction set for details
lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delay		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereço da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delay			; wait for BF to clear
	CALL delay			; wait for BF to clear
	RET


;Retorna o cursor para primeira posição sem limpar o display
retornaCursor:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delay		; wait for BF to clear
	RET


delay:
	MOV R0, #50
	DJNZ R0, $
	RET

