		PROCESSOR 16F876A
		#INCLUDE <P16F876A.INC>
		
; 변수 선언
		VARIABLE	W_TEMP		=	20H
		VARIABLE	STATUS_TEMP		=	21H
		VARIABLE	INT_CNT		=	22H
		VARIABLE	D_10SEC		=	23H
		VARIABLE	D_1SEC			=	24H
		VARIABLE	DISP_CNT		=	25H
		VARIABLE	COM_A			=	26H
		VARIABLE	COM_B			=	27H
		VARIABLE	D_10MIN		=	28H
		VARIABLE	D_1MIN		=	29H
		VARIABLE	DBUF1			=	30H
		VARIABLE	DBUF2			=	31H
		
; MAIN PROGRAM

	ORG		00H
	GOTO		START_UP
	ORG		04H
	
; ISR 시작 번지
	MOVWF	W_TEMP	 	; 현재 사용되고 있는 W REG를 저장
	SWAPF		STATUS,W
	MOVWF	STATUS_TEMP
	CALL  		DISP 			; DISPLAY 부 프로그램
	SWAPF 	STATUS_TEMP,W 	; 저장된 내용으로 복원
	MOVWF 	STATUS
	SWAPF 	W_TEMP,F
	SWAPF 	W_TEMP,W
	BCF 		INTCON,2
	RETFIE
	
; DISPLAY ROUTINE (DISP, DISPN, DISPM)
; DISP_CNT의 최하위 2자리가 00이면 DISP2로 이동
; DISP_CNT의 최하위 2자리가 01이면 DISP1로 이동
; DISP_CNT의 최하위 2자리가 10이면 DISP3으로 이동
; DISP_CNT의 최하위 2자리가 11이면 DISP4로 이동

DISP
	INCF	DISP_CNT
	BTFSS	DISP_CNT, 1
	GOTO	DISPM

DISPN
	BTFSS	DISP_CNT, 0 
	GOTO	DISP3
	GOTO	DISP4


DISPM
	BTFSS	DISP_CNT, 0
	GOTO	DISP2
	GOTO	DISP1
	

; 10초 단위
DISP1
	MOVLW	B'00000000'
	MOVWF	PORTA
	MOVWF	PORTC
	
	MOVF		D_10SEC, W
	CALL		CONV2
	MOVWF	PORTA
	MOVF		D_10SEC, W
	CALL		CONV1
	MOVWF	PORTC

	
	BSF		PORTA,3
	BSF 		PORTA,2
	BCF 		PORTB,2 		; DG3에 출력
	BSF		PORTB,1 
	
	RETURN
	
; 1초 단위 
DISP2
	MOVLW	B'00000000'
	MOVWF	PORTA
	MOVWF	PORTC
	
	MOVF		D_1SEC, W
	CALL		CONV2
	MOVWF	PORTA
	MOVF		D_1SEC, W
	CALL		CONV1
	MOVWF	PORTC
	
	BSF		PORTA,3
	BSF 		PORTA,2
	BSF 		PORTB,2
	BCF		PORTB,1		 ; DG4에 출력 
		
	INCF		INT_CNT
	
	RETURN	

; 1분 단위 	
DISP3
	MOVLW	B'00000000'
	MOVWF	PORTA
	MOVWF	PORTC
	
	MOVF		D_1MIN, W
	CALL		CONV2
	MOVWF	PORTA
	MOVF		D_1MIN, W
	CALL		CONV1
	MOVWF	PORTC

	
	BTFSS		INT_CNT, 7
	BSF		PORTA,0	
	
	
	BSF		PORTA,3
	BCF 		PORTA,2 		; DG2에 출력
	BSF 		PORTB,2
	BSF		PORTB,1	
	
	RETURN	
	
