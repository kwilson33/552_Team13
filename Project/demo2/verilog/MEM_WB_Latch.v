module MEM_WB_Latch (clk, rst, en, 
					Branching_in, RegWrite_in, MemToReg_in,
					aluOutput_in, readData_in);

	//TODO: Jump and Link (JAL enable)
	//TODO: is Branching_in what we want?
	//TODO: PC stuff?
	input clk, rst, en, Branching_in, RegWrite_in, MemToReg_in; 
	input [15:0] aluOutput_in, readData_in;

	// use connection by reference to these modules to pass from MEM_WB to  Writeback, Decode, Hazard Detection
	register_16bits rf_MEMWB_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
	register_16bits rf_MEMWB_readData_out(.readData(readData_out), .clk(clk), .rst(rst), .writeData(readData_in), .writeEnable(en));

	dff dff_MEMWB_Branching_out(.d(Branching_in), .q(Branching_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_RegWrite_out(.d(RegWrite_in), .q(RegWrite_out), .clk(clk), .rst(rst));
	dff dff_MEMWB_MemToReg_out(.d(MemToReg_in), .q(MemToReg_out), .clk(clk), .rst(rst));


endmodule