		.data
A:		.word	0xD813463B
N:		.word	7
		.code
		lw r1, A(r0)
		lw r2, N(r0)
		dsl r3, r1, r2
		dsli r4, r1, 7
		dsr r5, r1, r2
		dsri r6, r1, 7
		dsls r7, r1, r2
		dslsi r8, r1, 7
		dsrs r9, r1, r2
		dsrsi r10, r1, 7
		halt
	