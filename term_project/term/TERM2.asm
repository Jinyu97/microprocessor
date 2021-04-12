		PROCESSOR 16F876A
		#INCLUDE <P16F876A.INC>
		
; ���� ����
		VARIABLE	W_TEMP		=	20H
		VARIABLE	STATUS_TEMP	=	21H
		VARIABLE	INT_CNT		=	22H
		VARIABLE	D_10SEC		=	23H
		VARIABLE	D_1SEC		=	24H
		VARIABLE	DISP_CNT	=	25H
		VARIABLE	COM_A		=	26H
		VARIABLE	COM_B		=	27H
		VARIABLE	D_10MIN		=	28H
		VARIABLE	D_1MIN		=	29H
		VARIABLE	DBUF1		=	30H
		VARIABLE	DBUF2		=	31H
		
; MAIN PROGRAM

	ORG		00H
	GOTO	START_UP
	ORG		04H
	
; ISR ���� ����
	MOVWF	W_TEMP ; ���� ���ǰ� �ִ� W REG�� ����
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP
	CALL  	DISP ; DISPLAY �� ���α׷�
	SWAPF 	STATUS_TEMP,W ; ����� �������� ����
	MOVWF 	STATUS
	SWAPF 	W_TEMP,F
	SWAPF 	W_TEMP,W
	BCF 	INTCON,2
	RETFIE
	
; DISPLAY ROUTINE
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
	

; ó�� ���� ��	
DISP1
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_10SEC, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00000010'
	MOVWF	PORTA
	
	RETURN
	
; ���� ���� ��
DISP2
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_1SEC, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00000001'
	MOVWF	PORTA	
	
	INCF	INT_CNT

	RETURN	
	
DISP3
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_1MIN, W
	CALL	CONV
	MOVWF	PORTC
	
	BTFSS		INT_CNT, 7
	BCF			PORTC, 0	
	
	
	
	MOVLW	B'00000100'
	MOVWF	PORTA	
	
	RETURN	
	
DISP4
	MOVLW	B'00000000'
	MOVWF	PORTA
	
	MOVF	D_10MIN, W
	CALL	CONV
	MOVWF	PORTC
	
	MOVLW	B'00001000'
	MOVWF	PORTA	
	
	INCF	INT_CNT

	RETURN	
	
; MAIN PROGRAM ����
START_UP
	BSF 	STATUS,RP0 ; RAM BANK 1 ����
	MOVLW 	B'00000000' ; PORT I/O ����
	MOVWF 	TRISA
	MOVWF	TRISC
	MOVLW 	B'00000111' ; PORT I/O ����
	MOVWF	ADCON1

; INTERRUPT �ð� ���� --- 2.048msec �ֱ�
	MOVLW 	B'00000010' ; 2.048msec
	MOVWF 	OPTION_REG
	BCF 	STATUS,RP0 ; RAM BANK 0 ����
	BSF 	INTCON,5 ; TIMER INTERRUPT ENABLE
	BSF 	INTCON,7 ; GLOBAL INT. ENABLE
	GOTO 	MAIN_ST

MAIN_ST
	CLRF	INT_CNT
	CLRF	D_10SEC
	CLRF	D_1SEC
	CLRF	D_10MIN
	CLRF	D_1MIN
	
M_LOOP
; interrupt�� ���� Ƚ�� Ȯ��(�ð����)
	MOVLW 	.244
	SUBWF 	INT_CNT,W
	BTFSS 	STATUS, Z
	GOTO 	XLOOP
; 1sec ���� ������ �κ�
CK_LOOP
	CLRF 	INT_CNT ; ���� 1�ʸ� ��ٸ��� ���� �ʱ�ȭ
	INCF 	D_1SEC ; 1�� ���� ���� ����
	MOVLW 	.10
	SUBWF 	D_1SEC,W
	BTFSS 	STATUS, Z
	GOTO 	XLOOP
