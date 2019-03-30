module Hazard_Detector (instruction, stall, PC_Write_Enable, IF_ID_WriteEnable);

	input [15:0] instruction;
	

	output stall, PC_Write_Enable, IF_ID_WriteEnable; 

	//Stall conditions
	//ID/EX.WriteRegister = IF/ID.ReadRegister1

	//ID/EX.WriteRegister = IF/ID.ReadRegister2

	//EX/MEM.WriteRegister = IF/ID.ReadRegister1

	//EX/MEM.WriteRegister = IF/ID.ReadRegister2

	//Mem/WB.WriteRegister = IF/ID.ReadRegister1

	//MEM/WB.WriteRegister = IF/ID.ReadRegister2


endmodule
