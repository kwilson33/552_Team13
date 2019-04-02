module Hazard_Detector (  ID_EX_RegWrite_in, 
						EXMEM_RegWrite_in, 
						EXMEM_DMemEn_in, 
						EXMEM_DMemWrite_in, 
						MEMWB_RegWrite_in,
						IF_ID_Rs_in, 
						IF_ID_Rt_in, 
						ID_EX_WriteRegister_in, 
						MEM_WB_WriteRegister_in, 
						EX_Mem_WriteRegister_in,
						stall, 
						PC_Write_Enable_out, 
						IF_ID_WriteEnable_out,
						Rt_select,
						J_and_JAL_in);

	input ID_EX_RegWrite_in, EXMEM_RegWrite_in, EXMEM_DMemEn_in, 
		  EXMEM_DMemWrite_in, MEMWB_RegWrite_in, 
		  Rt_select, J_and_JAL_in;
	input [2:0] IF_ID_Rs_in, IF_ID_Rt_in, EX_Mem_WriteRegister_in, 
				ID_EX_WriteRegister_in,
				MEM_WB_WriteRegister_in; 

	//TODO: HASAB?????????????????????????????????????????????????????????????????????????????????????????????????
	output stall, PC_Write_Enable_out, IF_ID_WriteEnable_out; 

	// use bits [10:8] of instruction to figure out what Rs should be 
	// use bits [7:5] of instruction to figure out what Rt should be 

	//Stall conditions

	//bits [10:8] = Rs = ReadRegister1 
	//ID/EX.WriteRegister = IF/ID.ReadRegister1

	wire 	ID_EX_raw_Rs, ID_EX_raw_Rt,
			EX_MEM_raw_Rs, EX_MEM_raw_Rt,
			MEM_WB_raw_Rs,MEM_WB_raw_Rt,
			ID_EX_stall, EX_MEM_stall, MEM_WB_stall;


	assign ID_EX_raw_Rs = (ID_EX_WriteRegister_in == IF_ID_Rs_in) & (~J_and_JAL_in); // If we are jumping, don't care about Rs 

	//bits [7:5] = Rt = ReadReg2
	//ID/EX.WriteRegister = IF/ID.ReadRegister2 
	assign ID_EX_raw_Rt = (ID_EX_WriteRegister_in == IF_ID_Rt_in) & Rt_select; // If ALUSrc2 is 1, then we are using Rt

	//EX/MEM.WriteRegister = IF/ID.ReadRegister1
	assign EX_MEM_raw_Rs = (EX_Mem_WriteRegister_in == IF_ID_Rs_in) & (~J_and_JAL_in); // If we are jumping, don't care about Rs 

	//EX/MEM.WriteRegister = IF/ID.ReadRegister2 (for Mem to Mem (LD & ST) forwarding make sure you don't stall)
	assign EX_MEM_raw_Rt = (EX_Mem_WriteRegister_in == IF_ID_Rt_in) & Rt_select; // If ALUSrc2 is 1, then we are using Rt

	
	//TODO : ask matt about this: fixed with bypassing
	//Mem/WB.WriteRegister = IF/ID.ReadRegister1
	assign MEM_WB_raw_Rs = (MEM_WB_WriteRegister_in == IF_ID_Rs_in) & (~J_and_JAL_in); // If we are jumping, don't care about Rs 

	//MEM/WB.WriteRegister = IF/ID.ReadRegister2 Rt 
	assign MEM_WB_raw_Rt = (MEM_WB_WriteRegister_in == IF_ID_Rt_in) & Rt_select; 
    

	//Stall Conditions
	assign ID_EX_stall = ID_EX_RegWrite_in & (ID_EX_raw_Rs | ID_EX_raw_Rt);
	assign EX_MEM_stall = EX_Mem_WriteRegister_in & (EX_MEM_raw_Rs | EX_MEM_raw_Rt);

	// Since we're doing bypassing, don't have to worry about this 
	assign MEM_WB_stall = MEM_WB_WriteRegister_in & (MEM_WB_raw_Rs | MEM_WB_raw_Rt);


	// outputs of Hazard Detector
	assign stall = (ID_EX_stall | EX_MEM_stall | MEM_WB_stall); // Since we're doing bypassing, don't have to worry about MEM_WB
	assign PC_Write_Enable_out = ~stall;
	assign IF_ID_WriteEnable_out = ~stall;



endmodule
