; This program seeks to automate a movie theater using the 8051 microcontroller in the EdSim51 simulator

; Jumps for the main function
org 0000h
	LJMP Main

; Main function
org 0080h
Main:
	CALL showMovies
	SJMP $

; Function to display the movies available in the serial port
org 00A0h
; Variable to store de positions of string
posRead EQU 70h
; subroutine to reset variables
cleanVariables:
	CLR A
	MOV posRead, #0h
	RET
showMovies:
	CALL cleanVariables
	MOV SCON, #40h  ;  |  Serial mode 1
	MOV PCON, #80h  ;  |  SMOD bit = 1
	MOV TMOD, #20h  ;  |  CT1 mode 2
	MOV TH1, #243   ;  |  Initial value for count
	MOV TL1, #243   ;  |  Recharge amount
	SETB TR1        ;  | Turn on Counter
writeMovies:
	MOV DPTR, #moviesList ; |  Move the movies to the DPTR
	MOV A, posRead   ; |  like the variable i in a For to print the hole string
	MOVC A, @A+DPTR  ; |  Read the first letter
	JZ finish        ; |  Returns if the movies are printed
	MOV SBUF, A      ; |  Transmit the content in A
	JNB TI, $        ; |  Waits the transmition finish
	CLR TI           ; |  Clean the end of transmition indicator
	INC posRead      ; |  Incresase to read the next letter
	SJMP writeMovies ; |  Repeat to print next line
finish:
	RET ;  |  Returns if all movies are being shown

; list of movies and what time do they starts
moviesList:
	db "1 » Dune - Starts in 2m" 
	db '\n'
	db "2 » 007-Again - Starts in 1m"



