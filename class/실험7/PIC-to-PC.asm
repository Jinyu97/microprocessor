	PROCESSOR 16F876A

	#INCLUDE <P16F876A.INC>

		
	
; ---변수 선언---

VARIABLE DBUF1 = 20H
VARIABLE DBUF2 = 21H


		
	ORG	0000
	; --------- 송신 설정 부 ---------
	BSF	STATUS, RP0		; BANK 1
	BCF	TRISC, 6		; TX 단자를 출력으로
	MOVLW	B'00100100' 		; BIT2(BRGH=1), BIT5(TXEN=1)
	MOVWF	TXSTA			; 전송허가, 고속	
	MOVLW	.51			; BAUD RATE ? 4M 기준(4800 bps)
	MOVWF	SPBRG
	BCF	STATUS, RP0		; BANK 0
	MOVLW	B'10000000'		; BIT7(SPEN=1: 직렬포트 허가)
	MOVWF	RCSTA			; 비동기 직렬 포트 인에이블

		
; MAIN


	MOVLW	'A'
	CALL	TX_OUT
	CALL	DELAY		; 안정된 동작을 위하여


BBLP	
	GOTO	BBLP

;-----------------------------------------------------------

TX_OUT					; W-reg 내용이 출력됨
	MOVWF	TXREG		; 송신 데이터 로드
	; --------- 송신이 완료되었는가를 확인 ----------
LP	BSF		STATUS, RP0	; BANK 1
;	CLRWDT				; watch-dog 사용시 넣어야 함
	BTFSS	TXSTA, TRMT	; 송신완료 확인
	GOTO	LP
	BCF		STATUS, RP0	; BANK 0
	NOP					; 약간의 지연이 필요할 때
	RETURN


;--- LONG DELAY FOR LCD COMMAND   ---
		
DELAY
	MOVLW		0FFH
	MOVWF		DBUF1
LP2
	MOVLW		05H
	MOVWF		DBUF2
LP3
	NOP
	DECFSZ		DBUF2, F
	GOTO		LP3
	DECFSZ		DBUF1, F
	GOTO		LP2
	
	RETURN
	
	END