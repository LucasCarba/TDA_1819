.data
A: .hword 0100010111100010
B: .hword 0001101101001100
C: .word 10101110
D: .word 1011010111001001 // B5C9
E: .word 00000001

.subr
subr1: 
dsub r3,r1,r2
pushh r3
slt r4,r3,r0
bne r4, r7 ,mayorUno
lb r6, C(r0)
xnorr r5,r3,r6
jmp finalUno
mayorUno: lh r6, D(r0) 
xnorr r5, r3, r6
finalUno: pushh r5
ret

subr1: 
dsub r3,r2,r1
pushh r3
slt r4,r3,r0 
bne r4, r7 ,mayorDos
lb r6, C(r0)
xnorr r5,r3,r6
jmp finalDos

mayorDos: lh r6, D(r0) 
xnorr r5, r3, r6
finalDos: pushh r5
ret

.code
lh r1, A(r0)
lh r2, B(r0)
lb r7, E(r0)
call subr1
call subr2
halt
