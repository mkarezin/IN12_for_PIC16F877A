	list p=PIC16F877A
	#include "p16f877a.inc"
	__config 0x3f33

	cblock 0x20 		; Адрес регистров общего назначения
		Counter
		Reg_1
		Reg_2
		Reg_3
	endc

W equ .0
F equ .1
PC equ 0x2

	org 0x00 			; Адрес векторов сброса
	goto Start

	org 0x04 			; Адрес вектора прерывания
	bcf INTCON,1
	call Go 			; Код подпрограммы обработчика прерывания
	retfie

Pause_full movlw .89 	; Задержка на 0,25 секунд
	movwf Reg_1
	movlw .88
	movwf Reg_2
	movlw .7
	movwf Reg_3
wr_full decfsz Reg_1,F
	goto wr_full
	decfsz Reg_2,F
	goto wr_full
	decfsz Reg_3,F
	goto wr_full
	nop
	nop
	return

Table addwf PC,F		; Содержимое команд счетчика PC = PC + W
	retlw b'10000000'	; 0
	retlw b'11110010'  	; 1
	retlw b'01001000' 	; 2
	retlw b'01100000' 	; 3
	retlw b'00110010' 	; 4
	retlw b'00100100' 	; 5
	retlw b'00000100' 	; 6
	retlw b'11110000' 	; 7
	retlw b'00000000' 	; 8
	retlw b'00100000' 	; 9

Erase movlw .0	  		; Обнуление
	movwf Counter 		; внутреннего счетчика
	movwf PORTA	  		; и порта А
	call Table	   		; Отрисовка нуля на семисегментнике
	movwf PORTC
	return

Go	movf Counter,W
	bcf STATUS,2
	xorlw .9
	btfsc STATUS,2
	goto Erase
	incf Counter,F
	incf PORTA
	movf Counter,W
	call Table
	movwf PORTC
	call Pause_full
	return

Start clrf STATUS 			; Банк 0
	bsf STATUS,RP0 			; Банк 1
	movlw .6	   			; Настройка порта А
	movwf ADCON1 ^80h  		; как цифрового порта
	clrf TRISA ^80h    		; Настройка выводов порта А на выход
	clrf TRISC ^80h     	; Настройки выводов порта В на выход
	bsf TRISB,0
	movlw b'01001000'
	movwf OPTION_REG ^80h
	bcf STATUS,RP0 			; Банк 0	
	movlw b'10010000'
	movwf INTCON
	call Erase
loop nop
	goto loop
	end
