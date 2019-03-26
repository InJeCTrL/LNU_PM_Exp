;编写程序，将内存区域中用DEBUG程序设置好的一连串数据，以
;ASCII 码1AH 为结束符作为一个文件，存入磁盘，文件名为DATA.AAA。  
;假设内存中的数据起始地址已设置为DS:1000H，并将DS:2000H处设置为结束符
DATA SEGMENT
		TIPA		DB	'File Create Succeed!',0DH,0AH,'$'
		TIPB		DB	'File Create Failed!',0DH,0AH,'$'
		TIPC		DB	'File Write Succeed!',0DH,0AH,'$'
		TIPD		DB	'File Write Failed!',0DH,0AH,'$'
		TIPE		DB	'Return Value:','$'
		FNAME	DB	'DATA.AAA',00H
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
		
		MOV	DX,2000H
		MOV	AL,1AH
		MOV	BYTE PTR [DX],AL	;设置DS:2000H = 1AH
		
		MOV	AH,3CH
		LEA		DX,FNAME		;DS:DX指向文件名字符串
		MOV	CX,00H			;创建文件
		INT		21H
		
		PUSH	AX				;保存AX
		XOR		BL,BL			;BL清零
		ADC		BL,0				;BL = CF
		CMP		BL,00H			;if (BL  == 00H)
		JZ		CrtS
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示文件创建失败
		LEA		DX,TIPE			
		MOV	AH,09H
		INT		21H				;返回值提示
		POP		AX				;恢复保存的AX
		MOV	DH,AL			;文件创建失败，显示错误号
		JMP		ENDPROC		;跳转到结束			

CrtS:								;文件创建成功
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示文件创建成功
		POP		AX				;恢复保存的AX
		
Write:							;尝试写入文件
GETN:
		XOR		CX,CX			;CX清零
		MOV	SI,1000H			;DS:SI->1000H
		CMP		[SI],1AH
		
		MOV	BX,AX			;BX中存放句柄
		MOV	AH,40H
		

		
		
		
		
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
		CMP		CX,0				;if (CX == 0)
		JNZ		REST			;转回循环中
		JMP		CALC
RETRY:
		LEA		DX,TIPERR			
		MOV	AH,09H
		INT		21H				;提示以重新输入上一个数据
		MOV	BL,0				;临时存储区清零
		JMP		LOOPINPUT		;重新输入
		
CALC:
		
		MOV	DH,0			;源地址偏移初始为0
		MOV	DI,2000H			;DS:DI->DS:2000H
ALLRANK:						;计算所有学生排名
		MOV	AL,1				;AL保存临时排名，初始为1
		MOV	SI,1000H			;DS:SI->DS:1000H
		MOV	BX,SI
		ADD		BL,DH
		MOV	AH,BYTE PTR [BX]	;AH保存待计算排名的成绩
		MOV	CL,10			;计算10个排名
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
		INC		DH				;源地址偏移++
		CMP		DH,0AH			;if (CH<10)
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