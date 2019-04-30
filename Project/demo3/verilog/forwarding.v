module forwarding(IDEX_Rs, IDEX_Rt, EXMEM_Rd, 
				 MEMWB_Rd, MEMWB_RegWrite,
				 EXMEM_RegWrite, nakedA, nakedB, fwMEM, 
				 fwEX, ReadingRs_IDEX, ReadingRt_IDEX, ReadingRs_EXMEM, 
				 EXMEM_Rs, MEMWB_Rs);

input [15:0] nakedA, nakedB, fwMEM, fwEX;  

input [2:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd, EXMEM_Rs, MEMWB_Rs; 
input		MEMWB_RegWrite, EXMEM_RegWrite, 
			ReadingRs_IDEX, ReadingRt_IDEX, ReadingRs_EXMEM; 


wire   fw_EXMEM_Rs, fw_EXMEM_Rt, 
	   fw_MEMWB_Rs, fw_MEMWB_Rt; 

wire [15:0] chosenAluA, chosenAluB; 

//EX_MEM FORWARDING CONDITIONS
//Not MEM READ???

// if !alusrc2(i format) check if EXMEM_Rs == IDEX_Rs
assign fw_EXMEM_Rs = (EXMEM_RegWrite  & (EXMEM_Rd == IDEX_Rs))| // check if we're writing to a reg and if Rd == Rs
					(~ReadingRs_EXMEM & (IDEX_Rs == EXMEM_Rs)) & // or if a LBI check if Rs == Rs
					 ReadingRs_IDEX ? 1'b1 : 1'b0;  // and that we're reading Rs

assign fw_EXMEM_Rt = (EXMEM_RegWrite  & (EXMEM_Rd == IDEX_Rt)) | 
					(~ReadingRs_EXMEM & (IDEX_Rt == EXMEM_Rs))&  
					ReadingRt_IDEX ? 1'b1 : 1'b0; 


//MEM_WB FORWARDING CONDITIONS

assign fw_MEMWB_Rs = (MEMWB_RegWrite & (MEMWB_Rd == IDEX_Rs)) |
					 (~ReadingRs_EXMEM & (IDEX_Rs == MEMWB_Rs)) &
					 ReadingRs_IDEX ? 1'b1 : 1'b0;

					
assign fw_MEMWB_Rt = (MEMWB_RegWrite & (MEMWB_Rd == IDEX_Rt))|
					 (~ReadingRs_EXMEM & (IDEX_Rt == MEMWB_Rs)) &
					 ReadingRt_IDEX ? 1'b1 : 1'b0; 

assign chosenAluA = (fw_EXMEM_Rs) ? fwEX : (fw_MEMWB_Rs) ? fwMEM : nakedA; 
assign chosenAluB = (fw_EXMEM_Rt) ? fwEX : (fw_MEMWB_Rt) ? fwMEM : nakedB; 

endmodule