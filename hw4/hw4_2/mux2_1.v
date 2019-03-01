/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 1
	 Kevin Wilson
    2-1 mux template
*/
module mux2_1(InA, InB, S, Out);
    input   InA, InB;
    input   S;
    output  Out;

	wire OutB, OutA, S_n;

	
	// use NAND and NOT gates to implement a 2-1 mux
	not1 	SNOT(S,S_n);
	nand2 nandB(InB,S,OutB);
	nand2 nandA(InA,S_n,OutA);
	nand2 nandOut(OutB,OutA,Out);
endmodule
