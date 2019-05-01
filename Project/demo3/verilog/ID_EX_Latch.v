
module ID_EX_Latch(clk, rst, en,
                   A_in, B_in,
                   PC_In, 
                   S_extend5_in, 
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
                   DMemEn_in,
                   invA_in, invB_in,
                   Cin_in, 
                   SESel_in, SESel_out,
                   RegDst_in, RegDst_out,
                   ALUSrc2_in,
                   BranchingOrJumping_in,
                   ReadingRs_in,
                   ReadingRt_in,
                   stall,
                   instructionMemoryStall_in);

      //TODO: Figure out what instruction_in is for
      //TODO: Figure out PC stuff
      //TODO: Check if we need hasAB?
      //TODO: AluSrc signal?

      input [15:0] PC_In, A_in, B_in, S_extend5_in, Z_extend5_in, S_extend8_in, Z_extend8_in, S_extend11_in, instruction_in; 

      input [2:0] SESel_in;
      output [2:0] SESel_out;  

      input [1:0] RegDst_in;
      output [1:0] RegDst_out;

      input clk, rst, en, RegWrite_in, DMemWrite_in, DMemEn_in, MemToReg_in,  
            Branching_in, DMemDump_in, invA_in, invB_in, Cin_in, ALUSrc2_in, stall, 
            BranchingOrJumping_in, ReadingRs_in, ReadingRt_in, instructionMemoryStall_in;

      wire [15:0] PC_Out, A_out, B_out, S_extend5_out, Z_extend5_out, S_extend8_out, Z_extend8_out, S_extend11_out, 
                  stall_or_instruction_out, stall_or_instruction_in, instruction_out; 
      
      wire RegWrite_out, DMemWrite_out, DMemEn_out, MemToReg_out,  
            Branching_out, DMemDump_out, invA_out, invB_out, Cin_out, ALUSrc2_out,
            RegWrite_or_stall, DMemWrite_or_stall, DMemEn_or_stall,
             MemToReg_or_stall, DMemDump_or_stall, BranchingOrJumping_out,
             ReadingRt_out,ReadingRs_out, instructionMemoryStall_out, stallRegWrite;

      assign stall_or_instruction_in = stall ? 16'b0000100000000000 : instruction_in;

      //If stalling set these control signals to 0
  
      assign RegWrite_or_stall = stall ? 0 : RegWrite_in;
      assign DMemWrite_or_stall = stall ? 0 : DMemWrite_in;
      assign DMemEn_or_stall =   stall ? 0 : DMemEn_in;
      assign MemToReg_or_stall = stall ? 0 : MemToReg_in;
      assign DMemDump_or_stall = stall ? 0 : DMemDump_in;

      register_16bits rf_IDEX_PC_Out(.readData(PC_Out), .clk(clk), .rst(rst), .writeData(PC_In), .writeEnable(en));

      register_16bits rf_IDEX_Aout(.readData(A_out), .clk(clk), .rst(rst), .writeData(A_in), .writeEnable(en));
      register_16bits rf_IDEX_Bout(.readData(B_out), .clk(clk), .rst(rst), .writeData(B_in), .writeEnable(en));
      register_16bits rf_IDEX_S_extend5_out(.readData(S_extend5_out), .clk(clk), .rst(rst), .writeData(S_extend5_in), .writeEnable(en));
      register_16bits rf_IDEX_Z_extend5_out(.readData(Z_extend5_out), .clk(clk), .rst(rst), .writeData(Z_extend5_in), .writeEnable(en));
      register_16bits rf_IDEX_S_extend8_out(.readData(S_extend8_out), .clk(clk), .rst(rst), .writeData(S_extend8_in), .writeEnable(en));
      register_16bits rf_IDEX_Z_extend8_out(.readData(Z_extend8_out), .clk(clk), .rst(rst), .writeData(Z_extend8_in), .writeEnable(en));
      register_16bits rf_IDEX_S_extend11_out(.readData(S_extend11_out), .clk(clk), .rst(rst), .writeData(S_extend11_in), .writeEnable(en));
      register_16bits rf_IDEX_instruction_out(.readData(stall_or_instruction_out), .clk(clk), .rst(rst), .writeData(stall_or_instruction_in), .writeEnable(en));

      register_16bits instr_fwd(.readData(instruction_out), .clk(clk), .rst(rst), .writeData(instruction_in), .writeEnable(en));


      dff dff_IDEX_RegWrite_out(.d(RegWrite_or_stall), .q(RegWrite_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_DMemWrite_out(.d(DMemWrite_or_stall), .q(DMemWrite_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_DMemEn_in_out(.d(DMemEn_or_stall), .q(DMemEn_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_MemToReg_out(.d(MemToReg_or_stall), .q(MemToReg_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_DMemDump_out(.d(DMemDump_or_stall), .q(DMemDump_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_invA_out(.d(invA_in), .q(invA_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_invB_out(.d(invB_in), .q(invB_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_Cin_out(.d(Cin_in), .q(Cin_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_ALUSrc2_out(.d(ALUSrc2_in), .q(ALUSrc2_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_Branching_out(.d(Branching_in), .q(Branching_out), .clk(clk), .rst(rst), .enable(en));

      //KEVIN: Added this for stalling logic
      dff dff_IDEX_instructionMemoryStall_out(.d(instructionMemoryStall_in), .q(instructionMemoryStall_out), .clk(clk), .rst(rst), .enable(1'b1));
   //   dff dff_IDEX_WritingToRs_in_out(.d(instructionMemoryStall_in), .q(instructionMemoryStall_out), .clk(clk), .rst(rst), .enable(1'b1));

      dff dff_IDEX_ReadingRs_out(.d(ReadingRs_in), .q(ReadingRs_out), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_ReadingRt_out(.d(ReadingRt_in), .q(ReadingRt_out), .clk(clk), .rst(rst), .enable(en));

      // dff for SESel and RegDst
      dff dff_IDEX_SESel_out0(.d(SESel_in[0]), .q(SESel_out[0]), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_SESel_out1(.d(SESel_in[1]), .q(SESel_out[1]), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_SESel_out2(.d(SESel_in[2]), .q(SESel_out[2]), .clk(clk), .rst(rst), .enable(en));

      dff dff_IDEX_RegDst_out0(.d(RegDst_in[0]), .q(RegDst_out[0]), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_RegDst_out1(.d(RegDst_in[1]), .q(RegDst_out[1]), .clk(clk), .rst(rst), .enable(en));
      dff dff_IDEX_BorJ_out(.d(BranchingOrJumping_in), .q(BranchingOrJumping_out), .clk(clk), .rst(rst), .enable(en)); 

      //Want to store a bunch of control signals here
      
endmodule