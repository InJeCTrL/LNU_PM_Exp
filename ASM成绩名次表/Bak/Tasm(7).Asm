;根据提示将 0~100 之间的 10 个成绩存入首址为 1000H 的单元，
;1000H+ⅰ表示学号为ⅰ的学生成绩，编写程序能在2000H开始的区域
;排出名次表，2000H+ⅰ为学生号ⅰ的学生的名次，并将其显示在屏幕。 
DATA SEGMENT
		TIPA		DB	'Input 10 Marks:','$'
		TIPB		DB	'Rank List:',0DH,0AH,'$'
		TIPERR	DB	'Latest Number Is Bigger Than 100!Retry!',0DH,0AH,'$'
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
		
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示输入10个成绩数据
		
		MOV	DI,1000H			;DS:DI->1444:1000H
		MOV	CX,10
		MOV	BL,0				;临时存储区清零
LOOPINPUT:						;循环10次输入10个成绩
		MOV	AH,01H
		INT		21H				;输入成绩数字字符
		CMP		AL,3AH			;if (AL <'A')
		JB		CHKA			;符合要求则将数字存进缓冲区
		JMP		NEXTP			;否则准备输入下一个成绩
CHKA:	
		CMP		AL,30H			;if (AL>='0')
		JAE		CHKB
		JMP		NEXTP			;否则准备输入下一个成绩
CHKB:
		SUB		AL,30H			;ASCII->NUMBER
		MOV	BH,AL			;保存AL
		MOV	AL,10			
		MUL		BL				;已在缓冲区的高位*10
		MOV	BL,AL
		MOV	AL,BH			;恢复AL
		ADD		BL,AL			;输入的数字进入临时存储区
REST:	
		JMP		LOOPINPUT
		JMP		CALC			;跳转到计算排序
NEXTP:
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;换行
		CMP		BL,100			;if (BL >100)
		JA		RETRY
		MOV	BYTE PTR [DI],BL	;存入DS:1000H处
		INC		DI				;DI++
		DEC		CX				;计数器--
		MOV	BL,0				;临时存储区清零
		JMP		REST			;转回循环中
RETRY:
		LEA		DX,TIPERR			
		MOV	AH,09H
		INT		21H				;提示以重新输入上一个数据
		MOV	BL,0				;临时存储区清零
		JMP		LOOPINPUT		;重新输入
		
CALC:
		MOV	SI,1000			;DS:SI->DS:1000H
		MOV	DI,2000			;DS:DI->DS:2000H
		
		MOV	CH,0				;源地址偏移初始为0
ALLRANK:						;计算所有学生排名
		MOV	CL,10			;计算10个排名
		MOV	AL,1				;AL保存临时排名，初始为1
		MOV	BX,1000H
		ADD		BL,CH
		MOV	AH,BYTE PTR [BX]	;AH保存待计算排名的成绩
GETRANK:						;排序获得排名过程
		CMP		AH,BYTE PTR [SI]	;if (AH<[SI])
		JB		ADDRANK
		JMP		NEXTM
ADDRANK:
		INC		AL				;临时排名++
NEXTM:
		INC		SI				;游标后移
		LOOP	GETRANK
		MOV	BYTE PTR[DI],AL	;DS:DI处填入排名
		INC		DI				;目的游标后移
		INC		CH				;源地址偏移++
		CMP		CH,0AH			;if (CH<10)
		JB		ALLRANK

		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;开始输出排名表
		MOV	CX,10
		MOV	SI,2000H
LOOPOUT:						;显示排名后结果
		MOV	DH,BYTE PTR [SI]
		CALL	SHOW
		INC		SI
		LOOP	LOOPOUT
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
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;提示以下为已排序的数据
		RET
SHOW 	ENDP
CODE ENDS  
END START