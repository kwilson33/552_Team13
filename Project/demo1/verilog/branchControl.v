module branchControl(opcode, pos_flag, neg_flag, zero_flag, branchEN);

input[4:0] opcode; 
input  pos_flag, neg_flag, zero_flag; 

output branchEN; 

reg branchENREG; 

localparam assert = 1'b1; 
localparam no_assert = 1'b0; 

//Branch if not equal zero, branch if greator than or equal to zero
wire bnez, bgez; 

assign branchEN = branchENREG; 
assign bnez = (pos_flag | neg_flag) ? assert : no_assert;
assign bgez = (pos_flag | zero_flag) ? assert : no_assert; 


always@(*)begin
	case(opcode)
		5'b01111 : begin
			branchENREG = (bgez) ? assert : no_assert; 
		end

		5'b01110 : begin
			branchENREG = (neg_flag) ? assert : no_assert; 
		end

		5'b01101 : begin
			branchENREG = (bnez) ? assert : no_assert; 
		end

		5'b01100 : begin
			branchENREG = (zero_flag) ? assert : no_assert; 
		end

		default:  begin
			branchENREG = no_assert; 
		end	
	endcase
end

endmodule