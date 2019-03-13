
// Kevin most recent - removed err signal for now, not sure where to do that
// also I renamed a bunch of signals for clarity
// Super confused on which PC signals are for what
module executeInstruction (instr, invA, invB, A, B, Cin, SESel, ALUSrc2, next_PC_normal, /*err*/ aluOutput, updatedPC, reg7_En); 


	input[15:0] instr, next_PC_normal; 
	input[15:0] A, B; 
	input invA, invB, Cin;
	// decide what goes to the ALU
	input [2:0] SESel;
	input ALUSrc2;

	//output err;
	output reg7_En; 
	output[15:0] aluOutput; 
	output[15:0] updatedPC; 

	// decided by SESel and ALUSrc2
	wire[15:0] aluSecondInput; 

	//Jumping enables
	wire jump_enable, jump_select;

	//Branching enables
	wire branchEN; 

	//intermidiate wires
	// calculatedPC and jalr_jr_displacement are used for jumping
	wire[15:0] PC_Increment, branchingOuput, calculatedPC, jalr_jr_displacement; 

	//Unused connections, don't care about the Cout of the adders?
	wire cout1, cout2; 

	wire zero_flag, pos_flag, neg_flag, err;


	//All Extensions for module in schematic happens here
	wire[15:0] out_S_extend5, out_S_extend8, out_S_extend11,
				out_Z_extend8, out_Z_extend5; 
	//Sign extensions
	signExt16_5		signExtend5(.in(instr[4:0]), .out(out_S_extend5));
	signExt16_8		signExtend8(.in(instr[7:0]), .out(out_S_extend8));
	signExt16_11	signExtend11(.in(instr[10:0]), .out(out_S_extend11));
	//Zero Extensions
	zeroExt16_8		zeroExtend8(.in(instr[7:0]), .out(out_Z_extend8)); 
	zeroExt16_5		zeroExtend5(.in(instr[4:0]), .out(out_Z_extend5)); 


	reg [15:0] signExtendedImmediateReg;
	// case statement to decide how to sign extend the immediate
	always @(*) begin
		case (SESel)
			3'b000: begin
				signExtendedImmediateReg = out_Z_extend5;
			end
			3'b001: begin
				signExtendedImmediateReg = out_Z_extend8;
			end
			3'b01x: begin
				signExtendedImmediateReg = out_S_extend5;
			end
			3'b10x: begin
				signExtendedImmediateReg = out_S_extend8;
			end
			3'b11x: begin
				signExtendedImmediateReg = out_S_extend11;
			end
		endcase 
	end

	// Set the second input to the ALU
	assign aluSecondInput = ALUSrc2 ? (B) : signExtendedImmediateReg;

	// Calculate the displacement for  JALR and jr instructions
	rca_16b adder2(.A(out_S_extend8), .B(A), .C_in(1'b0), .S(jalr_jr_displacement), .C_out(cout2)); 
	// Set the new PC output to PC+2, or PC + branch offset, or PC + sign extended 11, or finally PC + 8 sign extended
	assign updatedPC = jump_select ? (jalr_jr_displacement) : (calculatedPC);

 	// If branching, use sign extended 8 bits of instruction. otherwise do nothing.
	assign branchingOuput = branchEN ? (out_Z_extend8) : (16'h0000);

	// If jumping, use sign extended 11 bits of instructions, otherwise use branch output from above
	assign PC_Increment = jump_enable ? (out_S_extend11) : (branchingOuput);

	jumpControlLogic jumpControl(.opcode(instr[15:11]), 
								 .reg7_En(reg7_En), 
								 .jr_and_jalr_enable(jump_select), 
								 .jal_and_j_enable(jump_enable)); 

	
	// Increment the PC by immediate value
	rca_16b adder1(.A(PC_Increment), .B(next_PC_normal), .C_in(1'b0), .S(calculatedPC), .C_out(cout1)); 
	

	alu 	mainALU( .A(A), .B(aluSecondInput), .Cin(Cin), 
					.Op(instr[15:11]), 
					.Funct(instr[1:0]),
					.invA(invA), .invB(invB),  
					.Out(aluOutput), .err(err), 
					.Zero(zero_flag), .Pos(pos_flag), .Neg(neg_flag)); 


	branchControlLogic branchControl(.opcode(instr[15:11]), 
									 .pos_flag(pos_flag), 
									 .neg_flag(neg_flag), 
									 .zero_flag(zero_flag), 
									 .branchEN(branchEN));
endmodule