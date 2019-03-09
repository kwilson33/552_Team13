// checks jalr jump to earlier part of program, R7 = 0xa
lbi r0, 0x0			// R0 used for jump address calculation
lbi r1, 0xfd			// R1 acts as a loop counter
addi r1, r1, 0x01
bgez r1, .done		// after 3 exec of add, go to halt
jalr r0, 0x4
.done:
halt
