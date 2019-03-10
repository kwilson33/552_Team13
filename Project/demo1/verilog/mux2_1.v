/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 1

    2-1 mux template
*/
module mux2_1(InA, InB, S, Out);
    input   InA, InB;
    input   S;
    output  Out;

    // YOUR CODE HERE

//assign Out = S ? InA : InB;

wire in1, in2, in3; 

nand2 n1(InB, S, in1);
not1 n2(S, in2);
nand2 n3(in2, InA, in3); 
nand2 n4(in3, in1, Out); 



endmodule
