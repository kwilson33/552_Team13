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
	memory2c_align dataMemory(.data_out(readData), .data_in(writeData), .addr(aluOutput), 
						.enable(memReadOrWrite), .wr(memWrite), 
						.createdump(dump), .clk(clk), .rst(rst), .err(unalignedMemErr)); 

endmodule