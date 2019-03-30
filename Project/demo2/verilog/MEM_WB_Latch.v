module MEM_WB_Latch (clk, rst, en, 
					Branching_in, RegWrite_in, 
					DMemEn_in, MemToReg_in,
					aluOutput_in, readData_in,
					WriteRegister_in, WriteRegister_out,
					Jump_in, updatedPC_in);

	//TODO: Jump and Link (JAL enable) - Kevin : I added Jump_in
	//TODO: is Branching_in what we want?
	//TODO: PC stuff? - Kevin : I added updatedPC_in

	input clk, rst, en, Branching_in, RegWrite_in, MemToReg_in, DMemEn_in, Jump_in;
	input [15:0] aluOutput_in, readData_in, updatedPC_in;

	input [2:0] WriteRegister_in; 
	output  [2:0] WriteRegister_out;

	wire [15:0] aluOutput_out, readData_out, updatedPC_out;
	wire Branching_out, RegWrite_out, MemToReg_out, DMemEn_out, Jump_out;

	// use connection by reference to these modules to pass from MEM_WB to  Writeback, Decode, Hazard Detection
	register_16bits rf_MEMWB_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
	register_16bits rf_MEMWB_readData_out(.readData(readData_out), .clk(clk), .rst(rst), .writeData(readData_in), .writeEnable(en));
	register_16bits rf_MEMWB_updatedPC_in_out(.readData(updatedPC_out), .clk(clk), .rst(rst), .writeData(updatedPC_in), .writeEnable(en));

	dff dff_MEMWB_Branching_out(.d(Branching_in), 	.q(Branching_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_RegWrite_out(.d(RegWrite_in), 	.q(RegWrite_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_MemToReg_in_out(.d(MemToReg_in), 	.q(MemToReg_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_Jump_in_out(.d(Jump_in), 			.q(Jump_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_DMemEn_out(.d(DMemEn_in), 		.q(DMemEn_out), .clk(clk), .rst(rst));

	// dff for WriteRegister
    dff dff_MEMWB_WriteRegister_in_out0(.d(WriteRegister_in[0]), .q(WriteRegister_out[0]), .clk(clk), .rst(rst));
    dff dff_MEMWB_WriteRegister_in_out1(.d(WriteRegister_in[1]), .q(WriteRegister_out[1]), .clk(clk), .rst(rst));
    dff dff_MEMWB_WriteRegister_in_out2(.d(WriteRegister_in[2]), .q(WriteRegister_out[2]), .clk(clk), .rst(rst));
endmodule