	.h8300s
	
	.equ	PUTS,0x114			;vystupni operace
	.equ	GETS,0x113			;vstupni operace	
	.equ	syscall,0x1FF00
	
	.data
	
vstup:		.space	100
prompt: 	.asciz	"Zadejte vstup: "
zobrazit:	.long	0

	.align 	2
	
par_vstup:	.long	vstup
par_prompt:	.long 	prompt
par_cislo:	.long  	zobrazit


	.align	1
	.space	100
stck:

	.text
	.global _start
	
prevod:	add.b	#-'0',R0L
		cmp.b	#9,R0L
		bls	lab1
		add.b	#('0'-'A'+0x0A),R0L
lab1:	rts

_start:	mov.l	#stck,ER7
		mov.l	#vstup,ER2
		xor.l	ER5,ER5
		xor.l	ER6,ER6
	
		mov.w 	#PUTS,R0
		mov.l	#par_prompt,ER1
		jsr		@syscall
	
		mov.w	#GETS,R0
		mov.l	#par_vstup,ER1
		jsr		@syscall
	
		mov.b	#4,R4l			;pocet vstupnich cifer ktere se zpracuji

		xor.l 	ER0,ER0
		xor.l 	ER1,ER1
	
ascdec:	mov.b	@ER2,R0L		;prevede ulozenou ascii hodnotu na decimalni
		cmp.b	#0x0A,R0L
		
		beq		pkrcj			;pokud byl zaznamenan entr, ukoncuje prevoc a pokracuje dal
		
		jsr		@prevod
		shll.l	#2,ER1
		shll.l	#2,ER1
		or.b	R0L,R1L
		inc.l	#1,ER2
		dec.b	R4l
		bne	ascdec
	
pkrcj:	xor.w	E6,E6
		xor.w	R4,R4
		mov.w	#10,R5
		mov.w	R1,R6
		
deleni:	divxu.w R5,ER6			;deli postupne vstup deseti, zbytek uklada do zasobniku
	
		add.w #0x30:16,E6
		
		push.w E6
		xor.w E6,E6
		inc.b R4l
		cmp.w #0,R6
	
		bne deleni
		
vypis:	pop.w R6				;tento loop vypise obsah zasobniku do konzole

		mov.b	R6l,@zobrazit
		mov.w	#PUTS,R0
		mov.l	#par_cislo,ER1
		jsr		@syscall
		
		dec.b	R4l
		cmp.w	#0,R4
	
		bne vypis
	
konec:	jmp	@konec
	