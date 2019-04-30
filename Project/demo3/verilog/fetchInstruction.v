module fetchInstruction(clk, rst, 
						PC_In,
						branchingPCEnable_in,
						MEM_WB_Branch_in,
						dump, 
						PC_Next, 
						instruction,
						PC_WriteEn_in,
						stall,
						instructionMemoryStall_out,
						dataMemoryStallOut);




	input [15:0] PC_In; 
	input clk, dump, rst, branchingPCEnable_in, PC_WriteEn_in, stall, MEM_WB_Branch_in, dataMemoryStallOut; 

	output [15:0] PC_Next;
	output [15:0] instruction; 
	output instructionMemoryStall_out;

	wire [15:0] currentPC, pc_increment, pcUpdated, instr_mem_system;
	wire cacheHit, instructionMemDone_out, unalignedMemErr;
	//wires that we don't care about
	wire c_out; 

	// if we are branching or stalling halt the PC
	assign pc_increment = (stall | branchingPCEnable_in | instructionMemoryStall_out | dataMemoryStallOut ) ? 16'h0 : 16'h2;

///////////////////////////////////////////////////////////
	assign pcUpdated = (MEM_WB_Branch_in) ? PC_In : PC_Next; 

	//Inputs: clk, rst, writeEnable, [15:0] writeData
	//Output: [15:0]readData 
	register_16bits PC_Register( .readData(currentPC), .clk(clk), .rst(rst), .writeData(pcUpdated), .writeEnable(~dump)); 

	/*
	// instruction Memory
	// instruction comes from the current PC
	stallmem instructionMemory (.DataIn(16'b0), .Addr(currentPC),
								 .Wr(1'b0), .clk(clk), .rst(rst),
								.createdump(dump), .DataOut(instruction), .err(unalignedMemErr),
								.Stall(instructionMemoryStall_out), .Rd(1'b1), .CacheHit(cacheHit), 
								.Done(instructionMemDone_out)); // probably do nothing with this
	*/							

	
	mem_system #(.memtype(0)) instructionMemory(.DataIn(16'b0), .Addr(currentPC),
								 .Wr(1'b0), .clk(clk), .rst(rst),
								 .createdump(dump), .DataOut(instruction), .err(unalignedMemErr),
								 .Stall(instructionMemoryStall_out), .Rd(1'b1), .CacheHit(cacheHit),
								 .Done(instructionMemDone_out), .isBranch(1'b0));
	

	// if Instruction Memory not done, do a NOP.
	//assign instruction = (~instructionMemDone_out) ? 16'b0000100000000000 : instr_mem_system;

	

	// Adding 2 to the PC
	rca_16b PC_Adder(.A(currentPC), .B(pc_increment), 
					 .C_in(1'b0), .S(PC_Next), 
					 .C_out(c_out));	 
endmodule

