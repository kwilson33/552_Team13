/*
CS/ECE 552 Spring '19
Homework #4, Problem 2

Kevin, Mark, Apoorva

A 16-bit ALU module.  It is designed to choose
the correct operation to perform on 2 16-bit numbers from rotate
left, shift left, shift right arithmetic, shift right logical, add,
or, xor, & and.  Upon doing this, it should output the 16-bit result
of the operation, as well as output a Zero bit and an Overflow
(OFL) bit.
*/
module alu (A, B, Cin, Op, invA, invB, sign, Out, Zero, Ofl);

	// declare constant for size of inputs, outputs (N),
	// and operations (O)
	parameter    N = 16;
	parameter    O = 3;

	input [N-1:0] A;
	input [N-1:0] B;
	input         Cin;
	input [O-1:0] Op;
	input         invA;
	input         invB;
	input         sign;
	output [N-1:0] Out;
	output         Ofl;
	output         Zero;
	output         Zero;

	/* YOUR CODE HERE */

	wire [N-1 : 0] barrelShifterOut, logic_add_Out;
	wire [N-1 : 0] outRCA, A_and_B, A_xor_B, A_or_B;

	wire coutRCA, signedOFL, unsignedOFL, bothPositive, bothNegative; 

	//Check if inputs A or B should be inverted
	assign A = (invA) ? ~A : A;
	assign B = (invB) ? ~B : B;

	/* Op codes for each of the 8 possible operations
		
	 * OP[2] = 0
	 
	 * ROTATE_LEFT  		3'b000
	 * SHIFT_LEFT  			3'b001
	 * SHIFT_RIGHT_ARITH  	3'b010
	 * SHIFT_RIGHT_LOGIC 	3'b011
	 
	   OP[2] = 1
	   
	 * ADD  				3'b100;
	 * AND  				3'b101;
	 * OR   				3'b110;
	 * XOR =				3'b111;
	*/
	
	//Instantiate Shifter
	//barrelShifter (In, Cnt, Op, Out); << What module takes
	//For all shifting: assume A = value being shifted
	//assume B = # of times to shift
	barrelShifter shifter1(A, B[3:0], Op[1:0], barrelShifterOut); 

	//Instantiate Ripple Carry Adder// Can take in 16 bit inputs
	//rca_16b (A, B, C_in, S, C_out); << What module takes
	rca_16b rippleCarry1(A, B, Cin, outRCA, coutRCA);

	//////////////////////////////////////////////////////////////
	//Cases for the first to Op bits

	assign A_and_B = A & B;
	assign A_or_B = A | B;
	assign A_xor_B = A ^ B;

	// Select between ADD, AND, OR, XOR using lower two bits of Op
	mux4_1 logicOrAddSelector(outRCA, A_and_B, A_or_B, A_xor_B, Op[1:0], logic_add_Out);
	// Select between shift operation or ADD,AND,OR,XOR using MSB of Op
	mux2_1 logicOrShiftSelector(barrelShifterOut, logic_add_Out, Op[2], Out);

	//Set zero if all the bits of out are 0
	assign Zero = ~(|Out); 

	//Handle Overflow. Check msb's of A and B
	// First checks if we are doing signed operation.
	// If signed, checks if MSB of newA and newB are 0
	// If unsigned, positive no matter what.
	assign bothPositive = (sign) ? (~A[15] & ~B[15]) : 1'b1;

	// First checks if signed. If we are, checks if MSB of
	// newA and newB are both 1. If not signed, then we can't
	// have negative numbers
	assign bothNegative = (sign) ? (A[15]  & B[15]) : 1'b0;

	assign Ofl = (sign) ? ((Out[15] & bothPositive) | (~Out[15] & bothNegative)) : (coutRCA); 
endmodule
