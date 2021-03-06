;一、 实验要求 
;编写程序，实现两个字符串比较。如相同，则显示“MATCH”，否
;则，显示“NOMATCH”。 
DATA SEGMENT
	TIP	DB	'IS STRING2 IN STRING1? ',0DH,0AH,'$'
	TIPA	DB	'InPut String1:',0DH,0AH,'$'
	TIPB	DB	'InPut String2:',0DH,0AH,'$'
	TIPC	DB	'MATCH!',0DH,0AH,'$'
	TIPD	DB	'NOTMATCH!',0DH,0AH,'$'
	NL	DB	0DH,0AH,'$'
	STRA DB	100 DUP(?)
	STRB DB	100 DUP(?)
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA,ES:DATA
START:
		MOV AX,DATA
		MOV DS,AX			;初始化代码段基址	
		MOV ES,AX			;初始化附加段基址
		
		LEA DX,TIP
		MOV AH,09H
		INT 21H				;显示TIP
		LEA DX,TIPA
		INT 21H				;显示TIPA
		MOV AL,100
		LEA 	BX,STRA
		MOV [BX],AL
		LEA DX,STRA
		MOV AH,0AH
		INT 21H				;输入STRA
		LEA DX,NL
		MOV AH,09H
		INT 21H				;换行
		MOV AL,100
		LEA 	BX,STRB
		MOV [BX],AL
		LEA DX,STRB
		MOV AH,0AH
		INT 21H				;输入STRB
		LEA DX,NL
		MOV AH,09H
		INT 21H				;换行
		
		XOR CX,CX
		XOR DX,DX
		LEA SI,STRA
		INC SI
		MOV CL,BYTE PTR [SI]	;读取串A字符数->CX
		INC SI				;跳过字符数标记位
QUITB:	LEA DI,STRB
		INC DI
		MOV DL,BYTE PTR [DI]	;读取串B字符数->DX
		INC DI				;跳过字符数标记位
		DEC DL
LOOPA:
  		MOV AL,[SI]
		CMP AL,[DI]
		JNZ NEXTA			;并继续循环判断
		INC SI
		INC DI				;若第一个字符匹配相等则各前进一位
		CMP DX,0
		JZ CHKOK			;若只传入一个字母且匹配成功则直接跳出
  LOOPB:
  		MOV AL,[SI]
		CMP AL,[DI]
		JNZ QUITB			;若遇到字符匹配不相等则退出内循环
		INC SI
		INC DI				;若字符匹配相等则各进一位
		DEC DX
		CMP DX,0
		JNZ LOOPB
		JMP CHKOK			;串B已匹配完毕则直接跳出
NEXTA:	INC SI				;串A下一位
		LOOP LOOPA

CHKOK:	CMP DX,0			;若匹配成功则DX为0
		JNZ NO				;匹配失败则跳转NO
		CMP CX,0				;若匹配成功则CX不为0
		JZ NO				;匹配失败则跳转NO
YES:		LEA DX,TIPC
		MOV AH,09H
		INT 21H				;显示TIPC
		JMP QUITP
NO:		LEA DX,TIPD
		MOV AH,09H
		INT 21H				;显示TIPD
	
QUITP:	MOV AH,0AH
		INT 21H
		MOV AX,4C00H
		INT 21H
CODE ENDS  
END START