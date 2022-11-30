		.data
A:		.word	0
B:		.word	6
C:		.word	5
		.code
		lw r1, B(r0)
prod:	dadd r1, r1, r1
		jmp prod
		halt
	