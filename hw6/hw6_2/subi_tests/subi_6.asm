// Rd <- I(sign ext.) – Rs
//  most negative 5 bit imm - itself
lbi r1, -16 			// load -16 to r1 
subi r2,r1, -16			// 16 - (-16)
halt