module MEM_WB_Latch ();

//TODO: Jump and Link (JAL enable)
//TODO: is Branching_in what we want?
//TODO: PC stuff?
input clk, rst, en, Branching_in, RegWrite_in, MemToReg_in; 
input [15:0] aluOutput_in, readData_in;

output Branching_out, RegWrite_out, MemToReg_out; 
output [15:0] aluOutput_out, readData_out;

register_16bits rf_MEMWB_aluOutput_out(.readData(aluOutput_out), .clk(clk), .rst(rst), .writeData(aluOutput_in), .writeEnable(en));
register_16bits rf_MEMWB_readData_out(.readData(readData_out), .clk(clk), .rst(rst), .writeData(readData_in), .writeEnable(en));

dff dff_MEMWB_Branching_out(Branching_in, Branching_out, clk, rst);
dff dff_MEMWB_RegWrite_out(RegWrite_in, RegWrite_out, clk, rst);
dff dff_MEMWB_MemToReg_out(MemToReg_in, MemToReg_out, clk, rst);


endmodule