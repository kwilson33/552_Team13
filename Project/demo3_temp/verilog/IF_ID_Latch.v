module IF_ID_Latch ( instruction_in, PC_In, en, clk, rst, 
                    instruction_out, PC_Out, BranchingOrJumping_in,
                    instructionMemoryStall,
                    valid_out);

      //Input from instruction memory
      input [15:0] instruction_in, PC_In; 
      input en, clk, rst, BranchingOrJumping_in,instructionMemoryStall;

      output [15:0] instruction_out, PC_Out; 
      output valid_out;

      // if rst is asserted, set instruction to the NOP opcode 
      wire [15:0] instruction_in_NOP_sel;
      // this goes into control.v and will determine if DMemDump should actually be asserted
      wire valid_in;

      assign instruction_in_NOP_sel = (rst | BranchingOrJumping_in) ?  16'b0000100000000000 : instruction_in;
      
      // if we have a random stall from instr mem, then we should NOT halt
      assign valid_in = ~(rst | instructionMemoryStall);
      dff dff_IF_ID_valid_out(.d(valid_in), .q(valid_out), .clk(clk), .rst(rst), .en(en));

      // use 16 bit registers to decide if we should use current saved output or update output for
      // the PC and the instruction
      register_16bits regFile_instruction(.readData(instruction_out), .clk(clk), .rst(1'b0), // TODO: should this really always be 0???
                                     .writeData(instruction_in_NOP_sel), /*instruction_in_NOP_sel*/
                                     .writeEnable(en));

      register_16bits regFile_PC(.readData(PC_Out), .clk(clk), 
                            .rst(rst), .writeData(PC_In), 
                            .writeEnable(en));

endmodule 

