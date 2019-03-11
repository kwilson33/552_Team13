/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 1

    2-1 mux template
*/
module mux2_1(InA, InB, S, Out);
   parameter NUM_BITS=1;
      
    input   [NUM_BITS-1:0] InA, InB;
    input   S;
    output  [NUM_BITS-1:0] Out;

    assign Out = S ? InB : InA;


endmodule
