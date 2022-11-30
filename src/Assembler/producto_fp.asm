		.data
A:		.float	0.0
B:		.float	6.0
C:		.float	5.0
D:		.float	-1.0
		.code
		lf f1, A(r0)
		lf f2, B(r0)
		lf f3, C(r0)
		lf f4, D(r0)
prod:	addf f1, f1, f2
		addf f3, f3, f4
		eqf f3, f0
		bfpf prod
		halt
	