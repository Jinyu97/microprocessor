	PROCESSOR 16F876A

	#INCLUDE <P16F876A.INC>

; ---변수 선언---

VARIABLE DBUF1  = 20H
VARIABLE DBUF2  = 21H
VARIABLE DBUF3  = 22H
VARIABLE COM_B  = 23H
VARIABLE COM_C  = 24H
VARIABLE BUFFER	= 25H		; 다른 변수와 주소가 중복되지 않게 큰 주소를 사용할 것
		

	ORG	0000
	BSF	STATUS, RP0
	MOVLW	B'00000000'
	MOVWF	TRISA
	BCF	STATUS, RP0
	
		

; 예7) 부 프로그램 LCD_OUT을 이용하여 글자 표시하기

	; 표시글자: ' I LOVE 1'
	; 앞부분, 변수설정 등은 당연히 필요하지요.
	; 그리고 서로 중복되지 않게 설정해야 됩니다.

	
	; 데이터 buffer에 글자를 넣는 프로그램

	MOVLW	' '
	MOVWF	BUFFER
	MOVLW	'I'
	MOVWF	BUFFER+1
	MOVLW	' '
	MOVWF	BUFFER+2
	MOVLW	'L'
	MOVWF	BUFFER+3
	MOVLW	'O'
	MOVWF	BUFFER+4
	MOVLW	'V'
	MOVWF	BUFFER+5
	MOVLW	'E'
	MOVWF	BUFFER+6
	MOVLW	' '
	MOVWF	BUFFER+7
	MOVLW	'1'
	MOVWF	BUFFER+8
	MOVLW	00		; end code
	MOVWF	BUFFER+9

	MOVLW	0A3H		; 화면 클리어
	MOVWF	COM_B
	CALL	RS232C
	CALL	DELAY
	
	MOVLW	1
	MOVWF	COM_B
	CALL	RS232C
	CALL	DELAY

; 데이터 buffer에 들어 있는 내용을 출력하는 부분	
	
	MOVLW	BUFFER		; initialize pointer의 초기값
	MOVWF	FSR		; 초기값을 initialize pointer에 넣음
	CALL	LCD_OUT
BBLP	GOTO	BBLP		; 프로그램 종료


;-----------------------------------------------------------

RS232C	MOVLW	8
	MOVWF	COM_C
	BCF	PORTA, 0	; start bit=0
	CALL	DELAYB
; 데이터 출력 LOOP
R_LP	BTFSS	COM_B, 0
	GOTO	BITX
	; 0 bit =1
	BSF	PORTA, 0
	GOTO	NEXT1
BITX	BCF	PORTA, 0
NEXT1	CALL	DELAYB
; 다음 데이터 만들기 및 마지막 확인
	RRF	COM_B, F
	DECFSZ	COM_C
	GOTO	R_LP
; stop bit 출력
	BSF	PORTA, 0
	CALL	DELAYB
	RETURN

;-----------------------------------------------------------

LCD_OUT
	; String 데이터를 출력하기 위한 시작 코드 출력
	MOVLW	0A2H
	MOVWF	COM_B
	CALL	RS232C
NEX	MOVF	INDF, W		; buffer의 내용을 W로 옮김
	MOVWF	COM_B		; W를 통신 출력 변수로 이동
	CALL	RS232C
	CALL	DELAYB		; 안정된 동작을 위한 지연시간
	; 마지막을 확인함
	MOVF	INDF, W		; buffer의 내용을 W로 옮김
	BTFSC	STATUS, ZF	; '00' 인가 확인
	RETURN
	INCF	FSR, F		; inc pointer
	GOTO	NEX

;-----------------------------------------------------------

;--- BAUD-RATE DELAY ---
;--- 208USEC DELAY   ---

DELAYB
	MOVLW		.51
	MOVWF		DBUF1
LP1
	NOP
	DECFSZ		DBUF1, F
	GOTO		LP1
	
	RETURN



;--- LONG DELAY FOR LCD COMMAND   ---
		
DELAY
	MOVLW		0FFH
	MOVWF		DBUF2
LP2
	MOVLW		05H
	MOVWF		DBUF3
LP3
	NOP
	DECFSZ		DBUF3, F
	GOTO		LP3
	DECFSZ		DBUF2, F
	GOTO		LP2
	
	RETURN
	
	END