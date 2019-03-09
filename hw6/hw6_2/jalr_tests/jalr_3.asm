// checks if values can be added to jump register
JAL 4 // Jumps to TargetA, PC = 6
Nop
Nop
Nop // PC = 6 TargetA
JALR r7, 16 // Jumps to TargetB, PC = 18
Nop
Nop
Nop
Nop
Nop // TargetB
Halt
Nop
Nop
Halt

