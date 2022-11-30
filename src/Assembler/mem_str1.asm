		.data
A:		.float	5.0
B:		.float	6.0
C:		.word	20
D:		.word	6
		.code
		lf f1, A(r0)
		lf f2, B(r0)
		lw r1, C(r0)
		lw r2, D(r0)
		nop
		addf f3, f1, f2
		mulf f4, f1, f2
		dadd r3, r1, r2
		dsub r4, r1, r2
		addf f5, f1, f2
		ddiv r6, r1, r2
		sw r3, D(r2)
		halt
	