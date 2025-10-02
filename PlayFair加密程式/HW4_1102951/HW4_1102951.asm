INCLUDE Irvine32.inc
BUFMAX = 128
.data
prompt1					BYTE	"Please input the plaintext: ",0
prompt2					BYTE	"Modified plaintext: ",0
prompt3					BYTE	"The ciphertext is: ",0
plaintext				BYTE	BUFMAX+1 DUP(0)
ciphertext				BYTE	BUFMAX+1 DUP(0)
PlayfairKey				BYTE    'M', 'O', 'N', 'A', 'R', 'C', 'H', 'Y', 'B', 'D', 'E', 'F', 'G', 'I', 'K', 'L', 'P', 'Q', 'S', 'T', 'U', 'V', 'W', 'X', 'Z'
.code
main PROC
	call inputPlaintext
	call checkCharacter
	call addX
	lea ESI,[ciphertext]
	lea EDI,[PlayfairKey]
	push ESI
	push EDI
	call PlayFair
	exit
main ENDP

inputPlaintext PROC
	mov EDX,OFFSET prompt1				; print "Please input the plaintext: "
	call WriteString
	mov ECX,BUFMAX
	mov EDX,OFFSET plaintext			; input string
	call ReadString
	mov ECX,EAX							; loop the size of input string
	ret
inputPlaintext ENDP

checkCharacter PROC
	mov EDX,OFFSET prompt2				; print "Modified plaintext: "
	call WriteString
	mov ESI,OFFSET plaintext
	mov EDI,OFFSET ciphertext
charCheck:
	mov AL,[ESI]
	cmp AL,41h							; skip if the character is below then 'A'
	jb skip
	cmp AL,5bh							; copy if the character is between 'A' to 'Z'
	jb copy
	cmp AL,61h							; skip if the character is between '[' to '`'
	jb skip
	cmp AL,7bh							; Change to Uppercase if the character is between 'a' to 'z'
	jb toUpperCase
	cmp AL,7fh							; skip if the character is between '{' to '~'
	jb skip
toUpperCase:
	sub AL,20h
copy:
	mov [EDI],AL
	inc EDI
skip:
	inc ESI
	loop charCheck
	invoke str_length,ADDR ciphertext
	mov ECX,EAX
	invoke str_copy,ADDR ciphertext,ADDR plaintext
	ret
checkCharacter ENDP

addX PROC
	mov ESI,OFFSET plaintext
	mov EDI,OFFSET ciphertext
twinCheck:
	mov AL,[ESI]
	mov AH,[ESI+1]
	mov [EDI],AL
	call WriteChar
	cmp AL,0							; if the AL = 0, then finish
	je theAddXEnd
	cmp AH,0							; if the AH = 0, then needs to add 'X' into ciphertext
	je addLastX
	cmp AL,AH							; if the AL != AH, then write it into ciphertext
	jne notTwin
	mov AL,'X'
	mov [EDI+1],AL
	call WriteChar
	jmp finishTwinCheck
notTwin:
	mov [EDI+1],AH
	mov AL,AH
	call WriteChar
	inc ESI
finishTwinCheck:
	mov AL,' '
	call WriteChar
	inc ESI
	add EDI,2
	loop twinCheck
addLastX:
	mov AL,'X'
	mov [EDI+1],AL
	call WriteChar
theAddXEnd:
	invoke str_length,ADDR ciphertext
	mov ECX,EAX
	invoke str_copy,ADDR ciphertext,ADDR plaintext
	call Crlf
	ret
addX ENDP

PlayFair PROC
	mov EDX,OFFSET prompt3
	call WriteString
	mov ESI,[EBP-16]					; ciphertext starting address
	push ECX
changeJToI:								; changing J to I in the ciphertext, using loop due to there may have more then one 'J' in the string
	mov AL,[ESI]
	cmp AL,'J'
	jne	notJ
	dec AL
	mov [ESI],AL						; changing J to I if it equals to J and store it into modifiedPlaintext
notJ:
	inc ESI								; do nothing if it isn't J
	loop changeJtoI
	mov ESI,[EBP-16]					; ciphertext starting address
	mov ECX,[EBP-28]					; load old ECX from stack
	shr ECX,1							; do 2 bytes at a time
encrypt:
	mov DL,5							; each playfair key row has five elements
	inc ESI
	call findRowCol						; do second byte first and store quotient and remainder in BL and BH
	mov BX,AX
	dec ESI
	call findRowCol						; than do first byte and store quotient and remainder in AL and AH
    cmp AL,BL							; if AL = BL(same Quotient), indicate that they are at same row
    jne  notSameRow
	mov DL,AH
	mov DH,BH
	call addColumnOrRow
	mov AH,DL
	mov BH,DH
	jmp finishEncrypt
notSameRow:
    cmp AH,BH							; if AH = BH(same Remainder), indicate that they are at same column
    jne  differentRowAndCol
	mov DL,AL
	mov DH,BL
	call addColumnOrRow
	mov AL,DL
	mov BL,DH
	jmp finishEncrypt
differentRowAndCol:
    xchg AH,BH							; if they are not above, exchange them
finishEncrypt:
	push EAX
	inc ESI
	call findPlayfairKey
	mov EBX,[EBP-32]
	dec ESI
	call findPlayfairKey
	mov AL,[ESI]
	call WriteChar
	mov AL,[ESI+1]
	call WriteChar
	add ESI,2
	mov AL,' '
	call WriteChar
	pop EAX
	loop encrypt
	pop ECX
	ret
PlayFair ENDP

findRowCol PROC
	mov AL,[ESI]
	mov EDI,[EBP-20]					; PlayfairKey starting address
	push ECX
	mov ECX,25
	repne scasb							; compare to playfair key
	pop ECX
	sub EDI,[EBP-20]
	dec EDI								; the offset of it in playfair key
	mov EAX,EDI
	idiv DL								; division to know the row and column of it in playfair key
	ret
findRowCol ENDP

addColumnOrRow PROC
	inc DL
	cmp DL,5
	jne nextRowOrColumn
	mov DL,0
nextRowOrColumn:
	inc DH
	cmp DH,5
	jne finishRowOrColumn
	mov DH,0
finishRowOrColumn:
	ret
addColumnOrRow ENDP

findPlayfairKey PROC
	mov EDI,[EBP-20]
	mov AL,BL
	mov DL,5
	mul DL
	add AL,BH
	add EDI,EAX
	mov AL,[EDI]
	mov [ESI],AL
	ret
findPlayfairKey ENDP
END main