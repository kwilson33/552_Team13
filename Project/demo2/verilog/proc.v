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

  // write register that is calculated in execute stage. Goes into Hazard Detector
  wire [2:0] writeRegister;
        
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
									      .fetch_instruction_Out(IF_ID_instruction_out), 
									      .err(errDecode), .dump(createDump),
									      .writeRegister(0), /*writeRegister_MEM_WB),*/
                                          .A(alu_A), .B(alu_B));

  // ################################################### DETECT HAZARDS #######################################################


  Hazard_Detector       detectHazards ();



  // ################################################### ID_EX Stage #######################################################

  //TODO: connect a few signals
  ID_EX_Latch           ID_EX_Stage (.clk(clk), .rst(rst), .en(),

                                     .A_in(alu_A), 
                                    
                                     .B_in(alu_B),
                                     
                                     .PC_In(IF_ID_PC_Out), 

                                     .instruction_in(IF_ID_instruction_Out), 

                                     .S_extend5_in(decodeInstruction.signExtend5.out), 
                                    
                                     .Z_extend5_in(decodeInstruction.zeroExtend5.out), 
                                     
                                     .S_extend8_in(decodeInstruction.signExtend8.out), 
                                     
                                     .Z_extend8_in(decodeInstruction.zeroExtend8.out), 
                                     
                                     .S_extend11_in(decodeInstruction.signExtend11.out), 

                                     .RegWrite_in(instructionDecode.controlUnit.RegWrite),
                                
                                     .DMemWrite_in(instructionDecode.controlUnit.DMemWrite),
                                    
                                     .MemToReg_in(instructionDecode.controlUnit.MemToReg),
                                  
                                     .DMemDump_in(createDump), 
                                     
                                     .invA_in(instructionDecode.controlUnit.invA), 
                            
                                     .invB_in(instructionDecode.controlUnit.invB),

                                     .Cin_in(instructionDecode.controlUnit.Cin), 

                                     .SESel_in(instructionDecode.controlUnit.SESel), 

                                     .RegDst_in(instructionDecode.controlUnit.RegDst), 
                                
                                     .ALUSrc2_in(instructionDecode.controlUnit.ALUSrc2), 

                                     .stall(detectHazards.stall));



   // ################################################### EXECUTE #######################################################
  executeInstruction    instructionExecute(.reg7_En(JAL_en), 
  										   .instr(ID_EX_Stage.rf_IDEX_instruction_out.readData), 
  										   .A(ID_EX_Stage.rf_IDEX_Aout.readData), 
                                           .B(ID_EX_Stage.rf_IDEX_Bout.readData), 
                                           .S_extend5_in(ID_EX_Stage.rf_IDEX_S_extend5_out.readData), 
  										   .S_extend8_in(ID_EX_Stage.rf_IDEX_S_extend8_out.readData), 
  										   .S_extend11_in(ID_EX_Stage.rf_IDEX_S_extend11_out.readData),
						  				   .Z_extend8_in(ID_EX_Stage.rf_IDEX_Z_extend8_out.readData), 
						  				   .Z_extend5_in(ID_EX_Stage.rf_IDEX_Z_extend5_out.readData),
                                           .invA(ID_EX_Stage.dff_IDEX_invA_out.q),
                                           .invB(ID_EX_Stage.dff_IDEX_invB_out.q), 
                                           .Cin(ID_EX_Stage.dff_IDEX_Cin_out.q), 
                                           .ALUSrc2(ID_EX_Stage.dff_IDEX_ALUSrc2_out.q),
                                           .SESel(ID_EX_Stage.SESel_out),
                                           .RegDst(ID_EX_Stage.RegDst_out),
                                           .Branching(ID_EX_Stage.dff_IDEX_Branching_out.q),
                                           .next_PC_normal(ID_EX_Stage.rf_IDEX_PC_Out.readData), 

                                           	//OUTPUT
                                           .writeRegister(writeRegister), // --> hazard detector
                                           .aluOutput(aluOutput), .updatedPC(updatedPC));


  // ################################################### EX_MEM Stage #######################################################


  EX_MEM_Latch          EX_MEM_Stage (.clk(clk), .rst(rst), .en(), 
									  .RegWrite_in(), .DMemWrite_in(), .MemToReg_in(), 
									  .DMemDump_in(ID_EX_Stage.dff_IDEX_DMemDump_out.q), .Branching_in(), .Jump_in(),
									  .aluOutput_in(), .B_in(), .updatedPC_in());
									  



  // ################################################### MEMORY #######################################################
  memoryReadWrite       dataMemory (.clk(clk), .rst(rst), 
  									.writeData(EX_MEM_Stage.rf_EXMEM_B_out.readData),
  									.aluOutput(EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData),

  									.memWrite(EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q),
        
                                    .memRead(instructionDecode.controlUnit.DMemEn), //FIX
                                    
                                    .dump(EX_MEM_Stage.dff_EXMEM_DMemDump_out.q),
                                    .readData(readData)); //output


  // ################################################### MEM_WB Stage #######################################################


  MEM_WB_Latch          MEM_WB_Stage (.clk(clk), .rst(rst), .en(), 
									  .Branching_in(), .RegWrite_in(), .MemToReg_in(),
									  .aluOutput_in(), .readData_in());



  // ################################################### WRITEBACK #######################################################
  writebackOutput       instructionWriteback(.readData(readData), .writeData(writeData), 
                                             .aluOutput(aluOutput),
                                             .PC_Next(fetch_next_PC_normal), 
                                             .memToReg(instructionDecode.controlUnit.MemToReg), 
                                             .JAL_en(JAL_en));
						
  
	 assign err = (errDecode | instructionExecute.mainALU.err | instructionDecode.regFile.err );

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
