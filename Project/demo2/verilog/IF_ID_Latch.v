module IF_ID_Latch ( instruction_in, PC_In, en, clk, rst, 
                    IF_ID_instruction_out, PC_Out);

      //Input from instruction memory
      input [15:0] instruction_in, PC_In; 
      input en, clk, rst; 
      output [15:0] IF_ID_instruction_out, PC_Out; 




      // if rst is asserted, set instruction to the NOP opcode 
      wire [15:0] instruction_in_NOP_sel, instruction_out; 
      assign instruction_in_NOP_sel = (rst) ? 16'b00001_xxxxxxxxxxx : instruction_in;

      // use 16 bit registers to decide if we should use current saved output or update output for
      // the PC and the instruction
      register_16bits rf_instruction(.readData(instruction_out), .clk(clk), .rst(rst), 
                                     .writeData(instruction_in_NOP_sel), 
                                     .writeEnable(en));

      register_16bits rf_PC(.readData(PC_Out), .clk(clk), 
                            .rst(rst), .writeData(PC_In), 
                            .writeEnable(en));

      // TODO: Another output for PC
      //register_16bits rf_PC_2(.out(anotherPCOut), .in(instrInSel), .en(en), .rst(1'b0), .clk(clk));

endmodule 

