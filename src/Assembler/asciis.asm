		.data
cadena:	.ascii	"adbgcd", "dbiddg", "0"
carb:	.asciiz	"d"
car0:	.asciiz	"0"
cant:	.word	0
		.code
		dadd r1, r0, r0
		lb r2, carb(r0)
		lb r3, car0(r0)
		lw r4, cant(r0)
		lb r5, cadena(r1)
loop:	bne r5, r2, no_car
		daddi r4, r4, 1
no_car:	daddi r1, r1, 1
		lb r5, cadena(r1)
		bne r5, r3, loop
		sw r4, cant(r0)
		halt
	