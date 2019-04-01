module IF_ID_Latch ( instruction_in, PC_In, en, clk, rst, 
                    instruction_out, PC_Out, BranchingOrJumping_in);

      //Input from instruction memory
      input [15:0] instruction_in, PC_In; 
      input en, clk, rst, BranchingOrJumping_in;
      output [15:0] instruction_out, PC_Out; 


      // if rst is asserted, set instruction to the NOP opcode 
      wire [15:0] instruction_in_NOP_sel;
      assign instruction_in_NOP_sel = (rst | BranchingOrJumping_in) ?  16'b0000100000000000 : instruction_in;

      // use 16 bit registers to decide if we should use current saved output or update output for
      // the PC and the instruction
      register_16bits rf_instruction(.readData(instruction_out), .clk(clk), .rst(1'b0), // TODO: should this really always be 0???
                                     .writeData(instruction_in_NOP_sel), /*instruction_in_NOP_sel*/
                                     .writeEnable(en));

      register_16bits rf_PC(.readData(PC_Out), .clk(clk), 
                            .rst(rst), .writeData(PC_In), 
                            .writeEnable(en));

endmodule 

