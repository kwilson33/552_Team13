
// Kevin most recent - removed err signal for now, not sure where to do that
// also I renamed a bunch of signals for clarity
// Super confused on which PC signals are for what
module executeInstruction (instr, invA, invB, A, B, Cin, SESel, ALUSrc2, 
						  Branching, next_PC_normal, aluOutput,
						  S_extend5_in, S_extend8_in, S_extend11_in,
						  Z_extend8_in, Z_extend5_in,	
						  writeRegister,
						  RegDst,				
						  updatedPC, reg7_En,
						  branchingPCEnable_out); 


	input[15:0] instr, next_PC_normal;
	input[15:0] A, B; 
	input [15:0]  S_extend5_in, S_extend8_in, S_extend11_in,
				  Z_extend8_in, Z_extend5_in;
	input invA, invB, Cin, Branching;
	// decide what goes to the ALU
	input [2:0] SESel;
	input [1:0] RegDst;
	input ALUSrc2;

	output reg7_En, branchingPCEnable_out; 
	output[15:0] aluOutput; 
	output[15:0] updatedPC; 
	output [2:0] writeRegister;

	// decided by SESel and ALUSrc2
	wire[15:0] aluSecondInput; 

	//Jumping enables
	wire jal_and_j_enable, jr_and_jalr_enable;

	//Branching enables
	wire branchEN; 

	//intermidiate wires
	// calculatedPC and jalr_jr_displacement are used for jumping
	wire[15:0] PC_Increment, branchOffset, calculatedPC, jalr_jr_displacement; 

	//Unused connections, don't care about the Cout of the adders?
	wire cout1, cout2; 

	// flags of ALU output and error signal
	wire zero_flag, pos_flag, neg_flag, err;


	//RegDstRegister
	// 00 - 4:2
	// 01 - 7:5
	// 10 - 10:8
	// 11 - 111

	// choose what reg to write to depending on output RegDstRegister of control
	mux4_1 #(.NUM_BITS(3)) writeRegSelMux (.InA(instr[4:2]), .InB(instr[7:5]), 
					       .InC(instr[10:8]), .InD(3'b111),
					       .S(RegDst), .Out(writeRegister));

	reg [15:0] signExtendedImmediateReg;
	// case statement to decide how to sign extend the immediate
	always @(*) begin
		casex (SESel)
			3'b000: begin
				signExtendedImmediateReg = Z_extend5_in;
			end
			3'b001: begin
				signExtendedImmediateReg = Z_extend8_in;
			end
			3'b01x: begin
				signExtendedImmediateReg = S_extend5_in;
			end
			3'b10x: begin
				signExtendedImmediateReg = S_extend8_in;
			end
			3'b11x: begin
				signExtendedImmediateReg = S_extend11_in;
			end
		endcase 
	end

	// Set the second input to the ALU
	assign aluSecondInput = Branching ? (16'h0000) : (ALUSrc2 ? (B) : signExtendedImmediateReg); 

	// Calculate the displacement for  JALR and jr instructions
	rca_16b adder2(.A(S_extend8_in), .B(A), .C_in(1'b0), .S(jalr_jr_displacement), .C_out(cout2)); 
	
	// This modules decides if we're branching or not 
	branchControlLogic branchControl(.Op(instr[15:11]), 
									 .pos_flag(pos_flag), 
									 .neg_flag(neg_flag), 
									 .zero_flag(zero_flag), 
									 .branchEN(branchEN));

 	// If branching, use sign extended 8 bits of instruction as offset, otherwise 0.
	assign branchOffset = branchEN ? (signExtendedImmediateReg) : (16'h0000);


	jumpControlLogic jumpControl(.opcode(instr[15:11]), 
								 .reg7_En(reg7_En), 
								 .jr_and_jalr_enable(jr_and_jalr_enable), 
								 .jal_and_j_enable(jal_and_j_enable)); 
	// If jumping, use sign extended 11 bits of instructions, otherwise use branch output from above
	assign PC_Increment = jal_and_j_enable ? (signExtendedImmediateReg) : (branchOffset);

	
	// Add PC + 2 (normal) + offset of branch,jump, or nothing
	rca_16b adder1(.A(PC_Increment), .B(next_PC_normal), .C_in(1'b0), .S(calculatedPC), .C_out(cout1)); 
	// Set the new PC output to PC+2, or PC + branch offset, 
	// or PC + sign extended 11, or finally PC + 8 sign extended

	// Pass to EX_MEM, MEM_WB, back to fetch
	assign updatedPC = jr_and_jalr_enable ? (jalr_jr_displacement) : (calculatedPC);
	

	alu 	mainALU( .A(A), .B(aluSecondInput), .Cin(Cin), 
					.Op(instr[15:11]), 
					.Funct(instr[1:0]),
					.invA(invA), .invB(invB),  
					.Out(aluOutput), .err(err), 
					.Zero(zero_flag), .Pos(pos_flag), .Neg(neg_flag)); 

	// add branch condition output- Pass to EX_MEM, MEM_WB, back to fetch
	assign branchingPCEnable_out = branchEN | jr_and_jalr_enable | jal_and_j_enable;

endmodule