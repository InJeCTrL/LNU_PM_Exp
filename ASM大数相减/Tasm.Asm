DATA SEGMENT  
	FIRST		DB '1','2','3','4','5','$'
	SECOND		DB '0','6','7','8','9','$'
DATA ENDS  

CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
	MOV AX,DATA	
	MOV DS,AX			;初始化数据段基址
	LEA DI,FIRST
	LEA SI,SECOND
	
	MOV AH,09H
	MOV DX,OFFSET FIRST
	INT 21H
	MOV AH,02H
	MOV DL,'-'
	INT 21H
	MOV AH,09H
	MOV DX,OFFSET SECOND
	INT 21H
	MOV AH,02H
	MOV DL,'='
	INT 21H
	
	MOV CX,5
LOOP1:;字符转数字
	MOV AL,BYTE PTR [DI]
	SUB AL,30H
	MOV BYTE PTR [DI],AL
	MOV BL,BYTE PTR [SI]
	SUB BL,30H
	MOV BYTE PTR [SI],BL
	INC DI
	INC SI
	LOOP LOOP1
	DEC DI
	DEC SI
	CLC
	MOV CX,5
LOOP2:
	MOV AL,[DI]
	SBB AL,[SI]
	AAS
	MOV [DI],AL
	DEC DI
	DEC SI
	LOOP LOOP2
	INC DI
	INC SI
	MOV CX,5
LOOP3:
	MOV AL,BYTE PTR [DI]
	ADD AL,30H
	MOV BYTE PTR [DI],AL
	MOV BL,BYTE PTR [SI]
	ADD BL,30H
	MOV BYTE PTR [SI],BL
	INC DI
	INC SI
	LOOP LOOP3
	
	MOV AH,09H
	MOV DX,OFFSET FIRST
	INT 21H
	MOV AH,0AH
	INT 21H
CODE ENDS  
END START