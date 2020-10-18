;=====================================================
;                      HEADER;
;=====================================================
; This program seeks to automate a 
; movie theater using the 8051 
; microcontroller in the EdSim51 
; simulator
;=====================================================


;=====================================================
;                  MAIN SECTION
;=====================================================

; Jumps for the main function
org 0000h
	LJMP Main


; Main function
org 0080h
Main:
	CALL showMovies
	SJMP $
;=====================================================
;              SERIAL CHANNEL SECTION
;=====================================================

; INTERRUPTION FOR RECEPTIONS
org 0023H
	MOV A, SBUF                   ; |  Reads the bytes received
	CJNE A, #0Dh, storeUserOption ; | Stores the value if diffent from 0D
	CLR RI                        ; |  Resets RI to receive new bytes
	RETI
	storeUserOption:
		MOV userOption, A  ; |  Writes the value in the userOption var
		CLR posRead
		;ACALL validateOption ; |
		CLR RI             ; |  Resets RI to receive new bytes
		RETI



org 00A0h
	posRead EQU 70h    ; |  Variable to store the string positions
	userOption EQU 71h ; |     "      "   "    "  movie chosen by the user   



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
	

;subroutine to print movies in the serial port
writeMovies:
	MOV DPTR, #moviesList ; |  Stores movies in the DPTR register
	MOV A, posRead   ; |  like the variable i in a For to print the whole string
	MOVC A, @A+DPTR  ; |  Reads the current string letter
	JZ break         ; |  Breaks if the movies are printed
	MOV SBUF, A      ; |  Transmits the content in A
	JNB TI, $        ; |  Waits the end of the transmission
	CLR TI           ; |  Cleans the end of transmission indicator
	INC posRead      ; |  Increments the string position
	SJMP writeMovies ; |  Repeats to print next line

break:
	RET ;  |  Breaks the loop if all movies have been shown


; movies list: names and start times
moviesList:
	db "1 » Dune - Starts in 2m" 
	db '\n'
	db "2 » 007-Again - Starts in 1m"

