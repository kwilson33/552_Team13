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


   // signals for the memory modules
   wire [15:0] data_in, addr, data_out, writeData;
   wire enable, wr,  createdump;

   // signals for decoder that reads instruction.
   // Error output of processor comes from decoder
   

   wire [15:0] instruction;

   // instantiate memory module twice. One for instruction memory
   // and another for data memory
   memory2c instrMem (.data_in(data_in), .addr(addr),
	                   .enable(enable), .wr(wr), .clk(clk), .rst(rst),
	                   .createdump(createdump), .data_out(data_out)),

	         dataMem   (.data_in(data_in), .addr(addr),
	       	           .enable(enable), .wr(wr), .clk(clk), .rst(rst),
	                    .createdump(createdump), .data_out(data_out));
  
  /*
   * this module instantiates the control unit and the register file. The control decides what to do 
   * with the instruction and the register file is told what to do. The control unit also makes
   * signals like SESelect which the regFile doesn't use.
   */
  decodeInstruction decodeInstruction(.clk(clk), .rst(rst), .writeData(writeData), .instruction(instruction),
                                       .err(err));
	 
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
