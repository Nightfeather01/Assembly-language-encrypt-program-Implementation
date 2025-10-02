INCLUDE Irvine32.inc

BUFMAX = 128

.data
introText		BYTE	"This is a Morse Code Translator!", 0
enterText		BYTE    "Please enter your string:", 0
outputText		BYTE	"Morse Code:", 0
askStr			BYTE    "Would you like to proceed another translation (y/n)? ", 0
inputStr		BYTE	BUFMAX+1 DUP(0)
morseCode		DWORD	' /', null, 0, ' @', null, 0, '..-.', ' .-', 0, ' @', null, 0, '-...', ' -..', 0, ' @', null, 0, ' @', null, 0, '---.', ' .-', 0, '--.-', ' -.', 0, '--.-', ' -.', 0, ' @', null, 0, ' @', null, 0, '..--', ' --', 0						; SP ~ ,
				DWORD	'...-', ' -.', 0, '-.-.', ' -.', 0, '-..-', ' .', 0, '----', ' -', 0, '---.', ' -', 0, '--..', ' -', 0, '-...', ' -', 0, '....', ' -', 0, '....', ' .', 0, '...-', ' .', 0, '..--', ' .', 0, '.---', ' .', 0, '----', ' .', 0			;  - ~ 9
				DWORD	'.---', ' ..', 0, '.-.-', ' .-', 0, ' @', null, 0, ' @', null, 0, ' @', null, 0, '--..', ' ..', 0, ' @', null, 0																													;  : ~ @
				DWORD	' -.', null, 0, '...-', ' ', 0, '.-.-', ' ', 0, ' ..-', null, 0, ' .', null, 0, '.-..', ' ', 0, ' .--', null, 0, '....', ' ', 0, ' ..', null, 0, '---.', ' ', 0, ' -.-', null, 0, '..-.', ' ', 0, ' --', null, 0		;  A ~ M
				DWORD   ' .-', null, 0, ' ---' , null, 0, '.--.', ' ', 0, '-.--', ' ', 0, ' .-.', null, 0, ' ...', null, 0, ' -', null, 0, ' -..', null, 0, '-...', ' ', 0, ' --.', null, 0, '-..-', ' ', 0, '--.-', ' ', 0, '..--', ' ', 0		;  N ~ Z
				DWORD	' @', null, 0, ' @', null, 0, ' @', null, 0, ' @', null, 0, ' @', null, 0																																						;	[~_

.code
main PROC
	mov EDX,OFFSET introText	; print "This is a Morse Code Translator!"
	call WriteString
keepGoing:
	call Crlf
	mov EDX,OFFSET enterText	; print "Please enter your string:"
	call WriteString
	call Crlf
	mov EDX,OFFSET inputStr	; input string
	mov ECX,BUFMAX
	call ReadString
	mov ECX,EAX					; store string size
	call lowerToCap				; change lowercase to uppercase
	mov EDX,OFFSET outputText	; print "Morse Code:"
	call WriteString
	call Crlf
	call MorseTran				; change string to morse code
	call Crlf
	mov EDX,OFFSET askStr		; print "Would you like to proceed another translation (y/n)? "
	call WriteString
	call ReadChar
	cmp AL,79h
    je keepGoing
	exit
main ENDP

lowerToCap PROC
	push ECX
	mov EAX,OFFSET inputStr
	mov ESI,EAX					; store the starting position of input string to ESI

lowercaseCheck:
	mov EBX,0					; clean up EBX
	mov BL,[EAX]
	cmp BL,60h
	jb noChange
	sub BL,20h					; lowercase change to uppercase
noChange:
	mov [EAX],BL
	inc EAX
	loop lowercaseCheck

	pop ECX
	ret
lowerToCap ENDP

MorseTran PROC
	push ECX
	mov EAX,ESI					; restore the starting position of input string to EAX

TransferToMorse:
	mov EBX,0
	mov BL,[EAX]
	sub BL,20h
	imul BX,12
    mov EDX,OFFSET morseCode
	mov ESI,EDX
    add ESI,EBX
	mov EDX,ESI
    call WriteString
	inc EAX
    loop TransferToMorse

	pop ECX
	ret
MorseTran ENDP
END main