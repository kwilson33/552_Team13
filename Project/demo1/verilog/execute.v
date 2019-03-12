//Mark most recent
module execute (instr, invA, invB, A, B, Cin, aluSRC, PCplus2, result, newPC, err, ENreg7); 

input[15:0] instr, PCplus2; 
input[15:0] A, B; 
input[2:0] aluSRC; 

output err, ENreg7; 
output[15:0] result; 
output[15:0] newPC; 


wire[15:0] muxIntermediate; 
wire[15:0] aluMuxedInput; 

//Jumping enables
wire JDen, JRen, r7en; 

//Branching enables
wire branchEN; 

//intermidiate wires
wire[15:0] pcIncrement, branchingOuput, total1, total2; 

//Unused connections, don't care about the Cout of the adders?
wire cout1, cout2; 

//All Extensions for module in schematic happens here
wire[15:0] out_S_extend5, out_S_extend8, out_S_extend11; 
wire[15:0] out_Z_extend8, out_Z_extend5; 
//Sign extensions
signExt16_5		signExtend5(.in(instr[4:0]), .out(out_S_extend5));
signExt16_8		signExtend8(.in(instr[7:0]), .out(out_S_extend8));
signExt16_11	signExtend11(.in(instr[10:0]), .out(out_S_extend11));
//Zero Extensions
zeroExt16_8		zeroExtend8(.in(instr[7:0]), .out(out_Z_extend8)); 
zeroExt16_5		zeroExtend5(.in(isntr[4:0]), .out(out_Z_extend5)); 


mux4_1 mux1(.InA(B), .InB(out_S_extend5), .InC(out_Z_extend5), .InD(out_S_extend8), 
			.S(aluSRC[1:0]), .Out(muxIntermediate)); 
mux2_1 mux2(.InA(muxIntermediate), .InB(out_Z_extend8), .S(aluSRC[2]), .Out(aluMuxedInput)); 	



//Set the new PC output to the updated value
mux2_1 mux3(.InA(total1), .InB(total2), .S(JRen), .Out(newPC)); 


rca_16b adder1(.A(pcIncrement), .B(PCplus2), .C_in(1'b0), .S(total1), .C_out(cout1)); 
rca_16b adder2(.A(out_S_extend8), .B(A), .C_in(1'b0), .S(total2), .C_out(cout2)); 



alu mainALU( .A(A), .B(aluMuxedInput), .Cin(Cin), .Op(instr[15:11]), .invA(invA), .invB(invB), .sign(), .Out(result), .Zero(), .Ofl()); 


controlJUMP controlJUMP1(.opcode(instr[15:11]), .r7en(r7en), .JRen(JRen), .JDen(JDen)); 


//logic module for branching and incrementing the PC below
mux2_1	mux4(.InA(16'h0000), .InB(out_S_extend8), .S(branchEN), .Out(branchingOuput)); 
mux2_1	mux4(.InA(branchingOuput), .InB(out_S_extend11), .S(JDen), .Out(pcIncrement)); 


branchControl bcntrl(.opcode(instr[15:11]), .pos_flag(), .neg_flag(), .zero_flag(), .branchEN(branchEN));


endmodule