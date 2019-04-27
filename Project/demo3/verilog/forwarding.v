module forwarding(IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd, MEMWB_WriteReg, EXMEM_WriteReg
				  fw_EXMEM_Rs, fw_EXMEM_Rt, fw_MEMWB_Rs, fw_MEMWB_Rt);

input [2:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd; 
input		MEMWB_WriteReg, EXMEM_WriteReg; 


output fw_EXMEM_Rs, fw_EXMEM_Rt, 
	   fw_MEMWB_Rs, fw_MEMWB_Rt; 


//EX_MEM FORWARDING CONDITIONS

assign fw_EXMEM_Rs = (EXMEM_WriteReg & (EXMEM_Rd != 0) & (EXMEM_Rd == IDEX_Rs)) ? 1'b1 : 1'b0; 
assign fw_EXMEM_Rt = (EXMEM_WriteReg & (EXMEM_Rd != 0) & (EXMEM_Rd == IDEX_Rt)) ? 1'b1 : 1'b0; 


//MEM_WB FORWARDING CONDITIONS

assign fw_MEMWB_Rs = (MEMWB_WriteReg & (MEMWB_Rd != 0) & (MEMWB_Rd == IDEX_Rs)) ? 1'b1 : 1'b0;
assign fw_MEMWB_Rt = (MEMWB_WriteReg & (MEMWB_Rd != 0) & (MEMWB_Rd == IDEX_Rt)) ? 1'b1 : 1'b0; 

endmodule