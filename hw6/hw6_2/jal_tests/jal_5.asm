// checks backward jump
lbi r1, 0x01
j 4 			// j pc + 2 + 4
addi r1, r1, 1
j 2
jal -6 		// jal pc + 2 -6
lbi r0, 0x01
halt			// R7 should have address of 2nd lbi, r1 = 2, r0 = 1
