// checks for negative jump
Nop
JAL 12 			// Should jump to first target, PC = 16
Nop
Nop
Nop
Nop 			// PC = 10 second target
halt
Nop
Nop 			// PC = 16 first target
JAL -10			// Should jump to second target, PC = 10
Nop
Nop
halt
