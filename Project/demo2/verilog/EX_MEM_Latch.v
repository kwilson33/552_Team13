module EX_MEM_Latch (// Inputs
					clk, rst, en, 
					RegWrite_in, DMemWrite_in, MemToReg_in, 
					DMemDump_in, Branching_in, Jump_in,
					aluOutput_in, B_in, updatedPC_in)


	//TODO: Check if our branching and jump are connected to the correct signals
	//TODO: Figure out hasAB

	input clk, rst, en, RegWrite_in, DMemWrite_in, MemToReg_in, DMemDump_in, Branching_in, Jump_in; 
	input [15:0] aluOutput_in, B_in, updatedPC_in; 
		

	// use connection by reference to these modules to pass from EX_MEM to Memory and Writeback, Hazard Detection
	register_16bits rf_EXMEM_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
	register_16bits rf_EXMEM_B_out(.readData(B_out), .clk(clk), .rst(rst), .writeData(B_in), .writeEnable(en));
	register_16bits rf_EXMEM_updatedPC_out(.readData(updatedPC_out), .clk(clk), .rst(rst), .writeData(updatedPC_in), .writeEnable(en));

	dff dff_EXMEM_RegWrite_out(.d(RegWrite_in), .q(RegWrite_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_DMemWrite_out(.d(DMemWrite_in), .q(DMemWrite_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_MemToReg_out(.d(MemToReg_in), .q(MemToReg_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_DMemDump_out(.d(DMemDump_in), .q(DMemDump_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_Branching_out(.d(Branching_in), .q(Branching_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_Jump_out		(.d(Jump_in), .q(Jump_out), .clk(clk), .rst(rst));

endmodule