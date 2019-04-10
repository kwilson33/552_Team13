module jumpControlLogic (opcode, reg7_En, jr_and_jalr_enable, jal_and_j_enable); 

	input [4:0] opcode; 

	output jal_and_j_enable, reg7_En, jr_and_jalr_enable; 

	reg jal_and_j_enable, jr_and_jalr_enable, reg7_En; 

	localparam assert = 1'b1; 
	localparam no_assert = 1'b0; 

	always @(*)begin
		case(opcode)
			//JALR
			5'b00111: begin
				jal_and_j_enable = no_assert; 
				jr_and_jalr_enable = assert; 
				reg7_En = assert; 
			end

			//JR
			5'b00101: begin
				jal_and_j_enable = no_assert; 
				jr_and_jalr_enable = assert; 
				reg7_En = no_assert; 

			end

			//JAL *
			5'b00110: begin
				jal_and_j_enable = assert; 
				jr_and_jalr_enable = no_assert; 
				reg7_En = assert; 
			end

			//J *  
			5'b00100: begin
				jal_and_j_enable = assert; 
				jr_and_jalr_enable = no_assert; 
				reg7_En = no_assert; 
			end

			default: begin
				jal_and_j_enable = no_assert; 
				jr_and_jalr_enable = no_assert; 
				reg7_En = no_assert; 
			end

		endcase

	end

endmodule
