;用串操作指令设计程序，实现在指定存储区 6000：0-6000：100
;（长度为100H）中寻找匹配字符，遇空格字符（20H）结束，退出时
;给出是否找到的信息。 
DATA SEGMENT
	E	DB	'FOUND!$'
	N	DB	'NOT FOUND!$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV AX,DATA
		MOV DS,AX			;初始化代码段基址
		MOV AX,6000H	
		MOV ES,AX			;初始化附加段基址
		MOV DI,0FEH
		MOV AL,20H
		MOV ES:[DI],AL
		MOV DI,0
		
		MOV CX,100H			;长度为100H
		MOV AL,20H			;AL存放空格标记
		CLD					;DI递增
REPNZ	SCASB				;若当前字节不等于AL中存放的字节则继续
		CMP CX,0
		JZ NEXIST			;检查是否有AL中相同字符，若没有则跳转NEXIST
EXIST:	LEA DX,E				;若存在则设置待输出字符串为E
		JMP SHOW
NEXIST:	LEA DX,N				;若存在则设置待输出字符串为N
SHOW:	MOV AH,09H			;输出提示信息
		INT 21H
		
		MOV AH,0AH
		INT 21H
		MOV AX,4C00H
		INT 21H
CODE ENDS  
END START