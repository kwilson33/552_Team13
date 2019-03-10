/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    
    a 16-bit RCA module
*/
module rca_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;
	
	// C_in1 is the carry in for the second 4-bit adder block. It's the carry out of the first 4-bit adder block
	 wire C_in1, C_in2, C_in3;
	
	 rca_4b rcaBit3_0   (A[3:0], B[3:0], C_in, S[3:0], C_in1),
	 		  rcaBit7_4   (A[7:4], B[7:4], C_in1, S[7:4], C_in2),
	 		  rcaBit11_8  (A[11:8], B[11:8], C_in2, S[11:8], C_in3),
	 		  rcaBit15_12 (A[15:12], B[15:12], C_in3, S[15:12], C_out);

	

endmodule
