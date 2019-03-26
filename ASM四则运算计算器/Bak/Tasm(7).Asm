;编写一个有符号多位十进制数的四则运算计算器程序，所输入的算式如下例所示：
;－278＋32＝
;－132--12＝
;11＊－32＝
;－1234／－18＝
;要求程序能接收键入的算式，在接收到‘＝’号时，计算并以有符号十进制数的形式显示结果，然后允许用户继续键入算式。
;如果键入算式后再键入‘.’，则显示结果并结束整个程序。（‘／’为整除）

DATA SEGMENT  
		TIPA		DB		'Input A Formula, Ends With "=" (Number No More Than 32767)!',0DH,0AH,'$'
		TIPB		DB		0DH,0AH,'Press Any Key Except "." To Continue Calculating!',0DH,0AH,'$'
		TIP		DB		'Press Any Key To Exit!',0DH,0AH,'$'
		NL		DB 		0DH,0AH,'$'
DATA ENDS  

CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
INIT:	
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示输入算式
		
AllClear:							;总清除
		XOR		AX,AX
		XOR		BX,BX
		XOR		CX,CX
		XOR		DX,DX			;清空用到的通用寄存器
InputFirstNumber:					;输入第一个数（最终保存在CX中）
		MOV	AH,01H
		INT		21H				;输入符号字符或数字字符->AL
		CMP		AL,'-'			;判断输入的字符是否是减号'-'
		JNZ		InputTrueNumber	;若不是符号则跳转到输入数字过程（BH == 0）
		MOV	BH,1				;BH用于标识负数情况，1：负数，0：正数
		MOV	AH,01H
		INT		21H				;输入数字字符->AL
		JMP		InputTrueNumber	;跳转到输入数字过程（BH == 1）
InputTrueNumber:					;输入操作数的数字(不包含符号)
		XOR		AH,AH			;清空无用的AH
		SUB		AL,30H			;将输入的一个数字字符转为数字
		PUSH	AX				;保存输入的一个数字
		MOV	AX,10			;AX保存乘数10
		MUL		CX				;CX用于保存第一个操作数，此处将CX乘以10
		MOV	CX,AX			;乘10后覆盖CX中
		POP		AX				;第一个操作数恢复到AX中
		ADD		CX,AX			;将输入的一个数字加入CX保存区中
		MOV	AH,01H
		INT		21H				;输入下一个数字字符或操作符->AL
		CMP		AL,30H			;小于30H判定为非数字，进入输入符号位的过程，否则循环输入数字
		JAE		InputTrueNumber	;大等于30H，判定为数字
		CMP		BH,0				;第一个操作数的数字部分输入结束，判断是否要转为负数
		JZ		InputOperand		;若表示的是正数，则跳转到操作符输入		
		NEG		CX				;求得第一个操作数的相反数
		XOR		BH,BH			;清空第一个数的负数标识
InputOperand:						;输入操作符，判断操作符类型，将BL进行标记
		CMP		AL,'+'			;判断是否为加法，是则BL = 0
		CMP		AL,'-'			;判断是否为减法，是则BL = 1
		JNZ		CHKM			;不是减法则跳转到判断乘法
		MOV	BL,1
CHKM:	CMP		AL,'*'			;判断是否为乘法，是则BL = 2
		JNZ		CHKD			;不是乘法则跳转到判断除法
		MOV	BL,2				
CHKD:	CMP		AL,'/'			;判断是否为除法，是则BL = 3
		JNZ		InputSecondNumber;不是除法则跳出操作符判断
		MOV	BL,3
		JMP		InputSecondNumber
InputSecondNumber:				;输入第二个数（最终保存在DX中）
		MOV	AH,01H
		INT		21H				;输入符号字符或数字字符->AL
		CMP		AL,'-'			;判断输入的字符是否是减号'-'
		JNZ		InputTrueNumberB	;若不是符号则跳转到输入数字过程（BH == 0）
		MOV	BH,1				;BH用于标识负数情况，1：负数，0：正数
		MOV	AH,01H
		INT		21H				;输入符号字符或数字字符->AL
		JMP		InputTrueNumberB	;跳转到输入数字过程（BH == 1）
InputTrueNumberB:				;输入操作数的数字(不包含符号)
		XOR		AH,AH			;清空无用的AH
		SUB		AL,30H			;将输入的一个数字字符转为数字
		PUSH	AX				;保存输入的一个数字
		MOV	AX,10			;AX保存乘数10
		MUL		DX				;DX用于保存第二个操作数，此处将DX乘以10
		MOV	DX,AX			;乘10后覆盖DX中
		POP		AX				;第一个操作数恢复到AX中
		ADD		DX,AX			;将输入的一个数字加入DX保存区中
		MOV	AH,01H
		INT		21H				;输入下一个数字字符或操作符->AL
		CMP		AL,'='			;判断是否为等号，若是等号则不再循环
		JNZ		InputTrueNumberB	;不为等号，判定为数字，继续循环
		CMP		BH,0				;第二个操作数的数字部分输入结束，判断是否要转为负数
		JZ		CALC			;若表示的是正数，则跳转到计算过程		
		NEG		DX				;求得第二个操作数的相反数

