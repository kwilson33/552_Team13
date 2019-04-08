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
								.Stall(instructionMemStall_out), .Rd(memRead), .CacheHit(cacheHit), // TODO: Do something with stall signal, all subsequent instructions (e.g., instructions in IF, ID, and EX in the above example) should be stopped and your processor would halt (not sure if this is for err or stall???)
								.Done(instructionMemDone_out)); // probably do nothing with this
								   
endmodule