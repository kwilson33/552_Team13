module Hazard_Detector ();

	input [15:0] instruction;
	input 

	output stall, pc_write_en, IF_ID_write_en; 

	//Stall conditions
	//Practice Midterm Solution --- JK don't use these it says not for general case!!!!
	//ED/EX.RegWrite = 1 and ID/EX.MemRead = 1 and IF/ID.Rs = ID/Ex.Rt

	//ID/EX.RegWrite = 0 and EX/MEM.RegWrite = 1 and EX/MEM.MemRead = 1 and IF/ID.Rs = EX/MEM.Rd.

	//EX/MEM.RegWrite = 1 and ID/EX.Rt

endmodule
