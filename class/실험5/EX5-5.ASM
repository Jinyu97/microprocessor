	PROCESSOR 16F876A

	INCLUDE <P16F876A.INC>

	DBUF1	EQU	20H
	DBUF2	EQU	21H

	VARIABLE KEY_DATA = 22H
	VARIABLE KEY_T 	  = 23H

		
	ORG	0000
	BSF	STATUS, RP0
	MOVLW	B'00000111'
	MOVWF	TRISA
	MOVWF	ADCON1
	MOVLW	B'00000000'
	MOVWF	TRISC
	BCF	STATUS, RP0
		
		
; MAIN

LP	
	CALL	KEY_IN
	MOVF	KEY_DATA, W
	CALL	CONV		; 숫자를 7-segment 값으로 변경
	MOVWF	PORTC		; 숫자 값 출력
	BSF	PORTA, 3	; 위치 결정
	CALL	DELAY
	BCF	PORTA, 3
	GOTO	LP

KEY_IN

	MOVLW	0FH		
	MOVWF	KEY_DATA	; 초기화	
	
	MOVLW	B'11110111'	; RC3=0, RC2,1,0=1
	MOVWF	PORTC
	CLRF	KEY_T

LP1
	CALL	READ_KEY	;key가 눌러짐 확인
	INCF	KEY_T,	F
	RRF	PORTC,	F
	BTFSC	STATUS,	C
	GOTO	LP1
	RETURN


; 스위치가 눌러짐 확인

READ_KEY	
	MOVF	PORTA,	W	; 스위치 읽기
	ANDLW	B'00000111'
	SUBLW	B'00000111'
	BTFSC	STATUS,	Z	; key 눌러짐 확인
	RETURN			; key가 눌러지지 않으면 그냥 RETURN
	
; key 값을 얻기 위한 TABLE ADDRESS 만듦

	MOVF	PORTA,	W
	MOVWF	KEY_DATA
	RLF	KEY_DATA, F
	RLF	KEY_DATA, W
	ANDLW	B'00011100'
	IORWF	KEY_T,	W
	CALL	KEY_TABLE
	MOVWF	KEY_DATA	; 눌러진 key의 변환 값 가져옴

	BSF	PORTA,	5	; BUZZER ON
	CALL	DELAY
	BCF	PORTA,	5	; BUZZER OFF
	
	RETURN
	
; key 값을 저장하는 TABLE -- 32개임

KEY_TABLE
	ADDWF	PCL,	F
	RETLW	0FH	; '000'+'00' 일 때
	RETLW	0FH	; '000'+'01' 일 때
	RETLW	0FH	; '000'+'10' 일 때
	RETLW	0FH	; '000'+'11' 일 때
	RETLW	0FH	; '001'+'00' 일 때
	RETLW	0FH	; '001'+'01' 일 때
	RETLW	0FH	; '001'+'10' 일 때
	RETLW	0FH	; '001'+'11' 일 때
	RETLW	0FH	; '010'+'00' 일 때
	RETLW	0FH	; '010'+'01' 일 때
	RETLW	0FH	; '010'+'10' 일 때
	RETLW	0FH	; '010'+'11' 일 때
	RETLW	01H	; '011'+'00' 일 때
	RETLW	04H	; '011'+'01' 일 때
	RETLW	07H	; '011'+'10' 일 때
	RETLW	0AH ; '011'+'11' 일 때 -- '*' code
;
	RETLW	0FH	; '100'+'00' 일 때
	RETLW	0FH	; '100'+'01' 일 때
	RETLW	0FH	; '100'+'10' 일 때
	RETLW	0FH	; '100'+'11' 일 때
	RETLW	02H	; '101'+'00' 일 때
	RETLW	05H	; '101'+'01' 일 때
	RETLW	08H	; '101'+'10' 일 때
	RETLW	00H	; '101'+'11' 일 때
	RETLW	03H	; '110'+'00' 일 때
	RETLW	06H	; '110'+'01' 일 때
	RETLW	09H	; '110'+'10' 일 때
	RETLW	0BH	; '110'+'11' 일 때 -- '#' code
	RETLW	0FH	; '111'+'00' 일 때
	RETLW	0FH	; '111'+'01' 일 때
	RETLW	0FH	; '111'+'10' 일 때
	RETLW	0FH	; '111'+'11' 일 때

	
CONV
	ANDLW	0FH		; W의 low nibble 값을 변환하자.
	ADDWF	PCL, F		; PCL+변환 숫자값 --> PCL
				; PC가 변경되므로 이 명령어 다음 수행 위치가 변경되지요.
	RETLW	B'00000011'	; '0'을 표시하는 값이 W로 들어모
	RETLW	B'10011111'	; '1'을 표시하는 값
	RETLW	B'00100101'	; '2'를 표시하는 값
	RETLW	B'00001101'	; '3'을 표시하는 값
	RETLW	B'10011001'	; '4'를 표시하는 값
	RETLW	B'01001001'	; '5'를 표시하는 값
	RETLW	B'01000001'	; '6'을 표시하는 값
	RETLW	B'00011011'	; '7'을 표시하는 값
	RETLW	B'00000001'	; '8'을 표시하는 값
	RETLW	B'00001001'	; '9'를 표시하는 값
	RETLW	B'11111101'	; '*'를 표시하는 값
	RETLW	B'01100011'	; '#'를 표시하는 값
	RETLW	B'11100101'	; 'C'를 표시하는 값
	RETLW	B'11111110'	; '.'를 표시하는 값
	RETLW	B'01100001'	; 'E'를 표시하는 값
	RETLW	B'01110001'	; 'F'를 표시하는 값

	
DELAY	
	MOVLW	.7		;130번을 확인하기 위한 변수
	MOVWF	DBUF1
LOOP1	MOVLW	.200		;200번을 확인하기 위한 변수
	MOVWF	DBUF2
LOOP2	NOP
	DECFSZ	DBUF2, F
	GOTO	LOOP2
	DECFSZ	DBUF1, F	;변수를 감소시켜 가면서 00이 되었나 확인
	GOTO	LOOP1		;ZERO가 아니면 여기에 들어옴
	RETURN
		
	END