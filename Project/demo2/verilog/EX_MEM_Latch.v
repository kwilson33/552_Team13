module EX_MEM_Latch ();

//TODO: Check if our branching and jump are connected to the correct signals
//TODO: Figure out hasAB

input clk, rst, en, RegWrite_in, DMemWrite_in, MemToReg_in, DMemDump_in, Branching_in, Jump_in; 
input [15:0] aluOutput_in, B_in, updatedPC_in; 
	
output RegWrite_out, DMemWrite_out, MemToReg_out, DMemDump_out, Branching_out, Jump_out; 
output [15:0] aluOutput_out, B_out, updatedPC_out; 

register_16bits rf_EXMEM_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
register_16bits rf_EXMEM_B_out(.readData(B_out), .clk(clk), .rst(rst), .writeData(B_in), .writeEnable(en));
register_16bits rf_EXMEM_updatedPC_out(.readData(updatedPC_out), .clk(clk), .rst(rst), .writeData(updatedPC_in), .writeEnable(en));

dff dff_EXMEM_RegWrite_out(RegWrite_in, RegWrite_out, clk, rst);
dff dff_EXMEM_DMemWrite_out(DMemWrite_in, DMemWrite_out, clk, rst);
dff dff_EXMEM_MemToReg_out(MemToReg_in, MemToReg_out, clk, rst);
dff dff_EXMEM_DMemDump_out(DMemDump_in, DMemDump_out, clk, rst);
dff dff_EXMEM_Branching_out(Branching_in, Branching_out, clk, rst);
dff dff_EXMEM_Jump_out(Jump_in, Jump_out, clk, rst);

endmodule