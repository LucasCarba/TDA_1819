		.data
A:		.byte	0b01010110
B:		.byte	0b10111010
		.code
		lb r1, A(r0)
		lb r2, B(r0)
		and r3, r1, r2
		andi r4, r1, 0b10111010
		or r5, r1, r2
		ori r6, r1, 0b10111010
		xor r7, r1, r2
		xori r8, r1, 0b10111010
		not r9, r1
		halt
	