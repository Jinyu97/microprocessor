		PROCESSOR 16F876A

		#INCLUDE <P16F876A.INC>


; ---변수선언---

		VARIABLE	DBUF1	=	20H
		VARIABLE	DBUF2	=	21H
		VARIABLE	DISP1	=	22H
		VARIABLE	DISP2	=	23H
		VARIABLE	DISP3	=	24H
		VARIABLE	DISP4	=	25H



		ORG	0000
		BSF	STATUS, RP0
		MOVLW	B'00000000'
		MOVWF	TRISA
		MOVLW	B'00000000'
		MOVWF	TRISC
		MOVLW	B'00000111'
		MOVWF	ADCON1
		BCF	STATUS, RP0

; MAIN PROGRAM

		MOVLW	01H		; 1
		MOVWF	DISP1
		MOVLW	12H		; 2
		MOVWF	DISP2
		MOVLW	23H		; 3
		MOVWF	DISP3
		MOVLW	34H		; 4
		MOVWF	DISP4

				

D_LOOP		
		MOVF	DISP1,	W
		CALL	CONV1		; CALL CONV
		MOVWF	PORTC		; 숫자 값 출력
		SWAPF	DISP1, 	W
		CALL	CONV2		
		MOVWF	PORTA		; 위치 결정 (DG1 선택)
		CALL	DELAY		; 이 DELAY는 시간이 약 5ms가 되도록

		MOVLW	0
		MOVWF	PORTA		; 전부 OFF

		MOVF	DISP2, W
		CALL	CONV1	 	; CALL CONV
		MOVWF	PORTC		; 숫자 값 출력
		SWAPF	DISP2, 	W
		CALL	CONV2		
		MOVWF	PORTA		; 위치 결정 (DG2 선택)
		CALL	DELAY		; 이 DELAY는 시간이 약 5ms가 되도록

		MOVLW	0
		MOVWF	PORTA		; 전부 OFF

		MOVF	DISP3,	W
		CALL	CONV1		; CALL CONV
		MOVWF	PORTC		; 숫자 값 출력
		SWAPF	DISP3, 	W
		CALL	CONV2
		MOVWF	PORTA		; 위치 결정 (DG3 선택)
		CALL	DELAY		; 이 DELAY는 시간이 약 5ms가 되도록

		MOVLW	0
		MOVWF	PORTA		; 전부 OFF

		MOVF	DISP4, W
		CALL	CONV1		; CALL CONV		 
		MOVWF	PORTC		; 숫자 값 출력
		SWAPF	DISP4, 	W
		CALL	CONV2
		MOVWF	PORTA		; 위치 결정 (DG4 선택)
		CALL	DELAY		; 이 DELAY는 시간이 약 5ms가 되도록

		MOVLW	0
		MOVWF	PORTA		; 전부 OFF

		GOTO	D_LOOP
		
CONV1
	   	ANDLW	0FH		; W의 low nibble 값을 변환하자.
		ADDWF	PCL, F		; PCL+변환 숫자값 --> PCL
					; PC가 변경되므로 이 명령어 다음 수행 위치가 변경되지요.
		RETLW	B'00000011'	; '0'을 표시하는 값
		RETLW	B'10011111'	; '1'을 표시하는 값
		RETLW	B'00100101'	; '2'를 표시하는 값
		RETLW	B'00001101'	; '3'을 표시하는 값
		RETLW	B'10011001'	; '4'를 표시하는 값
		RETLW	B'01001001'	; '5'를 표시하는 값
		RETLW	B'01000001'	; '6'을 표시하는 값
		RETLW	B'00011011'	; '7'을 표시하는 값
		RETLW	B'00000001'	; '8'을 표시하는 값
		RETLW	B'00001001'	; '9'를 표시하는 값
		RETLW	B'11111101'	; '-'를 표시하는 값
		RETLW	B'11111111'	; ' '를 표시하는 값
		RETLW	B'11100101'	; 'C'를 표시하는 값
		RETLW	B'11111110'	; '.'를 표시하는 값
		RETLW	B'01100001'	; 'E'를 표시하는 값
		RETLW	B'01110001'	; 'F'를 표시하는 값
		
CONV2
	   	ANDLW	03H		; W의 low nibble 값을 변환하자.
		ADDWF	PCL, F		; PCL+변환 숫자값 --> PCL
					; PC가 변경되므로 이 명령어 다음 수행 위치가 변경되지요.
		RETLW	B'00000001'	; 첫째자리 표시
		RETLW	B'00000010'	; 둘째자리 표시
		RETLW	B'00000100'	; 셋째자리 표시
		RETLW	B'00001000'	; 넷째자리 표시


; SUBROUTINE (5ms delay routine)

DELAY	
		MOVLW	.7		; 7번을 확인하기 위한 변수
		MOVWF	DBUF1
LP1		MOVLW	.200		; 200번을 확인하기 위한 변수
		MOVWF	DBUF2
LP2		NOP
		DECFSZ	DBUF2, F
		GOTO	LP2
		DECFSZ	DBUF1, F	; 변수를 감소시켜 가면서 00이 되었나 확인
		GOTO	LP1		; ZERO가 아니면 여기에 들어옴
		RETURN
		
		END
