//Memory stage might be done now?

// This module takes in the ALU result and control signals and depending
// on these signals, the memory2c module will operate
module memoryReadWrite (aluOutput, writeData, readData, memRead, memWrite, rst, dump, clk); 

	input clk, dump, rst, memWrite, memRead;
	input[15:0] aluOutput, writeData; 
	output [15:0] readData;

	wire memReadOrWrite, unalignedMemErr;

	assign memReadOrWrite = (memWrite | memRead);

	// This module will create the output readData for the top level module
	stallmem dataMemory			(.DataIn(16'b0), .Addr(currentPC),
								 .Wr(memWrite), .clk(clk), .rst(rst), 
								.createdump(dump), .DataOut(instruction), .err(unalignedMemErr),
								.Stall(instructionMemStall_out), .Rd(memRead), .CacheHit(cacheHit), //Rd == DMemEn (Mingyuan only did for LD instruction, I don't think this matters though if you look at stallmem.v)
								.Done(instructionMemDone_out)); // probably do nothing with this
								   
endmodule