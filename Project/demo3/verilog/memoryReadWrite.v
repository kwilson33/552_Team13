//Memory stage might be done now?

// This module takes in the ALU result and control signals and depending
// on these signals, the memory2c module will operate
module memoryReadWrite (aluOutput, writeData, 
						readData, memRead, memWrite, 
						rst, dump, clk,dataMemoryStallOut ); 

	input clk, dump, rst, memWrite, memRead;
	input[15:0] aluOutput, writeData; 
	output [15:0] readData;
	output dataMemoryStallOut;
	wire memReadOrWrite, cacheHit, dataMemoryDone;

	
	stallmem dataMemoryModule	 (.DataIn(writeData), .Addr(aluOutput),
								 .Wr(memWrite), .clk(clk), .rst(rst), 
								.createdump(dump), .DataOut(readData), .err(unalignedMemErr),
								.Stall(dataMemoryStallOut), .Rd(memRead), .CacheHit(cacheHit), 
								.Done(dataMemoryDone)); 
								
	/*
	mem_system dataMemoryModule(.DataIn(writeData), .Addr(aluOutput),
								 .Wr(memWrite), .clk(clk), .rst(rst), 
								.createdump(dump), .DataOut(readData), .err(unalignedMemErr),
								.Stall(dataMemoryStallOut), .Rd(memRead), .CacheHit(cacheHit), 
								.Done(dataMemoryDone));
	*/
endmodule