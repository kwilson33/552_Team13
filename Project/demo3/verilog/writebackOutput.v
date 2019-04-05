//Writeback

module writebackOutput(readData, writeData, aluOutput, PC_Next, memToReg, JAL_en); 

	input[15:0] readData, aluOutput, PC_Next; 
	input memToReg, JAL_en; 

	output[15:0] writeData;

	// Select is {JAL_en,memToReg} which will let us know if we're writing to a register, jumping
	// or neither
	// 00 - take the ALU output to write to register file
	// 01 - take what came out of memory to write to register file
	// 10 - jumping! so store the context of current PC into R7 

	mux4_1 #(.NUM_BITS(16)) mux1(.InA(aluOutput), .InB(readData), .InC(PC_Next), .InD(16'h0000), .S({JAL_en, memToReg}), .Out(writeData)); 
 
endmodule