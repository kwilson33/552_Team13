// Rd <- I(sign ext.) – Rs
//  most negative 5 bit imm - most negative 8bit immediate 
lbi r1, -128 		// load -128 to r1 
subi r2,r1, -16		// -16 - (-128)
halt