; 10�ʸ��� ������ �κ�
	CLRF 	D_1SEC ; ���� 10�ʸ� ��ٸ��� ���� �ʱ�ȭ
	INCF 	D_10SEC ; 10�� ���� ���� ����
	MOVLW 	.6
	SUBWF 	D_10SEC,W
	BTFSS 	STATUS, Z
;	CLRF 	D_10SEC ; 10�� ������ �ʱ�ȭ
	GOTO 	XLOOP
; 1�и��� ������ �κ�
;	CLRF 	D_1SEC ; ���� 10�ʸ� ��ٸ��� ���� �ʱ�ȭ
	CLRF	D_10SEC
	INCF 	D_1MIN ; 10�� ���� ���� ����
	GOTO	LEDLP
LEDLPR
	MOVLW 	.10
	SUBWF 	D_1MIN,W
	BTFSS 	STATUS, Z
;	CLRF 	D_1MIN ; 10�� ������ �ʱ�ȭ
	GOTO 	XLOOP
; 10�и��� ������ �κ�
;	CLRF 	D_1SEC ; ���� 10�ʸ� ��ٸ��� ���� �ʱ�ȭ
;	CLRF	D_10SEC
	CLRF	D_1MIN
	INCF 	D_10MIN ; 10�� ���� ���� ����
	MOVLW 	.6
	SUBWF 	D_10MIN,W
	BTFSC 	STATUS, Z
	CLRF 	D_10MIN ; 10�� ������ �ʱ�ȭ
	GOTO 	XLOOP

; ������ �ð� ���� ����� ����� �����ϱ� ���� ���α׷� ����


XLOOP
; KEY Ȯ���Ͽ� KEY�� ���� ��� ����
; ��ɿ� ���� ���� �︮�� ��
	GOTO	M_LOOP
	
CONV 
	ANDLW 	0FH ; W�� low nibble ���� ��ȯ����.
	ADDWF 	PCL,F ; PCL+��ȯ ���ڰ� --> PCL
; PC�� ����ǹǷ� �� ��ɾ� ���� ���� ��
; ġ�� ���������.
	RETLW 	B'00000011' ;'0'�� ǥ�� �ϴ� ���� W�� ����
	RETLW 	B'10011111' ; '1'�� ǥ�� �ϴ� ��
	RETLW 	B'00100101' ; '2'�� ǥ�� �ϴ� ��
	RETLW 	B'00001101' ; '3'�� ǥ�� �ϴ� ��
	RETLW 	B'10011001' ; '4'�� ǥ�� �ϴ� ��
	RETLW 	B'01001001' ; '5'�� ǥ�� �ϴ� ��
	RETLW 	B'01000001' ; '6'�� ǥ�� �ϴ� ��
	RETLW 	B'00011011' ; '7'�� ǥ�� �ϴ� ��
	RETLW 	B'00000001' ; '8'�� ǥ�� �ϴ� ��
	RETLW 	B'00001001' ; '9'�� ǥ�� �ϴ� ��
	RETLW 	B'11111101' ; '-'�� ǥ�� �ϴ� ��
	RETLW 	B'11111111' ; ' '�� ǥ�� �ϴ� ��
	RETLW 	B'11100101' ; 'C'�� ǥ�� �ϴ� ��
	RETLW 	B'11111110' ; '��'�� ǥ�� �ϴ� ��
	RETLW 	B'01100001' ; 'E'�� ǥ�� �ϴ� ��
	RETLW 	B'01110001' ; 'F'�� ǥ�� �ϴ� ��

LEDLP
	MOVLW	B'00111000'
	MOVWF	PORTC
	CALL	DELAY
	MOVLW	B'00000000'
	GOTO	LEDLPR

DELAY	; DELAY �����ƾ						
		MOVLW	.125
		MOVWF	DBUF1
LP1		MOVLW	.200
		MOVWF	DBUF2
LP2		NOP
		DECFSZ	DBUF2,F
		GOTO	LP2
		DECFSZ	DBUF1,F
		GOTO	LP1
		RETURN	
		END	
	

END