;编写计算N！的程序。数值 N由键盘输入，结果在屏幕上输出，
;N 的范围为0～65535，即刚好能被一个16 位寄存器容纳。 
;编制附乘程序的难点在于随着N 的增大，共结果远不是寄存器所
;能容纳。这就必须把结果放在一个内存缓冲区中。然而乘法运算只能
;限制于两个字相乘，因此要确定好算法，依次从缓冲区中取数，进行
;两字相乘，并将DX中的高16 位积作为产生的进位。程序根据阶乘的
;定义：N！=N*（N-1）*（N-2）*…*2*1，从左入右依次计算，结果首
;先将BP 初始化为存放 N 值，然后使BP为N-1，以后BP 依次减 1，直
;至变化为 1。每次让 BP 与 BUF 中的字单元按由低到高的次序相乘，
;低位结果AX仍保存在相应的BUF 字单元中，最高位结果 DX 则进到进
;位这单元CY中，以作为高字单元相乘时从低字来的进位，初始化CY
;为0，计算结果的长度随着乘积运算而不断增长，由字单元 LEN 指示。
;当最高字单元与BP相乘时，若DX 不为0，则结果长度要扩展。 

;---------------------------------Introduce-----------------------------------
;		预设DS:2000H存放累乘的中间结果与最终结果（倒序）
;
;
;				    输出时也使用上述地址
;--------------------------------------------------------------------------------
DATA SEGMENT  
		TIPA		DB 		'N!',0DH,0AH,'Input N:','$'
		TIPERR	DB		'Overflow Or Not A Right Number!Retry!',0DH,0AH,'$'
		NL		DB 		0DH,0AH,'$'
DATA ENDS  

CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
		
		MOV	BX,0000H
		MOV	DI,2000H
		MOV	CX,0FFFH
LOOPCR:
		MOV	[DI],BX			;清空操作
		INC		DI
		LOOP	LOOPCR
		
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示输入N
		
		XOR		BX,BX			;乘数存储区清零
LOOPINPUT:						;输入数字，保存到BX中
		MOV	AH,01H
		INT		21H				;输入数字字符
		CMP		AL,30H			;if (AL>='0')
		JAE		CHKA			;符合要求则将数字存进缓冲区
		JMP		CALC			;否则认为乘数输入完毕
CHKA:							;检查是否是正常数字字符
		CMP		AL,3AH			;if (AL <'A')
		JB		FILL				;确认是数字则开始数字装填
		JMP		RETRY			;否则重试
FILL:
		SUB		AL,30H			;ASCII->NUMBER
		XOR		CX,CX
		MOV	CL,AL			;保存AL->CL
		MOV	AX,10			
		MUL		BX				;已在乘数缓冲区的高位*10
		ADD		AX,CX			;输入的数字进入临时存储区
		MOV	BX,AX
		JC		RETRY			;乘数BX溢出
		JMP		LOOPINPUT
RETRY:
		LEA		DX,TIPERR			
		MOV	AH,09H
		INT		21H				;提示数据不合法
		XOR		BX,BX			;乘数存储区清零
		JMP		LOOPINPUT		;重新输入

CALC:
		MOV	SI,2000H			;SI清2000H，用于保存结果串结束地址
		MOV	BP,BX			;乘数转移到BP中
		MOV	DI,2000H
		MOV	[DI],BP			;第一个被乘数赋值
NEXTMULA:
		MOV	DI,2000H			;被乘数重定位
		XOR		DX,DX
		PUSH	DX				;初始之前数进位为0并进栈
		DEC		BP				;乘数初值比被乘数少1
		CMP		BP,1				;检测乘数是否减到1
		JZ		CLR
MULA:
		MOV	AX,[DI]			;读取内存当前数
		MUL		BP				;AX*BP
		MOV	[DI],AX			;[DI] = AX，当前数低位进内存
		POP		CX
		PUSH	DX
		MOV	DX,CX			;栈中存放的之前数的进位与本次运算产生的进位换位DX<->[SP]
		ADD		[DI],DX			;当前数加上之前数的进位
		INC		DI
		INC		DI				;跳转到下一单元
		MOV	BX,00H
		CMP		[DI],BX			;若下一单元为空，则本单元为最高单元
		JNZ		MULA			;若不为最高单元，计算本单元
		POP		DX				;本次进位DX出栈
		CMP		DX,00H			;若最高单元进位为0
		JZ		NMU
		INC		SI				
		INC		SI				;记录结尾
		ADD		[DI],DX
NMU:	JMP		NEXTMULA

CLR:
		POP		DX				;临时结果退栈

SHOWNUM:
		INC		SI				
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;换行
LOOPA:
		MOV	DH,BYTE PTR[SI]
		CALL	SHOW
		DEC		SI
		CMP		SI,2000H			;SI指向大于等于2000H则继续
		JAE		LOOPA

ENDPROC:
		MOV AH,0AH
		INT 21H					;暂停
		MOV AX,4C00H
		INT 21H		
		
SHOW	PROC					;显示数字子程序，入口数字参数DH
		MOV	DL,DH
		SHR		DL,1		
		SHR		DL,1			
		SHR		DL,1				
		SHR		DL,1				;DL逻辑右移4位
		ADD		DL,30H			;NUMBER->ASCII
		CMP		DL,3AH			;if (DL < 3AH)	Print
		JB		PRINTA
		ADD		DL,27H
PRINTA:	MOV	AH,02H
		INT		21H				;显示十位
		MOV	DL,DH
		SHL		DL,1	
		SHL		DL,1	
		SHL		DL,1	
		SHL		DL,1				;DL逻辑左移4位
		SHR		DL,1	
		SHR		DL,1	
		SHR		DL,1	
		SHR		DL,1				;DL逻辑右移4位，结果只保留个位数
		ADD		DL,30H			;NUMBER->ASCII
		CMP		DL,3AH			;if (DL < 3AH)	Print
		JB		PRINTB
		ADD		DL,27H
PRINTB:	MOV	AH,02H
		MOV	AH,02H
		INT		21H				;显示个位
		RET
SHOW 	ENDP
CODE ENDS  
END START