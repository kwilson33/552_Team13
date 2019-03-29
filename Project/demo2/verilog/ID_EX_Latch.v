module ID_EX_Latch(PC_In, A_in, B_in, PC_Out, A_out, B_out);

//TODO: Figure out what instruction_in is for
//TODO: Figure out PC stuff
//TODO: Check if we need hasAB?
//TODO: AluSrc signal?

input [15:0] PC_In, A_in, B_in, S_extend5_in, Z_extend5_in, S_extend8_in, Z_extend8_in, S_extend11_in, instruction_in; 
input clk, rst, en, RegWrite_in, DMemWrite_in, MemToReg_in, DMemDump_in, invA_in, invB_in, Cin_in, ALUSrc2_in, stall; 
input [2:0] SESel_in; 
input [1:0] RegDst_in;

output [15:0] PC_Out, A_out, B_out, S_extend5_out, Z_extend5_out, S_extend8_out, Z_extend8_out, S_extend11_out, instruction_out; 
output RegWrite_out, DMemWrite_out,MemToReg_out, DMemDump_out, invA_out, invB_out, Cin_out, ALUSrc2_out; 
output [2:0] SESel_out; 
output [1:0] RegDst_out;

register_16bits rf_IDEX_PC_Out(.readData(PC_Out), .clk(clk), .rst(rst), .writeData(PC_In), .writeEnable(en));

register_16bits rf_IDEX_Aout(.readData(A_out), .clk(clk), .rst(rst), .writeData(A_in), .writeEnable(en));
register_16bits rf_IDEX_Bout(.readData(B_out), .clk(clk), .rst(rst), .writeData(B_in), .writeEnable(en));
register_16bits rf_IDEX_S_extend5_out(.readData(S_extend5_out), .clk(clk), .rst(rst), .writeData(S_extend5_in), .writeEnable(en));
register_16bits rf_IDEX_Z_extend5_out(.readData(Z_extend5_out), .clk(clk), .rst(rst), .writeData(Z_extend5_in), .writeEnable(en));
register_16bits rf_IDEX_S_extend8_out(.readData(S_extend8_out), .clk(clk), .rst(rst), .writeData(S_extend8_in), .writeEnable(en));
register_16bits rf_IDEX_Z_extend8_out(.readData(Z_extend8_out), .clk(clk), .rst(rst), .writeData(Z_extend8_in), .writeEnable(en));
register_16bits rf_IDEX_S_extend11_out(.readData(S_extend11_out), .clk(clk), .rst(rst), .writeData(S_extend11_in), .writeEnable(en));
register_16bits rf_IDEX_instruction_out(.readData(instruction_out), .clk(clk), .rst(rst), .writeData(instruction_in), .writeEnable(en));

dff dff_IDEX_RegWrite_out(RegWrite_in, RegWrite_out, clk, rst);
dff dff_IDEX_DMemWrite_out(DMemWrite_in, DMemWrite_out, clk, rst);
dff dff_IDEX_MemToReg_out(MemToReg_in, MemToReg_out, clk, rst);
dff dff_IDEX_DMemDump_out(DMemDump_in, DMemDump_out, clk, rst);
dff dff_IDEX_invA_out(invA_in, invA_out, clk, rst);
dff dff_IDEX_invB_out(invB_in, invB_out, clk, rst);
dff dff_IDEX_Cin_out(Cin_in, Cin_out, clk, rst);
dff dff_IDEX_ALUSrc2_out(ALUSrc2_in, ALUSrc2_out, clk, rst);


//Want to store a bunch of control signals here
// 
endmodule