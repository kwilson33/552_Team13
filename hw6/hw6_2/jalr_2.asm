// checks jump to registers except r7
LBI r3 26
Nop
Nop
JALR r3, 0 		// Should jump to target, PC = 26
Nop
Nop
Nop
Halt
Nop
Nop
Nop
Nop
Nop
Nop 			// PC = 26 target
Nop
Halt
