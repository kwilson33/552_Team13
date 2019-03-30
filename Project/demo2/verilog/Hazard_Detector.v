module Hazard_Detector ();

	input [15:0] instruction;
	input 

	output stall, pc_write_en, IF_ID_write_en; 


	

	//Stall conditions
	//ID/EX.WriteRegister = IF/ID.ReadRegister1

	//ID/EX.WriteRegister = IF/ID.ReadRegister2

	//EX/MEM.WriteRegister = IF/ID.ReadRegister1

	//EX/MEM.WriteRegister = IF/ID.ReadRegister2

	//Mem/WB.WriteRegister = IF/ID.ReadRegister1

	//MEM/WB.WriteRegister = IF/ID.ReadRegister2


endmodule
