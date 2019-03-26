;检索目录应先使用 INT21H 的 4EH 号调用，它将检索到第一个匹
;配的文件，然后不断的使用 INT21H 的 4FH 号调用，检索下一个匹配
;文件，这就能实现DIR 功能。以上两个子功能均能识别文件名通配符
;‘？’和‘#’。 

DATA SEGMENT  
		TIPA		DB		'FILE DIR:',0DH,0AH,'$'
		DTA		DB		128 DUP(?)						;DTA
		FNAME	DB		'*.*',0							;查找所有类型文件
		TIPB		DB		'END!Press Any Key To Exit!',0DH,0AH,'$'
		NL		DB 		0DH,0AH,'$'
DATA ENDS  

CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器

		LEA		DX,DTA
		MOV	AH,1AH
		INT		21H				;设置DTA

		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示将输出文件列表
		
		MOV	AH,4EH
		XOR		CX,CX
		LEA		DX,FNAME		;查找所有类型文件
		INT		21H
		
		ADC		BX,0				;BX判断CF == 1，BX = CF
		CMP		BX,0				;判断CF == 1，若为1则出错，跳转到结尾
		JNZ		Q				;若读取第一个文件出错则直接跳转到结尾

OUTN:							;输出文件名过程
		LEA		DI,DTA			;得到DTA基址
		ADD		DI,2BH			;定位DI到文件名字符串结尾之后
		MOV	AL,'$'
		MOV	[DI],AL			;文件名字符串之后使用结束标志截断
		LEA		DX,DTA			;DX赋予DTA基址
		ADD		DX,1EH			;DX定位到文件名字符串base		
		MOV	AH,09H
		INT		21H				;输出一条文件名
		
		XOR		BX,BX			;BX用于判断CF，先清空
		MOV	AH,4FH
		ADC		BX,0				;BX = CF
		CMP		BX,0				;判断CF == 1，若为0则继续寻找下一个文件
		JNZ		OUTN			;跳转到输出文件名
		
Q:								;程序结束前提示
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示将输出文件列表
		
		
ENDPROC:
		MOV AH,0AH
		INT 21H					;暂停
		MOV AX,4C00H
		INT 21H		
CODE ENDS  
END START