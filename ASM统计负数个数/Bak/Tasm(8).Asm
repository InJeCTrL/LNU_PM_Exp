;统计某个数组中负元素的个数。有两个字数组BUFA和BUFB，
;统计各数组中负元素的个数，放入字节单元A、B中，
;统计数组中负元素的个数用子程序实现

DATA SEGMENT  
		BUFA	DW		-90,13,43,-92,-83,23,'$'
		BUFB	DW		18,-87,-23,29,66,99,-53,'$'
		TIPA		DB		'Neg Num Of BUFA:','$'
		TIPB		DB		'Neg Num Of BUFB:','$'
		NL		DB 		0DH,0AH,'$'
DATA ENDS  

CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器

		LEA		DX,BUFA			;DX作入口参数指向待查找数组首元素
		CALL	GetNegNum		;调用得到负数个数函数->DX
		PUSH	DX				;保存DX
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示将要输出BUFA中负数个数
		POP		DX				;恢复DX
		CALL	SHOW			;显示BUFA中负数元素个数
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;换行
		
		LEA		DX,BUFB			;DX作入口参数指向待查找数组首元素
		CALL	GetNegNum		;调用得到负数个数函数->DX
		PUSH	DX				;保存DX
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示将要输出BUFB中负数个数
		POP		DX				;恢复DX
		CALL	SHOW			;显示BUFB中负数元素个数
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;换行
ENDPROC:
		MOV AH,0AH
		INT 21H					;暂停
		MOV AX,4C00H
		INT 21H		
GetNegNum	PROC				;得到DX指向的数组中负数元素个数，结果存储到DX中
		MOV	DI,DX			;DX赋值到目的变址
		XOR		DX,DX			;作计数器，记录数组中负数个数
		MOV	AX,0				;与0对比
		MOV	BX,'$'			;结束符
CP:								;判断流程
		CMP		WORD
		CMP		WORD PTR[DI],AX	
		JGE		NEXT			;若非负数则跳转判断下一个数		
		INC		DX				;若是负数则DX计数器+1
NEXT:
		INC		DI
		INC		DI				;字单元需要向后偏移两个字节
		JMP		CP
		RET
GetNegNum endp
SHOW	PROC					;显示数字子程序，入口数字参数DX
		PUSH	AX
		PUSH	CX
		XOR		CX,CX
		MOV	AX,DX
		XOR		BX,BX
		MOV	BL,10
GOTOT:							;循环进行十进制转换并压栈
		XOR		DX,DX
		DIV		BX
		PUSH	DX
		INC		CX
		CMP		AL,0
		JNZ		GOTOT

OUTA:							;循环输出十进制数		
		CMP		CX,0
		JZ		OUTT
		POP		DX
		ADD		DL,30H
		MOV	AH,02H
		INT		21H				;显示一位十进制数
		DEC		CX
		JMP		OUTA
		
OUTT:
		POP		CX
		POP		AX
		RET
SHOW 	ENDP
CODE ENDS  
END START