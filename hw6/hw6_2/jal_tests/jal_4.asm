// checks basic JAL
lbi r1, 0x00
jal 2			// Jumps over next instruction
lbi r1, 0x01		// R1 should have 0		
lbi r2, 0x00		// R2 should have 0
halt			// R7 should have address of lbi $1, 0x01
