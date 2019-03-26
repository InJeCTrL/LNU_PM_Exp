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
		
		MOV	DI,2000H
		MOV	AL,1AH
		MOV	BYTE PTR [DI],AL	;设置DS:2000H = 1AH
		
		XOR		BL,BL			;BL清零
		
		MOV	AH,3CH
		LEA		DX,FNAME		;DS:DX指向文件名字符串
		MOV	CX,00H			;创建文件
		INT		21H
		
		PUSH	AX				;保存AX
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
		CALL	SHOW
		JMP		ENDPROC		;跳转到结束			

CrtS:								;文件创建成功
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示文件创建成功
		POP		AX				;恢复保存的AX
		
Write:							;尝试写入文件
		MOV	BL,1AH
		XOR		CX,CX			;CX清零
		INC		CX				;CX初始为1
GETN:
		MOV	SI,1000H			;DS:SI->1000H
		CMP		[SI],BL			;if ([SI] != BL)
		JZ		GETOK			;跳出循环
		INC		CX				;CX++
		INC		SI				;SI++
		JMP		GETN		
GETOK:		
		MOV	BX,AX			;BX中存放句柄
		XOR		SI,SI				;SI清零		
		MOV	AH,40H
		MOV	DX,1000H		;指向缓冲区首
		INT		21H
		ADC		SI,0				;SI = CF
		CMP		SI,00H			;if (SI  == 00H)
		JZ		WrS
		LEA		DX,TIPD			
		MOV	AH,09H
		INT		21H				;提示文件创建失败
		LEA		DX,TIPE			
		MOV	AH,09H
		INT		21H				;返回值提示
		MOV	DH,AL
		CALL	SHOW
		JMP		ENDPROC
		
WrS:
		LEA		DX,TIPC			
		MOV	AH,09H
		INT		21H				;提示文件写入成功
		
		
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