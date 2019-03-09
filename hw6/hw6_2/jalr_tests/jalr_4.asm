// checks jalr jump to half, R7 = 0x4
lbi r0, 0x4
jalr r0, 0x4
add r1, r1, r1
add r2, r2, r2
halt
