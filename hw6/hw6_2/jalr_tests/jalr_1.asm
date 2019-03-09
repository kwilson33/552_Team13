// checks if jalr can return to where jal jumped from
Nop
JAL 10 			// Should jump to first target, PC = 14 & store PC = 4
Nop 			// PC = 4 second target
Halt
Nop
Nop
Nop
Nop 			// PC = 14 first target
JALR r7, 0 		// Should jump to second target, PC = 4
Nop	
Nop
Halt
