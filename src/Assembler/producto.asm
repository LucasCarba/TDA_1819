		.data
A:		.word	0
B:		.word	6
C:		.word	5
		.code
		lw r1, A(r0)
		lw r2, B(r0)
		lw r3, C(r0)
prod:	dadd r1, r1, r2
		daddi r3, r3, -1
		bnez r3, prod
		halt
	