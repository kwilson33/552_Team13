// Rd <- I(sign ext.) – Rs
//  most negative 5 bit imm - most positive 8bit immediate 
lbi r1, 127 		// load 127 to r1 
subi r2,r1, -16		// -16 - 127
halt