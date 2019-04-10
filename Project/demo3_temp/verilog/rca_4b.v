/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    Kevin Wilson
    a 4-bit RCA module
*/
module rca_4b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;
	
	// C_in1 is the carry in for the second adder block. It's the carry out of the first adder block
	wire C_in1, C_in2, C_in3;
	 
	fullAdder_1b rcaBit0 (A[0], B[0], C_in, S[0], C_in1),
  					 rcaBit1 (A[1], B[1], C_in1, S[1], C_in2),
					 rcaBit2 (A[2], B[2], C_in2, S[2], C_in3),
   				 rcaBit3 (A[3], B[3], C_in3, S[3], C_out);


endmodule
