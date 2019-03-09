// checks loop to earlier portion of program (R7 set to 0x8)
lbi r1, 0xfd
addi r1, r1, 0x01
bgez r1, .done		// after 3 exec of add, go to halt
jal 0x7fa

.done:
Halt