; 10분 단위	
DISP4
	MOVLW	B'00000000'
	MOVWF	PORTA
	MOVWF	PORTC
	
	MOVF		D_10MIN, W
	CALL		CONV2
	MOVWF	PORTA
	MOVF		D_10MIN, W
	CALL		CONV1
	MOVWF	PORTC


	BCF		PORTA,3 		; DG1에 출력 
	BSF 		PORTA,2
	BSF 		PORTB,2
	BSF		PORTB,1	
	
	INCF		INT_CNT

	RETURN	

	
		
; MAIN PROGRAM 시작
START_UP
	BSF 		STATUS,RP0		; RAM BANK 1 선택
	MOVLW 	B'00000000'		; PORT I/O 선택
	MOVWF 	TRISA
	MOVWF	TRISC
	MOVLW	B'11111001'
	MOVWF	TRISB
	MOVLW 	B'00000111'		; PORT I/O 선택
	MOVWF	ADCON1

; INTERRUPT 시간 설정 --- 2.048msec 주기
	MOVLW 	B'00000010'		; 2.048msec
	MOVWF 	OPTION_REG
	BCF 		STATUS,RP0		; RAM BANK 0 선택
	BSF 		INTCON,5 		; TIMER INTERRUPT ENABLE
	BSF 		INTCON,7 		; GLOBAL INT. ENABLE
	GOTO 		MAIN_ST

MAIN_ST					; 시작 시 초기화 
	CLRF		INT_CNT
	CLRF		D_10SEC
	CLRF		D_1SEC
	CLRF		D_10MIN
	CLRF		D_1MIN
	
M_LOOP
; interrupt가 들어온 횟수 확인(시간계수)
	MOVLW 	.244
	SUBWF 	INT_CNT,W
	BTFSS 		STATUS, Z
	GOTO 		XLOOP
; 1초마다 들어오는 부분
CK_LOOP
	CLRF 		INT_CNT 		; 다음 1초를 기다리기 위한 초기화
	INCF 		D_1SEC 		; 1초 단위 변수 증가
	MOVLW 	.10
	SUBWF 	D_1SEC,W
	BTFSS 		STATUS, Z
	GOTO 		XLOOP
; 10초마다 들어오는 부분
	CLRF 		D_1SEC 		; 다음 10초를 기다리기 위한 초기화
	INCF 		D_10SEC 		; 10초 단위 변수 증가
	MOVLW 	.6
	SUBWF 	D_10SEC,W
	BTFSS 		STATUS, Z
	GOTO 		XLOOP
; 1분마다 들어오는 부분
	CLRF		D_10SEC
	INCF 		D_1MIN		 ; 10초 단위 변수 증가
	MOVLW 	.10
	SUBWF 	D_1MIN,W
	BTFSS	 	STATUS, Z
	GOTO 		XLOOP
; 10분마다 들어오는 부분
	CLRF		D_1MIN
	INCF 		D_10MIN 		; 10초 단위 변수 증가
	MOVLW 	.6
	SUBWF 	D_10MIN,W
	BTFSC 		STATUS, Z
	CLRF 		D_10MIN		; 10초 단위를 초기화
	GOTO 		XLOOP

; 나머지 시간 동안 사용자 기능을 수행하기 위한 프로그램 영역

XLOOP						; Push button switch 입력 확인 
	BTFSC		PORTB, 5		; sw3이 눌리는 지 확인
	GOTO 		SWTEST1		; 눌리지 않으면 sw1이나 sw2가 눌리는지 확인하는 루프로 이동 
	GOTO 		SW3_RESET		; 눌리면 리셋하기 위한 루프로 이동 
	
SWTEST1					; Push button switch 1, 2의 입력 확인 
 	BTFSC		PORTB, 3		; sw1이 눌리는지 확인 
 	GOTO		M_LOOP		; 눌리지 않으면 계속 카운트 
 	GOTO 		SW1_STOP		; 눌리면 스톱워치 일시정지 루프로 이동 
	
	
SW3_RESET					; 리셋 루프 
	BCF		PORTA, 4 		; BUZZER ON
	GOTO		MAIN_ST		; 모든 변수 초기화 후 다시 동작

