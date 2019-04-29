module forwarding(IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd, MEMWB_WriteReg, EXMEM_WriteReg, nakedA, nakedB, fwMEM, fwEX);

input [15:0] nakedA, nakedB, fwMEM, fwEX;  

input [2:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd; 
input		MEMWB_WriteReg, EXMEM_WriteReg; 


wire   fw_EXMEM_Rs, fw_EXMEM_Rt, 
	   fw_MEMWB_Rs, fw_MEMWB_Rt; 

wire [15:0] chosenAluA, chosenAluB; 

//EX_MEM FORWARDING CONDITIONS

assign fw_EXMEM_Rs = (EXMEM_WriteReg  & (EXMEM_Rd == IDEX_Rs)) ? 1'b1 : 1'b0; 
assign fw_EXMEM_Rt = (EXMEM_WriteReg  & (EXMEM_Rd == IDEX_Rt)) ? 1'b1 : 1'b0; 


//MEM_WB FORWARDING CONDITIONS

assign fw_MEMWB_Rs = (MEMWB_WriteReg & (MEMWB_Rd == IDEX_Rs)) ? 1'b1 : 1'b0;
assign fw_MEMWB_Rt = (MEMWB_WriteReg & (MEMWB_Rd == IDEX_Rt)) ? 1'b1 : 1'b0; 

assign chosenAluA = (fw_EXMEM_Rs) ? fwEX : (fw_MEMWB_Rs) ? fwMEM : nakedA; 
assign chosenAluB = (fw_EXMEM_Rt) ? fwEX : (fw_MEMWB_Rt) ? fwMEM : nakedB; 

endmodule