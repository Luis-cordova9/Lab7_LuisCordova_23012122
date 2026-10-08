        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

	
        EXPORT	LEDs_Init
		EXPORT	LED_Toggle
			
RCC		EQU		0x40021000
	
; Deben buscar el valor en el Reference Manual
GPIOE	EQU		0x0	; EvalBoard
;GPIOB	EQU		0x48000400	; K8
GPIOB   EQU		0x48000400	; G4
GPIOA	EQU		0x0 ; RE

AHB2ENR	EQU 	0x0000004C
	
; Deben buscar el valor en el Reference Manual
MODER   EQU		0x00
ODR		EQU		0x14

; Puntos extra: Bit Banding
BIT_N		EQU		18		
BB_AHB2ENR	EQU		0x42000000 + ((RCC + AHB2ENR - 0x40000000) * 32) + (BIT_N * 4)


LEDs_Init
	push {lr}
	
	;RCC->AHBENR |= (1<<1); 
	;**** Encender el puerto correspondiente de tu tarjeta ****
	
	ldr  r0, =RCC			;read
	ldr  r1, [r0,#AHB2ENR]
	movs r2, #0x2      		;modify
	orrs r1, r1, r2
	str  r1, [r0,#AHB2ENR]	;write
	
	;EvalBoard / Discovery
	;	GPIOE->MODER |= (1<<26);
	;	GPIOE->ODR &= ~(1<<13);
	;F303K8
	;	GPIOB->MODER &= ~(1<<7);			
	;	GPIOB->MODER |= (1<<6);
	;G431KB
	;	GPIOB->MODER &= ~(1<<17);
	;	GPIOB->MODER |= (1<<16);
	;F303RE
	;	GPIOA->MODER |= (1<<10);
	;	GPIOA->ODR &= ~(1<<5);	
	
	ldr  r0, =GPIOB			;read
	ldr  r1, [r0,#MODER]
	ldr  r2, =0x00020000	;modify (1<<17)
	bics r1, r1, r2
	ldr  r2, =0x00010000	;(1<<16)
	orrs r1, r1, r2
	str  r1, [r0,#MODER]	;write
	
	;RCC->AHB2ENR bit n = 1 con Bit Banding (puntos extra)
	ldr  r0, =BB_AHB2ENR
	movs r1, #1
	str  r1, [r0]
	
	pop {pc}

LED_Toggle
	push {lr}
	
	;GPIOE->ODR ^= 1<<13 EvalBoard / Disvovery
	;GPIOB->ODR ^= 1<<3 K8
	;GPIOB->ODR ^= 1<<8 G4
	;GPIOA->ODR ^= 1<<5 RE
	
	ldr  r0, =GPIOB			;read
	ldr  r1, [r0,#ODR]
	ldr  r2, =0x00000100	;modify (1<<8)
	eors r1, r1, r2
	str  r1, [r0,#ODR]		;write
	
	pop {pc}

	end
