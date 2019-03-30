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
  wire [15:0] IF_ID_instruction_Out, IF_ID_PC_Out;

  // write register that is calculated in execute stage. Goes into Hazard Detector
  wire [2:0] executeWriteRegister;

  // write regs after being pipelined through EX_MEM and MEM_WB
  wire [2:0] EX_MEM_writeRegister_out, MEM_WB_writeRegister_out;


  wire [2:0] ID_EX_SESel_out;
  wire [1:0] ID_EX_RegDst_out;

        
   wire createDump, errDecode , JAL_en;

   // signals for hazard detector
   wire PC_WriteEn, IF_ID_WriteEn, stall;

   
   /*
   * This module instantiates the fetch_instruction_Out memory and the PC Register to keep track of the current PC
   * there is also an adder instantiated here to increment the PC
  */  
  // ################################################### FETCH #######################################################
  fetchInstruction      instructionFetch(.clk(clk), .rst(rst), .PC_In(updatedPC), 
							/* TODO: fix dump  */		     .dump(createDump), .PC_Next(fetch_next_PC_normal), 
									     .instruction(fetch_instruction_Out));


  // ################################################### IF_ID_Stage #######################################################

   //TODO: Maybe need another PC output???
   // Many of these signals probably not correct, including instruction_in. 3/29
   IF_ID_Latch          IF_ID_Stage (.instruction_in(fetch_instruction_Out), 
                                    .instruction_out(IF_ID_instruction_Out),
                                    .en(1'b1),  /* TODO: change to this IF_ID_WriteEnable*/
                                    .clk(clk), .rst(rst),
                                    .PC_In(fetch_next_PC_normal), .PC_Out(IF_ID_PC_Out));


  /*
   * This module instantiates the control unit and the register file. The control decides what to do 
   * with the fetch_instruction_Out and the register file is told what to do. The control unit also makes
   * signals like SESelect which the regFile doesn't use.
   */
   // ################################################### DECODE #######################################################
  decodeInstruction     instructionDecode(.clk(clk), .rst(rst), .writeData(writeData), 
									      .instruction(IF_ID_instruction_Out), 
									      .err(errDecode), .dump(createDump),
									      .writeRegister(MEM_WB_writeRegister_out),
                                          .A(alu_A), .B(alu_B));

  // ################################################### DETECT HAZARDS #######################################################


  Hazard_Detector       detectHazards (.IF_ID_WriteEnable(IF_ID_WriteEn), .stall(stall), 
  									   .instruction(IF_ID_instruction_Out), .PC_Write_Enable(PC_WriteEn) );



  // ################################################### ID_EX Stage #######################################################

  //TODO: connect a few signals
  ID_EX_Latch           ID_EX_Stage (.clk(clk), .rst(rst), .en(1'b1), //TODO: Fix Enable
                                     .A_in(alu_A), 
                                     .B_in(alu_B),

                                     .stall(detectHazards.stall),

                                     .PC_In(IF_ID_PC_Out), 
                                     .instruction_in(IF_ID_instruction_Out), 
                                      // Sign Extended Signals
                                     .S_extend5_in(instructionDecode.signExtend5.out),                                    
                                     .Z_extend5_in(instructionDecode.zeroExtend5.out),                                      
                                     .S_extend8_in(instructionDecode.signExtend8.out),                                     
                                     .Z_extend8_in(instructionDecode.zeroExtend8.out),  
                                     .S_extend11_in(instructionDecode.signExtend11.out), 
                                      // Control Signals
                                     .RegWrite_in(instructionDecode.controlUnit.RegWrite),                                
                                     .DMemWrite_in(instructionDecode.controlUnit.DMemWrite),
                                     .DMemEn_in(instructionDecode.controlUnit.DMemEn),
                                     .MemToReg_in(instructionDecode.controlUnit.MemToReg),
                                     .DMemDump_in(instructionDecode.controlUnit.DMemDump), 			// TODO: Fix when dump is being asserted
                                     .invA_in(instructionDecode.controlUnit.invA), 
                                     .invB_in(instructionDecode.controlUnit.invB),
                                     .Cin_in(instructionDecode.controlUnit.Cin), 
                                     .ALUSrc2_in(instructionDecode.controlUnit.ALUSrc2),
                                     .Branching_in(instructionDecode.controlUnit.Branching),

                                     .SESel_in(instructionDecode.controlUnit.SESel), 
                                     .SESel_out(ID_EX_SESel_out),
                                     .RegDst_in(instructionDecode.controlUnit.RegDst),
                                     .RegDst_out(ID_EX_RegDst_out));

                                     
                                     

   // ################################################### EXECUTE #######################################################
  executeInstruction    instructionExecute(.instr(ID_EX_Stage.rf_IDEX_instruction_out.readData), 
  										   .next_PC_normal(ID_EX_Stage.rf_IDEX_PC_Out.readData), 
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
                                           .Branching(ID_EX_Stage.dff_IDEX_Branching_out.q), // I don' think we need branching after this

                                           .SESel(ID_EX_SESel_out),
                                           .RegDst(ID_EX_RegDst_out),

                                           	//OUTPUT
                                           .writeRegister(executeWriteRegister), // --> hazard detector
                                           .aluOutput(aluOutput), .updatedPC(updatedPC), .reg7_En(JAL_en));


  // ################################################### EX_MEM Stage #######################################################


  EX_MEM_Latch          EX_MEM_Stage (.clk(clk), .rst(rst), .en(1'b1), /*TODO: Fix enable */ 

									  .RegWrite_in(ID_EX_Stage.dff_IDEX_RegWrite_out.q), 
									  .DMemWrite_in(ID_EX_Stage.dff_IDEX_DMemWrite_out.q), 
									  .DMemEn_in(ID_EX_Stage.dff_IDEX_DMemEn_in_out.q), 
									  .MemToReg_in(ID_EX_Stage.dff_IDEX_MemToReg_out.q),
									  .DMemDump_in(ID_EX_Stage.dff_IDEX_DMemDump_out.q), 
									  .Branching_in(ID_EX_Stage.dff_IDEX_Branching_out.q),

									  .WriteRegister_in(executeWriteRegister), .WriteRegister_out(EX_MEM_writeRegister_out),

									  .Jump_in(JAL_en),
									  .aluOutput_in(aluOutput), 

									  .B_in(ID_EX_Stage.rf_IDEX_Bout.readData), 
									  .updatedPC_in(ID_EX_Stage.rf_IDEX_PC_Out.readData));
									  



  // ################################################### MEMORY #######################################################
  memoryReadWrite       dataMemory (.clk(clk), .rst(rst), 
  									.writeData(EX_MEM_Stage.rf_EXMEM_B_out.readData),
  									.aluOutput(EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData),

  									.memWrite(EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q),
        
                                    .memRead(EX_MEM_Stage.dff_EXMEM_DMemEn_out.q),
                                    
                                    .dump(EX_MEM_Stage.dff_EXMEM_DMemDump_out.q),
                                    .readData(readData)); //output


  // ################################################### MEM_WB Stage #######################################################


  MEM_WB_Latch          MEM_WB_Stage (.clk(clk), .rst(rst), .en(1'b1), /*TODO: Fix enable */ 

									  .Branching_in(EX_MEM_Stage.dff_EXMEM_Branching_out.q), // What are we doing with Branching signal??
									  .RegWrite_in(EX_MEM_Stage.dff_EXMEM_RegWrite_out.q), 
									  .DMemEn_in(EX_MEM_Stage.dff_EXMEM_DMemEn_out.q),
									  .MemToReg_in(EX_MEM_Stage.dff_EXMEM_MemToReg_in_out.q),
									  .Jump_in(EX_MEM_Stage.dff_EXMEM_Jump_out.q),
									  

									  .WriteRegister_in(EX_MEM_writeRegister_out), .WriteRegister_out(MEM_WB_writeRegister_out),

									   .updatedPC_in(EX_MEM_Stage.rf_EXMEM_updatedPC_out.readData),
									  .aluOutput_in(EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData), 
									  .readData_in(readData));

  // ################################################### WRITEBACK #######################################################
  writebackOutput       instructionWriteback(.writeData(writeData), 

  											 .readData(MEM_WB_Stage.rf_MEMWB_readData_out.readData), 
  											 .aluOutput(MEM_WB_Stage.rf_MEMWB_aluOutput_out.readData),
  											 .PC_Next(MEM_WB_Stage.rf_MEMWB_updatedPC_in_out.readData), // Not sure if right

                                             .memToReg(MEM_WB_Stage.dff_MEMWB_MemToReg_in_out.q),
                                             .JAL_en(MEM_WB_Stage.dff_MEMWB_Jump_in_out.q));
						
  
	 //assign err = 0;
	 assign err = (errDecode | instructionExecute.mainALU.err | instructionDecode.regFile.err );

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