SW1_STOP					; 스톱워치 일시정지 루프  
 		;CALL	LED
 		BTFSC	PORTB, 4		; sw2가 눌리는지 확인
 		GOTO SW1_STOP		; 눌리지 않으면 일시정지 루프 반복
 		GOTO	XLOOP			; 눌리면 일시정지 해제 
 	
;LED
	;	MOVLW	B'00000000'
	;	MOVWF	PORTC
	;	BCF		PORTB, 7
	;	MOVLW	80H
	;	MOVWF	PORTC
	;	CALL		DELAY
	;	MOVLW	0BFH
	;	MOVWF	PORTC
	;	CALL		DELAY
	;	MOVLW	0DFH
	;	MOVWF	PORTC
	;	CALL		DELAY
		
		

	
CONV1 ;PORTC 
	ANDLW 	0FH 			; W의 low nibble 값을 변환
	ADDWF 	PCL,F 			; PCL+변환 숫자값 --> PCL
	RETLW 	B'11100111'		; '0'하는 값이 W로 들어옴
	RETLW 	B'01100000' 		; '1'를 표시 하는 값
	RETLW 	B'11000011' 		; '2'를 표시 하는 값
	RETLW 	B'11100010' 		; '3'를 표시 하는 값
	RETLW 	B'01100100' 		; '4'를 표시 하는 값
	RETLW 	B'10100110' 		; '5'를 표시 하는 값
	RETLW 	B'00100111' 		; '6'를 표시 하는 값
	RETLW 	B'11100100' 		;7'를 표시 하는 값
	RETLW 	B'11100111' 		; '8'를 표시 하는 값
	RETLW 	B'11100100' 		; '9'를 표시 하는 값
	RETLW 	B'00000010' 		; '-'를 표시 하는 값
	RETLW 	B'00000000' 		; ' '를 표시 하는 값
	RETLW 	B'00011010' 		; 'C'를 표시 하는 값
	RETLW 	B'00000000' 		; '．'를 표시 하는 값
	RETLW 	B'10011110' 		; 'E'를 표시 하는 값
	RETLW 	B'10001110' 		; 'F'를 표시 하는 값
	
CONV2 ;PORTA
	ANDLW 	0FH 			; W의 low nibble 값을 변환하자.
	ADDWF 	PCL,F 			; PCL+변환 숫자값 --> PCL
	RETLW 	B'00010000' 		; '0'를 표시 하는 값이 W로 들어옴
	RETLW 	B'00010000' 		; '1'를 표시 하는 값
	RETLW 	B'00010010' 		; '2'를 표시 하는 값
	RETLW 	B'00010010' 		; '3'를 표시 하는 값
	RETLW 	B'00010010' 		; '4'를 표시 하는 값
	RETLW 	B'00010010' 		; '5'를 표시 하는 값
	RETLW 	B'00010010' 		; '6'를 표시 하는 값
	RETLW 	B'00010000' 		; '7'를 표시 하는 값
	RETLW 	B'00010010' 		; '8'를 표시 하는 값
	RETLW 	B'00010010' 		; '9'를 표시 하는 값
	RETLW 	B'00010010' 		; '-'를 표시 하는 값
	RETLW 	B'00010000' 		; ' '를 표시 하는 값
	RETLW 	B'00011010' 		; 'C'를 표시 하는 값
	RETLW 	B'00010001' 		; '．'를 표시 하는 값
	RETLW 	B'10011110' 		; 'E'를 표시 하는 값
	RETLW 	B'10011110' 		; 'F'를 표시 하는 값



DELAY	; DELAY 서브루틴						
		MOVLW	.125
		MOVWF	DBUF1
LP1		MOVLW	.200
		MOVWF	DBUF2
LP2		NOP
		DECFSZ	 	DBUF2,F
		GOTO		LP2
		DECFSZ		DBUF1,F
		GOTO		LP1
		RETURN		
	
END