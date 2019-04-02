module EX_MEM_Latch (// Inputs
					clk, rst, en, 
					RegWrite_in, DMemWrite_in, DMemEn_in, 
					DMemDump_in, Branching_in, Jump_in, MemToReg_in,
					WriteRegister_in, WriteRegister_out,
					aluOutput_in, B_in, updatedPC_in,
					nextPC_in, branchingPCEnable_in,
					BranchingOrJumping_in);
					

	//TODO: Check if our branching and jump are connected to the correct signals
	//TODO: Figure out hasAB

	input clk, rst, en, RegWrite_in, DMemWrite_in,
		 DMemEn_in, MemToReg_in, 
		 DMemDump_in, Branching_in, Jump_in,
		 branchingPCEnable_in, BranchingOrJumping_in;
	input [15:0] aluOutput_in, B_in, updatedPC_in, nextPC_in; 
	input [2:0] WriteRegister_in;

	output  [2:0] WriteRegister_out;
	
	wire [15:0] aluOutput_out, B_out, updatedPC_out, nextPC_out; 
	wire RegWrite_out, DMemWrite_out, DMemEn_out, MemToReg_out, 
		 DMemDump_out, Branching_out, Jump_out,
		 branchingPCEnable_out, BranchingOrJumping_out; 


	// use connection by reference to these modules to pass from EX_MEM to Memory and Writeback, Hazard Detection
	register_16bits rf_EXMEM_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
	register_16bits rf_EXMEM_B_out(.readData(B_out), .clk(clk), .rst(rst), .writeData(B_in), .writeEnable(en));
	register_16bits rf_EXMEM_updatedPC_out(.readData(updatedPC_out), .clk(clk), .rst(rst), .writeData(updatedPC_in), .writeEnable(en));
	register_16bits rf_EXMEM_nextPC_out(.readData(nextPC_out), .clk(clk), .rst(rst), .writeData(nextPC_in), .writeEnable(en));

	dff dff_EXMEM_RegWrite_out(.d(RegWrite_in), 	.q(RegWrite_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_DMemWrite_out(.d(DMemWrite_in),   .q(DMemWrite_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_DMemEn_out(.d(DMemEn_in), 		.q(DMemEn_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_MemToReg_in_out(.d(MemToReg_in), 	.q(MemToReg_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_DMemDump_out(.d(DMemDump_in), 	.q(DMemDump_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_Branching_out(.d(Branching_in), 	.q(Branching_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_Jump_out		(.d(Jump_in), 	  	.q(Jump_out), .clk(clk), .rst(rst));
	dff dff_EXMEM_branchingPCEnable_out	(.d(branchingPCEnable_in), 	  	.q(branchingPCEnable_out), .clk(clk), .rst(rst));


	// dff for WriteRegister
    dff dff_EXMEM_WriteRegister_in_out0(.d(WriteRegister_in[0]), .q(WriteRegister_out[0]), .clk(clk), .rst(rst));
    dff dff_EXMEM_WriteRegister_in_out1(.d(WriteRegister_in[1]), .q(WriteRegister_out[1]), .clk(clk), .rst(rst));
    dff dff_EXMEM_WriteRegister_in_out2(.d(WriteRegister_in[2]), .q(WriteRegister_out[2]), .clk(clk), .rst(rst));

    dff dff_EXMEM_BorJ_out(.d(BranchingOrJumping_in), .q(BranchingOrJumping_out), .clk(clk), .rst(rst)); 

endmodule