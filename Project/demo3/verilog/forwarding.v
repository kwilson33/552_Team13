module forwarding(IDEX_Rs, IDEX_Rt, EXMEM_Rd, 
				 MEMWB_Rd, MEMWB_RegWrite,
				 EXMEM_RegWrite, nakedA, nakedB, fwMEM, 
				 fwEX, ReadingRs_IDEX, ReadingRt_IDEX, ReadingRs_EXMEM, 
				 EXMEM_Rs, MEMWB_Rs, ReadingRs_MEMWB);

input [15:0] nakedA, nakedB, fwMEM, fwEX;  

input [2:0] IDEX_Rs, IDEX_Rt, EXMEM_Rd, MEMWB_Rd, EXMEM_Rs, MEMWB_Rs; 
input		MEMWB_RegWrite, EXMEM_RegWrite, 
			ReadingRs_IDEX, ReadingRt_IDEX, ReadingRs_EXMEM, ReadingRs_MEMWB; 


wire   fw_EXMEM_Rs, fw_EXMEM_Rt, 
	   fw_MEMWB_Rs, fw_MEMWB_Rt; 

wire [15:0] chosenAluA, chosenAluB; 

//EX_MEM FORWARDING CONDITIONS
//Not MEM READ???

					 // forward if: If we're writing after a read  and...
assign fw_EXMEM_Rs = (EXMEM_RegWrite & ReadingRs_IDEX)  &  
					// the destination reg Rd is the same as the source reg Rs or...
					(((EXMEM_Rd == IDEX_Rs)) | 
					 // if destination reg Rs is the same as Rs
					(~ReadingRs_EXMEM & (IDEX_Rs == EXMEM_Rs)))  
					  ? 1'b1 : 1'b0; 

assign fw_EXMEM_Rt = (EXMEM_RegWrite  & ReadingRt_IDEX) & 
					(((EXMEM_Rd == IDEX_Rt)) | 
					(~ReadingRs_EXMEM & (IDEX_Rt == EXMEM_Rs))) 
					? 1'b1 : 1'b0; 


//MEM_WB FORWARDING CONDITIONS

assign fw_MEMWB_Rs = (MEMWB_RegWrite & ReadingRs_IDEX) & 
					(((MEMWB_Rd == IDEX_Rs)) | // for XtoX.asm, this goes high too early
					 (~ReadingRs_MEMWB & (IDEX_Rs == MEMWB_Rs))) // change to ~ReadingRs_MEMWB
					  ? 1'b1 : 1'b0;

					
assign fw_MEMWB_Rt = (MEMWB_RegWrite & ReadingRt_IDEX) 
					 & (((MEMWB_Rd == IDEX_Rt)) |
					 (~ReadingRs_MEMWB & (IDEX_Rt == MEMWB_Rs))) 
					  ? 1'b1 : 1'b0; 

assign chosenAluA = (fw_EXMEM_Rs) ? fwEX : (fw_MEMWB_Rs) ? fwMEM : nakedA; 
assign chosenAluB = (fw_EXMEM_Rt) ? fwEX : (fw_MEMWB_Rt) ? fwMEM : nakedB; 

endmodule