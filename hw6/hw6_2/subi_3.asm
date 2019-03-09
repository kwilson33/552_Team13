// Rd <- I(sign ext.) – Rs
//  most positive 5 bit imm - most negative 8bit immediate 
lbi r1, -128 		// load -128 to r1 
subi r2,r1, 15		// 15 - (-128)
halt