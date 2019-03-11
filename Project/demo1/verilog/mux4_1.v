/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 1
	 Kevin Wilson
    4-1 mux template
*/
module mux4_1(InA, InB, InC, InD, S, Out);
    parameter NUM_BITS=1;
    
    input	  [NUM_BITS-1:0] 	InA, InB, InC, InD;
    input	  [1:0] 		S;
    output	  [NUM_BITS-1:0] 	Out;
	
    wire  [NUM_BITS-1:0] A_B_Out, C_D_Out;
	
    mux2_1 #(.NUM_BITS(NUM_BITS)) A_B_mux  (InA, InB, S[0], A_B_Out);		// mux for if S[1] is a 0
    mux2_1 #(.NUM_BITS(NUM_BITS)) C_D_mux  (InC, InD,  S[0], C_D_Out);		// mux for if S[1] is a 1	
    mux2_1 #(.NUM_BITS(NUM_BITS)) finalMux (A_B_Out, C_D_Out, S[1], Out);	// use S[1] to pick A,B,C,D

endmodule


