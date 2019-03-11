/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As described in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   /* your code here */


   // signals for the fetch, decode, memory, and execute
   wire [15:0] currentPC, nextPC, instruction;
			   data_out, data_in, writeData;
			    
   wire enable, wr, createDump;

   
   /*
   * This module instantiates the instruction memory and the PC Register to keep track of the current PC
   * there is also an adder instantiated here to increment the PC
  */  
  fetchInstruction instructionFetch(.clk(clk), .rst(rst), .PC_In(currentPC), 
									.dump(createDump), .PC_Next(nextPC), 
									.instruction(instruction));
   
  /*
   * This module instantiates the control unit and the register file. The control decides what to do 
   * with the instruction and the register file is told what to do. The control unit also makes
   * signals like SESelect which the regFile doesn't use.
   */
  decodeInstruction instructionDecode(.clk(clk), .rst(rst), .writeData(writeData), 
									  .instruction(instruction), .err(err));
						
  
	 
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
