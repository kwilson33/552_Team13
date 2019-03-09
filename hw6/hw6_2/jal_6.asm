// checks irregular & repeated use of jal
lbi r1, 0x01
jal 0
jal 0
jal 2
lbi r1, 0x02
halt			// R1 = 1 and R7 should have address of lbi
