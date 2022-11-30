		.data
TABLA:	.word	6, 0xFE, 5, -4, 0b1111
LONG:	.word	5
FACTOR:	.word	4
RES:	.word	0
		.code
		dadd r1, r0, r0
		lw r2, LONG(r0)
		lw r3, FACTOR(r0)
loop:	lw r4, TABLA(r1)
		dmul r4, r4, r3
		sw r4, RES(r1)
		daddi r1, r1, 4
		daddi r2, r2, -1
		bnez r2, loop
		halt
	