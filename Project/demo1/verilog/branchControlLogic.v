// This module takes care of the logic for the BGEZ, BNEZ, 
module branchControlLogic(opcode, pos_flag, neg_flag, zero_flag, branchEN);

	input [4:0] opcode; 
	input  pos_flag, neg_flag, zero_flag; 

	output branchEN; 

	reg branchEnReg; 

	localparam assert = 1'b1; 
	localparam no_assert = 1'b0; 

	//Branch if not equal zero, branch if greater than or equal to zero
	wire bnez, bgez; 


	assign bnez = (pos_flag | neg_flag) ? assert : no_assert;
	assign bgez = (pos_flag | zero_flag) ? assert : no_assert; 
	assign branchEN = branchEnReg; 

	always@(*)begin
		case(opcode)
			// BGEZ
			5'b01111 : begin
				branchEnReg = (bgez) ? assert : no_assert; 
			end
			// BLTZ
			5'b01110 : begin
				branchEnReg = (neg_flag) ? assert : no_assert; 
			end
			// BEQZ
			5'b01101 : begin
				branchEnReg = (bnez) ? assert : no_assert; 
			end
			// BNEZ
			5'b01100 : begin
				branchEnReg = (zero_flag) ? assert : no_assert; 
			end

			default:  begin
				branchEnReg = no_assert; 
			end	
		endcase
	end

endmodule