;设一个接口的输入端口地址为0100H，而它的状态端口地址
;显示信息“输入字符串，回车或空格结束”，空格或回车后显示输
;入字符串总字符数，数字字符（1-9）及非数字字符数。 
DATA SEGMENT
		TIP		DB	'输入字符串，回车或空格结束：',0DH,0AH,'$'
		TIPA		DB'字符总数：',0DH,0AH,'$'
		TIPB		DB数字字符数：',0DH,0AH,'$'
		TIPC		DB'非数字字符数：',0DH,0AH,'$'
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA,ES:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
		MOV	ES,AX			;初始化附加段寄存器
		LEA		DX,TIP
		MOV	AH,09H
		INT		21H				;输出提示字符串
INPCHK:
		MOV	AH,01H
		INT		21H				;输入字符，ASCII保存在AL中
		CMP		AL,20H
		JZ		INPEND			;若字符为空格则跳转到结束
		CMP		AL,0DH
		JZ		INPEND			;若字符为回车则跳转到结束
		CMP		AL,'1'
		JB		NONUM			;若ASCII小于'1'则跳转到NONUM
		CMP		AL,'9'
		JA		NONUM			;若ASCII大于'9'则跳转到NONUM
		INC		BL				;BL++
		JMP		INPCHK			;循环输入判断
NONUM:
		INC		BH				;BH++
		JMP		INPCHK			;返回继续循环输入判断
INPEND:
		LEA		DX,NL
		MOV	AH,09H
		INT		21H				;换行
SHOW:
		LEA		DX,TIPA
		MOV	AH,09H
		INT		21H				;显示TIPA
		MOV	AL,BL
		ADD		AL,BH			;BL+BH=总字符数
		DAA						;总字符数转为组合BCD
		MOV	CH,AL			;十进制低二位暂时保存在CH
		MOV	AL,AH
		MOV	CL,4
		CALL	OUTPUTNUM
		CALL	OUTPUTNUM
		MOV	AL,CH			;保存的十进制低二位恢复原位
		CALL	OUTPUTNUM
		CALL	OUTPUTNUM		;输出总字符数
		LEA		DX,TIPB
		MOV	AH,09H
		INT		21H				;显示TIPB
		MOV	AL,BL			;BL为数字数量
		XOR		AH,AH
		ADD		AL,0
		DAA						;数字数目转为组合BCD
		CALL	OUTPUTNUM
		CALL	OUTPUTNUM		;输出数字数目
		LEA		DX,TIPC
		MOV	AH,09H
		INT		21H				;显示TIPC
		MOV	AL,BH			;BH为数字数量
		XOR		AH,AH
		ADD		AL,0		
		DAA						;数字数目转为组合BCD
		CALL	OUTPUTNUM
		CALL	OUTPUTNUM		;输出数字数目
		
PUTNUM	PROC
		XOR		AH,AH
		SHL		AX,CL
		ADD		AH,30H
		MOV	DL,AH
		MOV	AH,02H
		INT		21H				;输出数字
		RET
OUTPUTNUM endp
		
CODE ENDS  
END START