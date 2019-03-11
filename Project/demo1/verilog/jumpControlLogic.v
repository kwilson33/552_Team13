module jumpControlLogic (opcode, r7en, JRen, JDen); 

	input [4:0] opcode; 

	output JDen, r7en, JRen; 

	reg JDen, JRen, r7en; 

	localparam assert = 1'b1; 
	localparam no_assert = 1'b0; 

	always @(*)begin
		case(opcode)
			//JALR
			5'b00111: begin
				JDen = no_assert; 
				JRen = assert; 
				r7en = assert; 
			end

			//JR
			5'b00101: begin
				JDen = no_assert; 
				JRen = assert; 
				r7en = no_assert; 

			end

			//JAL *
			5'b00110: begin
				JDen = assert; 
				JRen = no_assert; 
				r7en = assert; 
			end

			//J *  
			5'b00100: begin
				JDen = assert; 
				JRen = no_assert; 
				r7en = no_assert; 
			end

			default: begin
				JDen = no_assert; 
				JRen = no_assert; 
				r7en = no_assert; 
			end

		endcase

	end

endmodule
