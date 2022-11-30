		.data
TABLA:	.float	6.0, 2.0, 5.0, -4.0, 8.0
LONG:	.float	5.0
DECR:	.float	-1.0
FACTOR:	.float	4.0
RES:	.float	0.0
		.code
		dadd r1, r0, r0
		lf f1, LONG(r0)
		lf f2, DECR(r0)
		lf f3, FACTOR(r0)
loop:	lf f4, TABLA(r1)
		mulf f4, f4, f3
		sf f4, RES(r1)
		daddi r1, r1, 4
		addf f1, f1, f2
		eqf f1, f0
		bfpf loop
		halt
	