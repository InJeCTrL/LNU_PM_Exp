;编写程序，使它相当于 TYPE 命令的功能，先由屏幕显示提示信
;息，再读取文件名（含路径），然后在屏幕上显示文件内容。 
;假设文件绝对路径设为C:\DATA.AAA
DATA SEGMENT
		TIPA		DB	'File Open Succeed!',0DH,0AH,'$'
		TIPB		DB	'File Open Failed!',0DH,0AH,'$'
		TIPC		DB	'File Read Succeed!',0DH,0AH,'$'
		TIPD		DB	'File Read Failed!',0DH,0AH,'$'
		TIPE		DB	'Return Value:','$'
		PATH	DB	'C:\DATA.AAA',00H
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器

		XOR		BL,BL			;BL清零
		
		MOV	AH,3DH
		LEA		DX,PATH			;DS:DX指向文件绝对路径字符串
		XOR		AL,AL			;只读打开
		INT		21H
		
		PUSH	AX				;保存AX
		ADC		BL,0				;BL = CF
		CMP		BL,00H			;if (BL  == 00H)
		JZ		OpS
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示文件打开失败
		LEA		DX,TIPE			
		MOV	AH,09H
		INT		21H				;返回值提示
		POP		AX				;恢复保存的AX
		MOV	DH,AL			;文件打开失败，显示错误号
		CALL	SHOW
		JMP		ENDPROC		;跳转到结束			

OpS:								;文件创建成功
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示文件打开成功
		POP		AX				;恢复保存的AX
		
Read:							;尝试读取文件
		MOV	BX,AX			;BX中存放句柄
		MOV	CX,200			;单次预定读出200字节
		MOV	DX,2000H		;指向目的缓冲区首
REPEATRD:
		XOR		SI,SI				;SI清零		
		MOV	AH,3FH
		INT		21H
		ADC		SI,0				;SI = CF
		CMP		SI,00H			;if (SI  != 00H)
		JNZ		RdF
		CMP		AX,00H			;若实际读取字节数为0
		JZ		BRK				;跳出
		ADD		DX,AX			;目的变址向后偏移相应字节数
		JMP		REPEATRD
BRK:
		MOV	DI,DX
		INC		DI
		MOV	BYTE PTR [DI],'$'	;结束符
		LEA		DX,TIPC			
		MOV	AH,09H
		INT		21H				;提示文件读取成功
		JMP		SHOWI
		
RdF:
		LEA		DX,TIPD			
		MOV	AH,09H
		INT		21H				;提示文件读取失败
		LEA		DX,TIPE			
		MOV	AH,09H
		INT		21H				;返回值提示
		MOV	DH,AL
		CALL	SHOW
		JMP		CLOSEH
		
SHOWI:							;输出文件内容
		MOV	DX,2000H
		MOV	AH,09H
		INT		21H				

CLOSEH:							;关闭文件句柄
		MOV	AH,3EH
		INT		21H
			
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