
module ID_EX_Latch(clk, rst, en,
                   A_in, B_in,
                   A_out, 
                   PC_In, 
                   S_extend5_in, 
                   S_extend5_out,
                   Z_extend5_in, 
                   S_extend8_in, 
                   Z_extend8_in, 
                   Branching_in,
                   S_extend11_in,
                   instruction_in, 
                   RegWrite_in,
                   DMemWrite_in,
                   MemToReg_in, 
                   DMemDump_in, 
                   invA_in, invB_in,
                   Cin_in, 
                   SESel_in, SESel_out,
                   RegDst_in, RegDst_out,
                   ALUSrc2_in,
                   stall);

      //TODO: Figure out what instruction_in is for
      //TODO: Figure out PC stuff
      //TODO: Check if we need hasAB?
      //TODO: AluSrc signal?

      input [15:0] PC_In, A_in, B_in, S_extend5_in, Z_extend5_in, S_extend8_in, Z_extend8_in, S_extend11_in, instruction_in; 
      input clk, rst, en, RegWrite_in, DMemWrite_in, MemToReg_in, DMemDump_in, invA_in, invB_in, Cin_in, ALUSrc2_in, stall; 
      input [2:0] SESel_in; 
      input [1:0] RegDst_in;

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

      dff dff_IDEX_RegWrite_out(.d(RegWrite_in), .q(RegWrite_out), .clk(clk), .rst(rst));
      dff dff_IDEX_DMemWrite_out(.d(DMemWrite_in), .q(DMemWrite_out), .clk(clk), .rst(rst));
      dff dff_IDEX_MemToReg_out(.d(MemToReg_in), .q(MemToReg_out), .clk(clk), .rst(rst));
      dff dff_IDEX_DMemDump_out(.d(DMemDump_in), .q(DMemDump_out), .clk(clk), .rst(rst));
      dff dff_IDEX_invA_out(.d(invA_in), .q(invA_out), .clk(clk), .rst(rst));
      dff dff_IDEX_invB_out(.d(invB_in), .q(invB_out), .clk(clk), .rst(rst));
      dff dff_IDEX_Cin_out(.d(Cin_in), .q(Cin_out), .clk(clk), .rst(rst));
      dff dff_IDEX_ALUSrc2_out(.d(ALUSrc2_in), .q(ALUSrc2_out), .clk(clk), .rst(rst));
      dff dff_IDEX_Branching_out(.d(Branching_in), .q(Branching_out), .clk(clk), .rst(rst));

      // dff for SESel and RegDst
       dff dff_IDEX_SESel_out0(.d(SESel_in[0]), .q(SESel_out[0]), .clk(clk), .rst(rst));
       dff dff_IDEX_SESel_out1(.d(SESel_in[1]), .q(SESel_out[1]), .clk(clk), .rst(rst));
       dff dff_IDEX_SESel_out2(.d(SESel_in[2]), .q(SESel_out[2]), .clk(clk), .rst(rst));

        dff dff_IDEX_RegDst_out0(.d(RegDst_in[0]), .q(RegDst_out[0]), .clk(clk), .rst(rst));
        dff dff_IDEX_RegDst_out1(.d(RegDst_in[1]), .q(RegDst_out[1]), .clk(clk), .rst(rst));


      //Want to store a bunch of control signals here
      
endmodule