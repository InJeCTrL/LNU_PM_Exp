;编写程序，将键盘接收到的四位十六进制数转换为等值的二进制
;数，再显示在屏幕上。若输入的不是 0-F间的数字，则显示出错信息，
;并要求重新输入。 
 
DATA SEGMENT
	TIP	DB	'Input:',0DH,0AH,'$'
	TIPB	DB	'ERROR NUMBER!',0DH,0AH,'$'
	HN	DB	7 DUP(?),'$'
	BN	DB 	16 DUP(?),'$'
	NL	DB	0DH,0AH,'$'
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
		MOV AL,5
		LEA 	BX,HN
		MOV [BX],AL			;限定HN字符串输入最多4字节
		LEA DX,HN
		MOV AH,0AH
		INT 21H				;输入HN
		LEA DX,NL
		MOV AH,09H
		INT 21H				;换行
		
		LEA SI,HN
		LEA DI,BN
		INC SI
		INC SI				;跳过字节数目单元
		MOV DH,4			;四个十六进制数大循环四次
		MOV CL,7			;后续需要右移
LOOPT:
		CALL CHK
		MOV DL,4
		ADD DI,5H			;DI+5
  LOOPTP:
  		XOR AL,AL			
  		SHR AX,1				;AH中内容除以2，余数->AL
		SHR AL,CL			;二进制位右移7次
		ADD AL,30H			;二进制数转为ASCII
		MOV [DI],AL			;将二进制位填入目标位置
		DEC DI				;DI减量
  DEC DL
  CMP DL,0
  JNZ LOOPTP
		INC SI				;SI移动到下一个十六进制数字符
DEC DH
CMP DH,0
JNZ LOOPT

ERRNUM:
		LEA DX,TIPB
		MOV AH,09H
		INT 21H				;显示TIPB
QUITP:	
		MOV AH,0AH
		INT 21H				;暂停
		MOV AX,4C00H
		INT 21H
CHK PROC ;检测是否为正确的十六进制数
		MOV AH,[SI]
		SUB AH,30H
		CMP AH,0H		;若小于0进入转到错误
		JB ERRNUM
		CMP AH,0FH		;若大于F进入转到错误
		JA ERRNUM
		RET
CHK endp
CODE ENDS  
END START