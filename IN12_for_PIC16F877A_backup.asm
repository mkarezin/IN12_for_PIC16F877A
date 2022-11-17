	list p=PIC16F877A
	#include "p16f877a.inc"
	__config 0x3f33
	cblock 0x20 ; Адрес регистров общего назначения
		Counter
		Reg_1
		Reg_2
		Reg_3
	endc
W equ .0
F equ .1
PC equ 0x2
	org 0x00 ; Адрес векторов сброса
	goto Start
Pause_full movlw .89 ; Задержка на 0,25 секунд
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
Pause_check movlw .166 ; Задержка на 100 микросекунд
	movwf Reg_1		 ; (защита от дребезга кнопки)
wr_check decfsz Reg_1,F
	goto wr_check
	nop
	return
Table addwf PC,F	; Содержимое команд счетчика PC = PC + W
	retlw b'01000000' ; 0
	retlw b'01111001' ; 1
	retlw b'00100100' ; 2
	retlw b'00110000' ; 3
	retlw b'00011001' ; 4
	retlw b'00010010' ; 5
	retlw b'00000010' ; 6
	retlw b'01111000' ; 7
	retlw b'00000000' ; 8
	retlw b'00010000' ; 9
Start clrf STATUS ; Банк 0
	bsf STATUS,RP0 ; Банк 1
	movlw .6	   ; Настройка порта А
	movwf ADCON1   ; как цифрового порта
	clrf TRISA    ; Настройка выводов порта А на выход
	clrf TRISB    ; Настройка выводов порта В на выход
	bsf TRISE,4	   ; Настройка вывода
	bsf TRISE,0	   ; RE0 на вход
	bcf STATUS,RP0 ; Банк 0
Erase movlw .0	   ; Обнуление
	movwf Counter  ; внутреннего счетчика
	movwf PORTA	   ; и порта А
	call Table	   ; Отрисовка нуля на семисегментнике
	movwf PORTB
preCheck_button btfss PORTE,0	; Проверка на нажатие кнопки
	goto preCheck_button
	call Pause_check		; Задержка для защиты от дребезга
	btfss PORTE,0	; Повторная проверка на нажатие кнопки
	goto preCheck_button
Check_button btfsc PORTE,0
	goto Check_button
	call Pause_check
	btfsc PORTE,0
	goto Check_button
	movf Counter,W
	bcf STATUS,2
	xorlw .9
	btfsc STATUS,2
	goto Erase
	incf Counter,F
	incf PORTA
	movf Counter,W
	call Table
	movwf PORTB
	call Pause_full
	goto preCheck_button
	end
