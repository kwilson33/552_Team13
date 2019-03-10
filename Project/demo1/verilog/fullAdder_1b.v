/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    Kevin Wilson
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out);
    input  A, B;
    input  C_in;
    output S;
    output C_out;

	wire A_nand_B, A_nand_Cin, B_nand_Cin;
	
	
	// to get S, simply XOR (A,B,C_in)
	xor3 A_B_Cin_Xor(A,B,C_in, S);

	// to get C_out, use all NANDs
	nand2 A_B_nand		(A,B,A_nand_B),
			A_Cin_nand	(A,C_in,A_nand_Cin),
			B_Cin_nand  (B,C_in,B_nand_Cin);

	nand3 final_nand(A_nand_B, A_nand_Cin, B_nand_Cin, C_out);
	
	
endmodule
