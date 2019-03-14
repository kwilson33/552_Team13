// This module takes care of the logic for the branch instructions
module branchControlLogic(Op, pos_flag, neg_flag, zero_flag, branchEN);

	input [4:0] Op; 
	input  pos_flag, neg_flag, zero_flag; 

	output branchEN; 

	reg branchEnReg; 

	//Branch if not equal zero, branch if greater than or equal to zero
	wire bnez, bgez; 


	assign bnez = ((pos_flag | neg_flag) & ~zero_flag) ? 1'b1 : 1'b0;
	assign bgez = (pos_flag | zero_flag) ? 1'b1 : 1'b0; 
	assign branchEN = branchEnReg; 

	always@(*)begin
		branchEnReg = 1'b0; 
		case(Op)
			// BGEZ (Rs >= 0)
			5'b01111 : begin
				branchEnReg = (bgez) ? 1'b1 : 1'b0; 
			end
			// BLTZ (Rs<0)
			5'b01110 : begin
				branchEnReg = (neg_flag) ? 1'b1 : 1'b0; 
			end
			// BEQZ(Rs == 0)
			5'b01101 : begin
				branchEnReg = (zero_flag) ? 1'b1 : 1'b0; 

				//branchEnReg = (bnez) ? 1'b1 : 1'b0; 
			end
			// BNEZ (Rs!=0)
			5'b01100 : begin
				//branchEnReg = (zero_flag) ? 1'b1 : 1'b0; 

				branchEnReg = (bnez) ? 1'b1 : 1'b0; 
			end

			default:  begin
				branchEnReg = 1'b0; 
			end	
		endcase
	end

endmodule