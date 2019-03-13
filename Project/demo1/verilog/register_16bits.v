//Mark added this file to the project. There was 
//no skeleton code here. 
module register_16bits (readData, clk, rst, writeData, writeEnable); 

	output  [15:0]	readData;
	input 			clk, rst, writeEnable;
	input	[15:0] 	writeData;

	wire[15:0] in; 
	
	// Depending if write is enabled, input will be
	// new writeData or current output
	//assign in = writeEnable ?  readData : writeData;
	assign in = writeEnable ? writeData : readData; 
	
	// attach the 16 bit in to the input of a
	// D Flip Flop. The output will also be 16 bits.
	dff  dff_16_bits[15:0] (.q(readData), .d(in), .clk(clk), .rst(rst)); 

endmodule
