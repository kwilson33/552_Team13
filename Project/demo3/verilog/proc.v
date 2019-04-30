/* $Author: karu $ */
/* $LastChangedDate: 3/29/19, Kevin, Mark, and Apoorva
/* $Rev: 45 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk, rst;
   output err;

   // signals for the fetch, decode, memory, and execute
   wire [15:0] updatedPC, nextPC_from_fetch, 
              fetch_instruction_Out, 
			        readData, writeData,
              // alu_B is the register we're storing into memory
              aluOutput, alu_A, alu_B;

  wire [15:0] IF_ID_instruction_Out, IF_ID_PC_Out;

              // write register that is calculated in execute stage. Goes into Hazard Detector
  wire [2:0] executeWriteRegister,
            // outputs of pipeline latches
            EX_MEM_writeRegister_out, 
            MEM_WB_writeRegister_out,  
            ID_EX_SESel_out;
  wire [1:0] ID_EX_RegDst_out;

   wire createDump, errDecode , JAL_en, 
        EX_branchingPCEnable_to_EX_MEM,
        ALUSrc2_connector, 
        masterBorJ,
        // signals for hazard detector
        PC_WriteEn_from_hazardDet, IF_ID_WriteEn,
        instructionMemoryStall_out, 
        dataMemoryStallOut, dataMemoryDoneOut,
        IF_ID_valid_out;

   assign err = (errDecode |
                 instructionExecute.mainALU.err | 
                 instructionDecode.regFile.err |
                 instructionFetch.instructionMemory.err|
                 dataMemory.dataMemoryModule.err);

   assign masterBorJ = (instructionDecode.controlUnit.BranchingOrJumping | 
                        ID_EX_Stage.dff_IDEX_BorJ_out.q |
                        EX_MEM_Stage.dff_EXMEM_BorJ_out.q |
                        MEM_WB_Stage.dff_MEMWB_BorJ_out.q); 
   

   /*
   * This module instantiates the fetch_instruction_Out memory and the PC Register to keep track of the current PC
   * there is also an adder instantiated here to increment the PC
  */  
  // ################################################### FETCH #######################################################
  fetchInstruction     instructionFetch(.clk(clk), .rst(rst), 
                      .PC_In(MEM_WB_Stage.rf_MEMWB_updatedPC_out.readData), 
								     	.dump(createDump), 
								     	.PC_Next(nextPC_from_fetch), 
                      .PC_WriteEn_in(PC_WriteEn_from_hazardDet),
									    .instruction(fetch_instruction_Out),
                      .branchingPCEnable_in(masterBorJ /*| dataMemoryDoneOut*/), // TODO: not sure if right branching signal or if dataMemDone should be here
                      .stall(stall_from_HazardDet),
                      .instructionMemoryStall_out(instructionMemoryStall_out),
                      .MEM_WB_Branch_in(MEM_WB_Stage.dff_MEMWB_branchingPCEnable_out.q),
                      .dataMemoryStallOut(dataMemoryStallOut));

  // ################################################### IF_ID_Stage #######################################################

   IF_ID_Latch          IF_ID_Stage (.instruction_in(fetch_instruction_Out), 
                                    .instruction_out(IF_ID_instruction_Out),
                                    .en(IF_ID_WriteEn & ~dataMemoryStallOut), 
                                    .clk(clk), .rst(rst),
                                    .PC_In(nextPC_from_fetch), 
                                    .PC_Out(IF_ID_PC_Out),
                                    .instructionMemoryStall(instructionMemoryStall_out),
                                    .valid_out(IF_ID_valid_out),
                                    .BranchingOrJumping_in(masterBorJ));

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
                        .RegWrite_in(MEM_WB_Stage.dff_MEMWB_RegWrite_out.q), // maybe add the stall from mem module  here 
                        .A(alu_A), .B(alu_B), .valid_in(IF_ID_valid_out));

  // ################################################### DETECT HAZARDS #######################################################


  Hazard_Detector       detectHazards (.IF_ID_WriteEnable_out(IF_ID_WriteEn), 
                                        .stall(stall_from_HazardDet), 
  									                   .PC_Write_Enable_out(PC_WriteEn_from_hazardDet),
                  									   .ID_EX_RegWrite_in(ID_EX_Stage.dff_IDEX_RegWrite_out.q), 
                  									   .EXMEM_RegWrite_in(EX_MEM_Stage.dff_EXMEM_RegWrite_out.q),
                  									   .EXMEM_DMemEn_in(EX_MEM_Stage.dff_EXMEM_DMemEn_out.q),
                  									   .EXMEM_DMemWrite_in(EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q), 
                  									   .IF_ID_Rs_in(IF_ID_instruction_Out[10:8]), 
                  									   .IF_ID_Rt_in(IF_ID_instruction_Out[7:5]), 
                  									   .ID_EX_WriteRegister_in(executeWriteRegister), 
                  									   .EX_Mem_WriteRegister_in(EX_MEM_writeRegister_out),
                                       .ReadingRs_in(instructionDecode.controlUnit.ReadingRs),
                                       .ReadingRt_in(instructionDecode.controlUnit.ReadingRt));

  // ################################################### ID_EX Stage #######################################################

  //TODO: connect a few signals
  ID_EX_Latch           ID_EX_Stage (.clk(clk), .rst(rst), //.en(1'b1), //TODO: Fix Enable??
                                     .en(~dataMemoryStallOut),
                                     .A_in(alu_A),
                                       
                                        
                                     .B_in(alu_B),

                                     .stall(stall_from_HazardDet),

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
                                     .DMemDump_in(instructionDecode.controlUnit.DMemDump), 			
                                     .invA_in(instructionDecode.controlUnit.invA), 
                                     .invB_in(instructionDecode.controlUnit.invB),
                                     .Cin_in(instructionDecode.controlUnit.Cin), 
                                     .ALUSrc2_in(instructionDecode.controlUnit.ALUSrc2), 
                                     
                                     .Branching_in(instructionDecode.controlUnit.Branching),
									                   .ReadingRs_in(instructionDecode.controlUnit.ReadingRs),
									                   .ReadingRt_in(instructionDecode.controlUnit.ReadingRt),
                                     .SESel_in(instructionDecode.controlUnit.SESel), 
                                     .SESel_out(ID_EX_SESel_out),
                                     .RegDst_in(instructionDecode.controlUnit.RegDst),
                                     .RegDst_out(ID_EX_RegDst_out),

                                     .BranchingOrJumping_in(instructionDecode.controlUnit.BranchingOrJumping));
                                                                   
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
                                           .Branching(ID_EX_Stage.dff_IDEX_Branching_out.q), 

                                           .SESel(ID_EX_SESel_out),
                                           .RegDst(ID_EX_RegDst_out),

                                           	//OUTPUT
                                           .writeRegister(executeWriteRegister), // --> hazard detector
                                           .aluOutput(aluOutput), .updatedPC(updatedPC), .reg7_En(JAL_en),
                                           .branchingPCEnable_out(EX_branchingPCEnable_to_EX_MEM));

  // ################################################### EX_MEM Stage #######################################################


  EX_MEM_Latch          EX_MEM_Stage (.clk(clk), .rst(rst), //.en(1'b1), /*TODO: Fix enable */ 
                                      .en(~dataMemoryStallOut /*& ~instructionMemoryStall_out*/),
									  .RegWrite_in(ID_EX_Stage.dff_IDEX_RegWrite_out.q), 
									  .DMemWrite_in(ID_EX_Stage.dff_IDEX_DMemWrite_out.q), 
									  .DMemEn_in(ID_EX_Stage.dff_IDEX_DMemEn_in_out.q), 
									  .MemToReg_in(ID_EX_Stage.dff_IDEX_MemToReg_out.q),
									  .DMemDump_in(ID_EX_Stage.dff_IDEX_DMemDump_out.q), 
									  .Branching_in(ID_EX_Stage.dff_IDEX_Branching_out.q),
										.ReadingRs_in(ID_EX_Stage.dff_IDEX_ReadingRs_out.q),
									  .ReadingRt_in(ID_EX_Stage.dff_IDEX_ReadingRt_out.q),
									  .WriteRegister_in(executeWriteRegister), .WriteRegister_out(EX_MEM_writeRegister_out),
									  .Jump_in(JAL_en),
									  .aluOutput_in(aluOutput), 
									  .B_in(ID_EX_Stage.rf_IDEX_Bout.readData), 

                    .nextPC_in(ID_EX_Stage.rf_IDEX_PC_Out.readData), // this is from ID_EX, not updated
									  .updatedPC_in(updatedPC),  // this contains address a jump or branch should go to

                    .branchingPCEnable_in(EX_branchingPCEnable_to_EX_MEM),
                    .BranchingOrJumping_in(ID_EX_Stage.dff_IDEX_BorJ_out.q));
									  
  // ################################################### MEMORY #######################################################
  memoryReadWrite       dataMemory (.clk(clk), .rst(rst), 
  									.writeData(EX_MEM_Stage.rf_EXMEM_B_out.readData),
  									.aluOutput(EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData),
  									.memWrite(EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q),
                    .memRead(EX_MEM_Stage.dff_EXMEM_DMemEn_out.q),  
                    .dump(EX_MEM_Stage.dff_EXMEM_DMemDump_out.q),
                    .readData(readData),
                    .dataMemoryStallOut(dataMemoryStallOut),
                    .dataMemoryDoneOut(dataMemoryDoneOut)); //output

  // ################################################### MEM_WB Stage #######################################################

  MEM_WB_Latch      MEM_WB_Stage (.clk(clk), .rst(rst), //.en(~dataMemoryStallOut), 
                    .en(1'b1),

                   //Send NOP into write regwrite_in

									  .Branching_in(EX_MEM_Stage.dff_EXMEM_Branching_out.q), 
									  .RegWrite_in(EX_MEM_Stage.dff_EXMEM_RegWrite_out.q),
									//.RegWrite_in(EX_MEM_Stage.NOP_or_regular), 
									  .DMemEn_in(EX_MEM_Stage.dff_EXMEM_DMemEn_out.q),
									  .MemToReg_in(EX_MEM_Stage.dff_EXMEM_MemToReg_in_out.q),
									  .Jump_in(EX_MEM_Stage.dff_EXMEM_Jump_out.q),
                    .DMemDump_in(EX_MEM_Stage.dff_EXMEM_DMemDump_out.q),
					           .ReadingRs_in(EX_MEM_Stage.dff_EXMEM_ReadingRs_out.q),
									   .ReadingRt_in(EX_MEM_Stage.dff_EXMEM_ReadingRt_out.q),
                    .updatedPC_in(EX_MEM_Stage.rf_EXMEM_updatedPC_out.readData),
                    .nextPC_in(EX_MEM_Stage.rf_EXMEM_nextPC_out.readData), 
									  
									  .WriteRegister_in(EX_MEM_writeRegister_out), .WriteRegister_out(MEM_WB_writeRegister_out),

                    
                    .branchingPCEnable_in(EX_MEM_Stage.dff_EXMEM_branchingPCEnable_out.q),
                    .BranchingOrJumping_in(EX_MEM_Stage.dff_EXMEM_BorJ_out.q), 
									   
									  .aluOutput_in(EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData), 
									  .readData_in(readData));

  // ################################################### WRITEBACK #######################################################
  writebackOutput       instructionWriteback(
                         .writeData(writeData), 
  											 .readData(MEM_WB_Stage.rf_MEMWB_readData_out.readData), 
  											 .aluOutput(MEM_WB_Stage.rf_MEMWB_aluOutput_out.readData),
  											 .PC_Next(MEM_WB_Stage.rf_MEMWB_nextPC_out.readData),

                         .memToReg(MEM_WB_Stage.dff_MEMWB_MemToReg_in_out.q),
                         .JAL_en(MEM_WB_Stage.dff_MEMWB_Jump_in_out.q));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
