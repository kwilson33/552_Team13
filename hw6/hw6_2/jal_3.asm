// checks for lack of jump
JAL 0 			// Should increment to the next PC
Nop	
halt


// checks for correct values in R7 & PC from jump and link
JAL .GoHere
lbi r6, -1		// Should not enter here

.GoHere:
lbi r6, 1		// R6 should be 1
halt			// R7 should have previous instruction