CALC:							;根据操作符类型进行相应运算
		MOV	AX,CX			;将第一个操作数移动到AX
		CMP		BL,1				;二分判断符号
		JBE		ISAorS			;判断BL <= 1，则跳转到判断加法或减法
		CMP		BL,2				;判断是否为乘法
		JZ		CALCM			;是乘法，跳转到乘法计算过程
		PUSH	BX				;保存BX
		MOV	BX,DX
		CMP		AX,0				;比较被除数是否大于0，若小于0，则需要把DX全置1
		JGE		MT0				;被除数大于等于0时直接清空DX
		OR		DX,1111111111111111B		;被除数为负数时DX全置1
		JMP		MTOUT
MT0:	XOR		DX,DX
MTOUT:	IDIV		BX				;否则进行除法操作，结果（商）->AX
		POP		BX				;恢复BX
		JMP		SHOWP			;计算结束后跳转到显示答案过程
ISAorS:
		CMP		BL,0				;判断是否为加法
		JZ		CALCA			;是加法，跳转到加法计算过程
		SUB		AX,DX			;减法操作，结果（差）->AX
		JMP		SHOWP			;计算技术后跳转到显示答案过程
CALCA:
		ADD		AX,DX			;加法操作，结果（合）->AX
		JMP		SHOWP			;计算结束后跳转到显示答案过程
CALCM:
		PUSH	BX				;保存BX
		MOV	BX,DX
		XOR		DX,DX			;清空用于保存乘法结果高位的DX
		IMUL	BX				;乘法操作，结果（积）->DX:AX
		POP		BX				;恢复BX
			
SHOWP:							;显示计算结果
		CMP		BL,2				;判断是否执行的是乘法法操作，若是乘法操作则需要判断DX最高位
		JZ		MULCHK			
		CMP		AX,0				;判断AX是否大等于0
		JGE		SHOWPN			;已是非负数则直接输出结果		
		NEG		AX				;DX取相反数
		PUSH	AX				;保存AX
		MOV	AH,02H
		MOV	DL,'-'
		INT		21H				;输出一个负号
		POP		AX				;恢复AX
		JMP		SHOWPN			;跳转到常规运算答案输出过程
MULCHK:
		CMP		DX,0				;判断DX是否大等于0
		JGE		SHOWPM		;已是非负数则直接输出乘法结果		
		NEG		DX				;DX取相反数
		DEC		DX
		NEG		AX				;AX取相反数
		PUSH	AX				;保存AX
		PUSH	DX				;保存DX
		MOV	AH,02H
		MOV	DL,'-'
		INT		21H				;输出一个负号
		POP		DX				;恢复DX
		POP		AX				;恢复AX
SHOWPM:						;针对乘法的输出
		CALL	SHOW			;显示DX
		MOV	DX,AX
		CALL	SHOW			;显示原AX内容
		JMP		GO				;跳转到提示过程
SHOWPN:						;针对乘法以外的输出
		CALL	SHOW			;输出DX内容
		
GO:
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示是否继续
		MOV	AH,07H
		INT		21H				;输入下一个任意键或“.”结束符->AL
		CMP		AL,'.'				;若输入的是结束符则结束，否则继续上述循环
		JNZ		INIT
		LEA		DX,TIP			
		MOV	AH,09H
		INT		21H				;提示任意键退出
ENDPROC:
		MOV AH,0AH
		INT 21H					;暂停
		MOV AX,4C00H
		INT 21H		
		
SHOW	PROC					;显示数字子程序，入口数字参数DX
		PUSH	AX
		PUSH	CX
		XOR		CX,CX
		MOV	AX,DX
		MOV	BL,10
GOTOT:							;循环进行十进制转换并压栈
		XOR		DX,DX
		DIV		BL
		PUSH	DL
		INC		CX
		CMP		AX,0
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
		
		POP		CX
		POP		AX
;		PUSH	DX				;保存DX
;		MOV	DL,DH
;		SHR		DL,1		
;		SHR		DL,1			
;		SHR		DL,1				
;		SHR		DL,1				;DL逻辑右移4位
;		ADD		DL,30H			;NUMBER->ASCII
;		CMP		DL,3AH			;if (DL < 3AH)	Print
;		JB		PRINTA
;		ADD		DL,27H
;PRINTA:	
;		PUSH	AX				;保存AX
;		MOV	AH,02H
;		INT		21H				;显示十位
;		POP		AX				;恢复AX
;		MOV	DL,DH
;		SHL		DL,1	
;		SHL		DL,1	
;		SHL		DL,1	
;		SHL		DL,1				;DL逻辑左移4位
;		SHR		DL,1	
;		SHR		DL,1	
;		SHR		DL,1	
;		SHR		DL,1				;DL逻辑右移4位，结果只保留个位数
;		ADD		DL,30H			;NUMBER->ASCII
;		CMP		DL,3AH			;if (DL < 3AH)	Print
;		JB		PRINTB
;		ADD		DL,27H
;PRINTB:	
;		PUSH	AX				;保存AX
;		MOV	AH,02H
;		INT		21H				;显示个位
;		POP		AX				;恢复AX
;		POP		DX				;恢复DX
		RET
SHOW 	ENDP
CODE ENDS  
END START