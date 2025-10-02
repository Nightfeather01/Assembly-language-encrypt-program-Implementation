INCLUDE Irvine32.inc
BUFMAX = 128                                        ;maxium buffer size

.data
    inputPlaintext BYTE "Input Plaintext: ", 0
    modifiedPlaintext BYTE "Modified Plaintext: ", 0
    key BYTE "Key: ", 0
    cyphertext BYTE "Cyphertext: ", 0
    plaintextAfterDecrypt BYTE "Plaintext after decrypt: ", 0
    buffer BYTE BUFMAX+1 DUP(0)                     ; the reason that setting the buffer size to BUFMAX+1 is because null terminator occupy one bytes
    modifiedBuffer BYTE BUFMAX+1 DUP(0)
    keySeed BYTE BUFMAX+1 DUP(0)
    bufSize DWORD ?
    keySize DWORD ? 

.code
main PROC
    call    InputTheString
    call    ModifyTheString
    call    GenerateKey
    call    EncryptTheString
    call    DecryptTheString
    exit
main ENDP

InputTheString PROC
    pushad                                          ; store all registers to stack before starting
    mov EDX,OFFSET inputPlaintext
    call    WriteString                             ; print "Input Plaintext: "
    mov ECX,BUFMAX                                  ; maximum character count
    mov	EDX,OFFSET buffer                           ; point to the buffer
    call    ReadString         	                    ; input the buffer
    mov	bufSize,EAX        	                        ; save the buffer length to bufSize
    call Crlf                                       ; next line
    popad                                           ; restore all registers to stack after using
    ret
InputTheString ENDP

ModifyTheString PROC
    pushad                                          ; store all registers to stack before starting
    mov ECX,bufSize                                 ; loop bufSize
    mov ESI,OFFSET buffer                           ; load buffer starting address to ESI
    mov EDI,OFFSET modifiedBuffer                   ; load modifiedBuffer starting address to EDI
    xor EBX,EBX                                     ; clear EBX to zero and using it to count the modifiedBuffer size
L1: mov AL,[ESI]                                    ; load buffer character into AL
    cmp AL,20h                                      ; compare with 'Space'
    je L1_end                                       ; jump taken if equals to 'Space'
    cmp AL,2Ch                                      ; compare with ','
    je L1_end                                       ; jump taken if equals to ','
    cmp AL,2Eh                                      ; compare with '.'
    je L1_end                                       ; jump taken if equals to '.'
    mov [EDI],AL                                    ; if not taken, put the character to new string
    inc EDI                                         ; increase EDI
    inc EBX                                         ; increase EBX
L1_end:
    inc ESI                                         ; increase ESI
    loop L1
    
    mov BYTE PTR [EDI],0                            ; add null terminator at the end of keySeed
    inc EBX
    mov bufSize,EBX                                 ; store EBX to bufSize
    mov EDX,OFFSET modifiedPlaintext
    call    WriteString                             ; print "Modified Plaintext: "
    mov EDX,OFFSET modifiedBuffer
    call    WriteString                             ; print modifiedBuffer
    call    Crlf                                    ; next line
    popad                                           ; restore all registers to stack after using
    ret
ModifyTheString ENDP

GenerateKey PROC
    pushad                                          ; store all registers to stack before starting
    mov ESI,OFFSET keySeed                          ; load keySeed index to ESI
    mov EAX,BUFMAX                                  ; setting key range
    call    RandomRange
    inc EAX
    mov keySize,EAX                                 ; store key size
    mov ECX,EAX                                     ; loop keySize
    xor EAX,EAX                                     ; clear EAX to zero
L2: mov AL,5Bh                                      ; the range is start from 21h to 7Dh
    call    RandomRange                             ; generate random int
    add AL,21h                                      ; start from 21h
    mov [ESI],AL                                    ; move character to ESI 
    inc ESI                                         ; increase ESI
    inc EBX                                         ; increase EBX
    loop L2
    
    mov BYTE PTR [ESI], 0                           ; add null terminator at the end of keySeed
    mov EDX, OFFSET key
    call WriteString                                ; print key
    mov EDX, OFFSET keySeed
    call WriteString                                ; print keySeed
    call Crlf
    popad                                           ; restore all registers to stack after using
    ret
GenerateKey ENDP

EncryptTheString PROC
    pushad                                          ; store all registers to stack before starting
    mov ESI,OFFSET modifiedBuffer                   ; load modifiedBuffer address to ESI
    mov EDI,OFFSET keySeed                          ; load keySeed starting address to ESI
    mov EAX,EDI                                     ; store keySeed starting address to EAX
    mov ECX,bufSize                                 ; loop bufsize
L3: mov BL,[ESI]                                    ; load modifiedBuffer character into AL
    cmp BL,0
    je L3_end
    mov BH,[EDI]                                    ; load keySeed character into AH
    xor BL,BH                                       ; encrypt modifiedBuffer
    mov [ESI],BL
    inc ESI
    inc EDI
    mov EAX, EDI                                    ; store the current EDI value in EAX
    sub EAX, OFFSET keySeed                         ; calculate the offset from the start of keySeed
    cmp EAX, keySize                                ; compare with the keySize
    jb L3
    mov EDI, OFFSET keySeed
    jmp L3
L3_end:
    mov EDX, OFFSET cyphertext
    call WriteString                                ; print "Cyphertext: "
    mov EDX, OFFSET modifiedBuffer
    call WriteString                                ; print modifiedBuffer
    call Crlf                                       ; next line
    popad                                           ; restore all register to stack after using
    ret
EncryptTheString ENDP

DecryptTheString PROC
    pushad                                          ; store all registers to stack before starting
    mov ESI, OFFSET modifiedBuffer                  ; load modifiedBuffer address to ESI
    mov EDI, OFFSET keySeed                         ; load keySeed starting address to EDI
    mov EAX, EDI                                    ; store keySeed starting address to EAX
    mov ECX, bufSize                                ; loop bufSize
L4: mov BL, [ESI]                                   ; load modifiedBuffer character into BL
    cmp BL, 0
    je L4_end
    mov BH, [EDI]                                   ; load keySeed character into BH
    xor BL, BH                                      ; decrypt modifiedBuffer
    mov [ESI], BL                                   ; store the decrypted byte back
    inc ESI
    inc EDI
    mov EAX, EDI                                    ; store the current EDI value in EAX
    sub EAX, OFFSET keySeed                         ; calculate the offset from the start of keySeed
    cmp EAX, keySize                                ; compare with the keySize
    jb L4                                           ; if less than keySize, continue the loop
    mov EDI, OFFSET keySeed                         ; reset EDI to the start of keySeed
    jmp L4
L4_end:
    mov EDX, OFFSET plaintextAfterDecrypt
    call WriteString                                ; print "Plaintext after decrypt: "
    mov EDX, OFFSET modifiedBuffer
    call WriteString                                ; print decrypted modifiedBuffer
    call Crlf                                       ; next line
    popad                                           ; restore all registers to stack after using
    ret
DecryptTheString ENDP

END main