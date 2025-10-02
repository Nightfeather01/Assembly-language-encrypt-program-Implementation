INCLUDE Irvine32.inc

.data
    arrayStr   BYTE 30 DUP (?)                      ; define an array to store random array string
    countArray EQU 30                               ; count random array string element
    outputStr  BYTE "Enter a Number:", 0            ; output string

.code
main PROC
    mov EDX, OFFSET outputStr
    call WriteString                                ; print output string
    call ReadInt                                    ; read the input number
    mov ECX, EAX                                    ; move the input number to ECX for outer loop counter

L1: call Rand1                                      ; generate random array string
    call CheckSmallLetter                           ; check the small letter in the random array string
    loop L1
    exit
main ENDP

Rand1 PROC
    push ECX                                        ; store outer loop counter to stack
    mov ECX, countArray                             ; load inner loop counter to ECX
    mov ESI, OFFSET arrayStr                        ; load arrayStr index to esi

L2:
    mov EAX,56
    call RandomRange                                ; generate random int
    add EAX, 65                                     ; start from 41h equals to 65d
    mov [ESI], AL                                   ; move the generate random int into arrayStr
    inc ESI                                         ; increase esi
    call WriteChar                                  ; print the character
    loop L2

    call Crlf                                       ; change line after print all the character
    pop ECX                                         ; restore outer loop counter to ECX
    ret
Rand1 ENDP

CheckSmallLetter PROC
    push ECX                                        ; store outer loop counter to stack
    mov ECX, countArray                             ; load inner loop counter to ECX
    mov ESI, OFFSET arrayStr                        ; load arrayStr index to esi
    xor EAX, EAX                                    ; initialize the lowercase count to 0

L3:
    movzx EBX, byte ptr [ESI]                       ; load the character into ebx
    inc ESI                                         ; increase esi
    cmp BL, 61h                                     ; compare with 'a'
    jb L3_end                                       ; if less than 'a', skip
    cmp BL, 7Ah                                     ; compare with 'z'
    ja L3_end                                       ; if greater than 'z', skip
    inc EAX                                         ; increment the lowercase count
L3_end:
    loop L3

    call WriteDec                                   ; print the result of small letter
    call Crlf                                       ; change line after print all the character
    pop ECX                                         ; restore outer loop counter to ECX
    ret
CheckSmallLetter ENDP

END main