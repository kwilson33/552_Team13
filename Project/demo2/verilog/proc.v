/* $Author: karu $ */
/* $LastChangedDate: 3/29/19
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

   // signals for the fetch, decode, memory, and execute
   wire [15:0] updatedPC, fetch_next_PC_normal, fetch_instruction_Out, 
			   readData, writeData,
         // alu_B is the register we're storing into memory
         aluOutput, alu_A, alu_B;

  // Added 3/29
  wire [15:0] IF_ID_instruction_Out, IF_ID_WriteEnable, IF_ID_PC_Out;
        
   wire createDump, errDecode , JAL_en;

   
   /*
   * This module instantiates the fetch_instruction_Out memory and the PC Register to keep track of the current PC
   * there is also an adder instantiated here to increment the PC
  */  
  // ################################################### FETCH #######################################################
  fetchInstruction      instructionFetch(.clk(clk), .rst(rst), .PC_In(updatedPC), 
									                       .dump(createDump), .PC_Next(fetch_next_PC_normal), 
									                       .fetch_instruction_Out(fetch_instruction_Out));


  // ################################################### IF_ID_Stage #######################################################

   //TODO: Maybe need another PC output???
   // Many of these signals probably not correct, including instruction_in. 3/29
   IF_ID_Latch          IF_ID_Stage (.instruction_in(fetch_instruction_Out), 
                                    .instruction_out(IF_ID_instruction_Out),
                                    .en(IF_ID_WriteEnable), 
                                    .clk(clk), .rst(rst),
                                    .PC_In(fetch_next_PC_normal), .PC_Out(IF_ID_PC_Out));


  /*
   * This module instantiates the control unit and the register file. The control decides what to do 
   * with the fetch_instruction_Out and the register file is told what to do. The control unit also makes
   * signals like SESelect which the regFile doesn't use.
   */
   // ################################################### DECODE #######################################################
  decodeInstruction     instructionDecode(.clk(clk), .rst(rst), .writeData(writeData), 
									                        .fetch_instruction_Out(IF_ID_instruction_out), .err(errDecode), .dump(createDump),
                                          .A(alu_A), .B(alu_B), .Cin(Cin));

  // ################################################### DETECT HAZARDS #######################################################


  Hazard_Detector       detectHazards ();



  // ################################################### ID_EX Stage #######################################################

  ID_EX_Latch           ID_EX_Stage ();



   // ################################################### EXECUTE #######################################################
  executeInstruction    instructionExecute(.reg7_En(JAL_en), .instr(fetch_instruction_Out), 
                                           .invA(instructionDecode.controlUnit.invA),
                                           .invB(instructionDecode.controlUnit.invB), 
                                           .Cin(Cin), 
                                           .SESel(instructionDecode.controlUnit.SESel),
                                           .ALUSrc2(instructionDecode.controlUnit.ALUSrc2),
                                           .Branching(instructionDecode.controlUnit.Branching),
                                           .A(alu_A), .B(alu_B), 
                                           .fetch_next_PC_normal(fetch_next_PC_normal), 
                                           .aluOutput(aluOutput), .updatedPC(updatedPC));


  // ################################################### EX_MEM Stage #######################################################


  EX_MEM_Latch          EX_MEM_Stage ();



  // ################################################### MEMORY #######################################################
  memoryReadWrite       dataMemory (.clk(clk), .rst(rst), .writeData(alu_B),
                                    .readData(readData), 
                                    .memRead(instructionDecode.controlUnit.DMemEn), 
                                    .memWrite(instructionDecode.controlUnit.DMemWrite),
                                    .aluOutput(aluOutput), .dump(createDump));


  // ################################################### MEM_WB Stage #######################################################


  MEM_WB_Latch          MEM_WB_Stage ();



  // ################################################### WRITEBACK #######################################################
  writebackOutput       instructionWriteback(.readData(readData), .writeData(writeData), 
                                             .aluOutput(aluOutput),
                                             .PC_Next(fetch_next_PC_normal), 
                                             .memToReg(instructionDecode.controlUnit.MemToReg), 
                                             .JAL_en(JAL_en));
						
  
	 assign err = (errDecode | instructionExecute.mainALU.err | instructionDecode.regFile.err );

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
