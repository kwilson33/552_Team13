/*
CS/ECE 552 Spring '19
Homework #4, Problem 2
Kevin, Mark, Apoorva
A 16-bit ALU module.  It is designed to choose
the correct operation to perform on 2 16-bit numbers 
output zero, negative, and positive flags
*/
module alu (A, B, Cin, Op, Funct, invA, invB, Out, Zero, Neg, Pos, err);


	input [15: 0] A, B;  
	input [4:0]   Op;
	input [1:0]	  Funct;
	input         invA, invB,  Cin;

	output [15:0]  Out;
	output         Zero, Pos, Neg, err;

	wire coutRCA;
	wire [15:0] outRCA;
	reg [15:0] outReg;
	reg errRegister;


				// output wires for shifts
	wire [15:0] outLeftRotate, outRightRotate,
				outLeftShift, outRightShift,
				// output for bit rotate
				outBitRotate;

	//Wire for if we need to NOT A and/or B
	wire [15:0] newA, newB; 


	//Check if inputs A or B should be inverted
	assign newA = (invA) ? ~A : A;
	assign newB = (invB) ? ~B : B;



	//Instantiate Ripple Carry Adder// Can take in 16 bit inputs
	//rca_16b (A, B, C_in, S, C_out); << What module takes
	rca_16b rippleCarryAdder(.A(newA), .B(newB), .C_in(Cin), .S(outRCA), .C_out(coutRCA));


	// Shift modules
	leftRotate	lr1(.In(A), .Cnt(B[3:0]), .Out(outLeftRotate));
  	rightRotate rr1(.In(A), .Cnt(B[3:0]), .Out(outRightRotate)); 
  	leftShift 	ls1(.In(A), .Cnt(B[3:0]), .Out(outLeftShift)); 
  	rightShift 	rs1(.In(A), .Cnt(B[3:0]), .Out(outRightShift)); 
  	// Bit rotate
  	bitRotate   btr(.In(A), .Out(outBitRotate));

	//////////////Ops//////////////////////

	// I-format 1
	localparam	SUBI 		= 5'b01000; 
	localparam 	ADDI 		= 5'b01001; 
	localparam	ANDNI 		= 5'b01010; 
	localparam 	XORI 		= 5'b01011; 
	localparam	ROLI  		= 5'b10100; 
	localparam 	SLLI 		= 5'b10101; 
	localparam	RORI 		= 5'b10110; 
	localparam 	SRLI 		= 5'b10111; 
	localparam	ST 			= 5'b10000; 
	localparam 	LD 			= 5'b10001; 
	localparam	STU 		= 5'b10011; 

	/* 
	 R-format and ALU operations split up
	 but what 2 funct bits are. Or, for
	 ALU_3 case, uses lower two bits of
	 the Op. BTR is R-format but doesn't
	 fit into any ALU case
	*/
	localparam 	BTR 		= 5'b11001; 

	localparam	ALU_1 		= 5'b11011; 
	localparam 	ADD 		= 2'b00; 
	localparam 	SUB 		= 2'b01;
	localparam 	XOR 		= 2'b10;
	localparam 	ANDN 		= 2'b11;

	localparam	ALU_2 		= 5'b11010; 
	localparam 	ROL 		= 2'b00;
	localparam 	SLL 		= 2'b01;
	localparam 	ROR 		= 2'b10;
	localparam 	SRL 		= 2'b11;

	localparam SEQ			= 5'b11100;
	localparam SLT			= 5'b11101;
	localparam SLE			= 5'b11110;
	localparam SCO			= 5'b11111;
	////////////////////////////////////////

	// I-format 2
	localparam 	BNEZ 		= 5'b01100;
	localparam 	BEQZ 		= 5'b01101;
	localparam 	BLTZ 		= 5'b01110;
	localparam 	BGEZ 		= 5'b01111;
	localparam 	LBI 		= 5'b11000;
	localparam 	SLBI 		= 5'b10010;
	localparam 	J 			= 5'b00100;
	localparam 	JR 			= 5'b00101;

	// J-format
	localparam 	JAL 		= 5'b00110;
	localparam 	JALR 		= 5'b00111;

	// Special instructions
	localparam 	siic  		= 5'b00010;
	localparam 	NOP 		= 5'b00001;
	localparam 	RTI 		= 5'b00011;
	localparam 	HALT 		= 5'b00000;
	
	//Set zero if all the bits of the ripple carry adder output are 0
	assign Zero = ~(|Out); 
	// check if output of RCA is positive or negative
	assign Pos = ~(Out[15] | Zero );
	assign Neg =  (Out[15] | Zero );


	//assign Zero = ~(|outRCA); s
	// check if output of RCA is positive or negative
	//assign Pos = ~(outRCA[15] | Zero );
	//assign Neg =  (outRCA[15] | Zero );

	assign err = errRegister;
	assign Out = outReg;

	// Rs = A
	// Rt = B
	always@(*) begin
		errRegister = 1'b0;
		case (Op)
			/////////////////RFORMAT///////////////////////
			// R-format instructions mean that
			// bits 4:2 represent the destination register
			ALU_1 : begin
					case(Funct)
						// Rs + Rt
						ADD : begin
								outReg = outRCA;
						end
						// Rt - Rs
						SUB : begin
								outReg = outRCA;
						end
						
						XOR : begin
							 outReg = (newA^newB);
						end
						
						ANDN : begin
							outReg = A & (~B);
						end
					endcase
			end 
			ALU_2: begin
					case(Funct)
						ROL : begin
							outReg = outLeftRotate; 
						end
						
						SLL : begin
							outReg = outLeftShift; 
						end
						
						ROR : begin
							outReg = outRightRotate; 
						end
						
						SRL : begin
							outReg = outRightShift;
						end
					endcase
			end

			//Rs == Rt
			SEQ : begin
					// (is Rt - Rs == 0)
					outReg = (Zero) ? 16'h0001 : 16'h0000; 
			end
			// Rs < Rt
			SLT : begin
					// (is A negative and B positive) or  (is Rt - Rs negative)
					outReg = ((A[15] & ~B[15]) | (Neg & ~(A[15]^B[15]))) ? 16'h0001 : 16'h0000; 
			end
			// Rs <= Rt
			SLE : begin
					// (Is A neg and B pos or Rt - Rs == 0) or (is Rt -Rs negative)
					outReg = ( Zero | (A[15] & ~B[15]) | (Neg & ~(A[15]^B[15]))) ? 16'h0001 : 16'h0000; 
			end
			
			// if Rs + Rt generates carry out
			SCO : begin
					outReg =  coutRCA;
			end

			BTR : begin
				outReg = outBitRotate;
			end	
			
			////////////////////IFORMAT-1//////////////////////////
			// I-format 1 instructions mean that
			// bits 7:5 represent the destination register
			SUBI : begin
				outReg = outRCA;
			end
			ADDI : begin
				outReg = outRCA;
			end
			ANDNI : begin
				// B would be selected as an immediate in the execute module
				outReg = A & B;
			end
			XORI : begin
				outReg = A ^ B;
			end
			ROLI : begin
				outReg = outLeftRotate; 
			end
			SLLI : begin
				outReg = outLeftShift; 
			end 	 
			RORI : begin
				outReg = outRightRotate; 
			end	
			SRLI : begin
				outReg = outRightShift; 
			end	
			ST : begin
				outReg = outRCA;
			end
			LD : begin
				outReg = outRCA;
			end
			// Write to Rs for STU
			STU : begin	
				outReg = outRCA;
			end	

			/////////////////IFORMAT-2////////////////////
			BNEZ : begin
				outReg = outRCA; 
			end	
			BEQZ : begin
				outReg = outRCA; 
			end	
			
			BLTZ : begin
				outReg = outRCA; 
			end	
			
			BGEZ : begin
				outReg = outRCA; 
			end	
			
			// Write to Rs for LBI
			LBI : begin
				outReg = B; 
			end
			// Write to Rs for SLBI
			SLBI : begin
				outReg = ((A << 8) | B); 
			end	
			
			JR : begin
				outReg = outRCA; 
			end 	
			
			JALR : begin
				outReg = outRCA; 
			end	
			
			///////////////////JUMP////////////////
			J : begin
				outReg = outRCA; 
			end	
			
			JAL : begin
				outReg = outRCA; 
			end	
			
			////////////////SPECIAL///////////////
			siic : begin
				outReg = 16'h0000;
			end
			
			NOP : begin
				outReg = 16'h0000;
			end	
			
			HALT : begin
				outReg = 16'h0000;
			end
			
			RTI : begin
				outReg = 16'h0000;
			end
			
			// If Op not recognized, set error
			default : begin
				errRegister = 1'b1; 
			end
			
		endcase
	end
endmodule