//Fetch instructionuction work in progress

module fetchInstruction(clk, rst, PC_In, dump, PC_Next, instruction)

	input [15:0] PC_In; 
	input clk, dump, rst; 

	output [15:0] PC_Next; 
	output [15:0] instruction; 

	wire stop; 
	wire[15:0] currentPC; 

	//wires that we don't care about
	wire c_out; 


	assign stop = ~dump; 

	//Inputs: clk, rst, writeEnable, [15:0]writeData
	//Output: [15:0]readData 
	register_16bits PC_Register( .readData(PC_In), .clk(clk), .rst(rst), .writeData(currentPC), .writeEnable(stop)); 


	//instruction Memory
	memory2c instructionMemory (.data_in(16'b0), .addr(currentPC),
								.enable(1'b1), .wr(wr), .clk(clk), .rst(rst),
								.createdump(dump), .data_out(instruction)); 


	//Adding 2 to the PC
	rca_16b PC_Adder(.A(currentPC), .B(16'h0002), 
					 .C_in(1'b0), .S(PC_Next), 
					 .C_out(c_out));
					 
endmodule

