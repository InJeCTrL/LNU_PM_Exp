;使用DEBUG 程序，从首址为1000H的内存区开始存放50个数，要求设计程序将这些数由小到大排序，排序后的数，仍放在该区域中。  
;假设数据源于 0000:0000H处开始的50个BYTE
DATA SEGMENT
		TIPA		DB	'Before Sorting:',0DH,0AH,'$'
		TIPB		DB	'After Sorting:',0DH,0AH,'$'
		NL		DB	0DH,0AH,'$'
DATA ENDS
CODE SEGMENT 
ASSUME CS:CODE,DS:DATA
START:
		MOV	AX,DATA
		MOV	DS,AX			;初始化数据段寄存器
		
		
		MOV	AX,0H
		MOV	ES,AX			;指定基址为0000H
		MOV	SI,0000H			;假设数据源于 0000:0000H处开始的50个BYTE
		MOV	DI,1000H			;目的内存区从DS:1000H开始
		
		LEA		DX,TIPA			
		MOV	AH,09H
		INT		21H				;提示以下为未排序的数据
		
		MOV	CX,50			;存放50个数
LOOPPUT:
		MOV	DH,BYTE PTR ES:[SI]
		MOV	BYTE PTR [DI],DH	;将当前指向的数写入目的内存区
		CALL	SHOW			;显示DH中储存的数字
		INC		SI				;目的指针++
		INC		DI				;源指针++
		LOOP	LOOPPUT
		
		MOV	AH,1			;AH作Flag位，指示是否已有序，此处Flag=1
SORT:							;冒泡排序过程
		CMP		AH,1
		JNZ		FINISH			;while(Flag == 1)
		MOV	AH,0			;Flag = 0
		MOV	CX,49			;for (i=0;i<49;i++)
		MOV	SI,1000H			;ES:SI->0000:1000H
		MOV	DI,1001H			;DS:DI->1444:1001H
SRTA:	CMP		CX,0
		JZ		SORT			;if (CX == 0) break;
		MOV	AL,BYTE PTR [SI]
		CMP		AL,BYTE PTR [DI]	;if (a[i]>a[i+1])
		JA		SWAPandFlag		;a[i]<->a[i+1];Flag = 1;
SRTB:	DEC		CX
		INC		SI				
		INC		DI				;两指针后移一位
		JMP		SRTA
SWAPandFlag:						;交换过程并置标志位
		MOV	BH,BYTE PTR [DI]
		MOV	BYTE PTR [SI],BH
		MOV	BYTE PTR [DI],AL
		MOV	AH,1			;Flag = 1
		JMP		SRTB
FINISH:							;排序结束
		LEA		DX,TIPB			
		MOV	AH,09H
		INT		21H				;提示以下为已排序的数据
		MOV	SI,1000H			;DS:SI->1000H
		MOV	CX,50
LOOPOUT:						;显示排序后结果
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
		CALL	TONORM
		MOV	AH,02H
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
		CALL	TONORM
		MOV	AH,02H
		INT		21H				;显示个位
		LEA		DX,NL			
		MOV	AH,09H
		INT		21H				;提示以下为已排序的数据
		RET
SHOW 	ENDP
TONORM	PROC
		CMP		DL,3AH			;if (DL > 3AH)
		JA		NORM			;JMP NORM
BK:	RET
TONORM ENDP
NORM:
		ADD		DL,27H
		JMP		BK
CODE ENDS  
END START