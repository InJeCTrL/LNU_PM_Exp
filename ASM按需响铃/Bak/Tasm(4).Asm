;从键盘按收输入字符,如是数字N,则响铃N次,如不是数字或数字是0,则不响。 
DATA SEGMENT
		TIP		DB	'Input a number(1~9)',0DH,0AH,'$'
		TIPE		DB	'Press any key to exit',0DH,0AH,'$'
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
INPCHK:
		LEA		DX,TIP
		MOV	AH,09H
		INT		21H				;输出提示字符串
		MOV	AH,01H
		INT		21H				;输入字符，ASCII保存在AL中
		CMP		AL,20H
		JZ		INPEND			;若字符为空格则跳转到结束
		CMP		AL,0DH
		JZ		INPEND			;若字符为回车则跳转到结束
		CMP		AL,'1'
		JB		INPCHK			;若ASCII小于'1'则跳转到INPCHK重新输入
		CMP		AL,'9'
		JA		INPCHK			;若ASCII大于'9'则跳转到INPCHK重新输入
		MOV	AH,02H
		MOV	DL,07H
		INT		21H				;响铃
		JMP		INPCHK			;循环输入判断
INPEND:
		LEA		DX,TIPE
		MOV	AH,09H
		INT		21H				;换行
ENDPROC:
		MOV AH,0AH
		INT 21H					;暂停
		MOV AX,4C00H
		INT 21H		
CODE ENDS  
END START