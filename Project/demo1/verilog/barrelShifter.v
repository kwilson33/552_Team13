/*
CS/ECE 552 Spring '19
Homework #4, Problem 1

A barrel shifter module.  It is designed to shift a number via rotate
left, shift left, shift right arithmetic, or shift right logical based
on the Op() value that is passed in (2 bit number).  It uses these
shifts to shift the value any number of bits between 0 and 15 bits.
*/
module barrelShifter (In, Cnt, Op, Out);

	// declare constant for size of inputs, outputs (N) and # bits to shift (C)
	parameter   N = 16;
	parameter   C = 4;
	parameter   O = 2;

	input [N-1:0]   In;
	input [C-1:0]   Cnt;
	input [1:0]     Op;
	output [N-1:0]  Out;
	wire [N-1 : 0] shiftOut;
	
	/*
	ROTATE_LEFT = 2'b00;
    SHIFT_LEFT = 2'b01;
    SHIFT_RIGHT_ARITH = 2'b10;
    SHIFT_RIGHT_LOGICAL = 2'b11;
	*/
	
	// wires for outputs of shift modules
	wire [N-1:0] outLeftRot, outLeftShift, outShiftRightA, outShiftRightL;

	// instantiate modules for all the shift operations
	leftRotate 					left_rotate		(In,Cnt,outLeftRot);
	leftShift 					left_shift		(In,Cnt,outLeftShift);
	shiftRightArithmetic 		shift_right_A	(In,Cnt,outShiftRightA); 
	shiftRightLogical 			shift_right_L	(In,Cnt,outShiftRightL);
	
	// Use a 4 to 1 mux to select between different shift operations
	mux4_1 shiftOutputSelector (outLeftRot, outLeftShift, outShiftRightA, outShiftRightL, Op, shiftOut);

	assign Out = shiftOut;
endmodule
