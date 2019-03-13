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

	wire [15:0] outLeftRotate, outRightRotate; 
	wire [15:0] outLeftShift, outRightShift; 
	wire [15:0] shifRotMuxOut; 

	//Wire for if we need to NOT A and/or B
	wire [15:0] newA, newB; 


	//Check if inputs A or B should be inverted
	assign newA = (invA) ? ~A : A;
	assign newB = (invB) ? ~B : B;



	//Instantiate Ripple Carry Adder// Can take in 16 bit inputs
	//rca_16b (A, B, C_in, S, C_out); << What module takes
	rca_16b rippleCarryAdder(newA, newB, Cin, outRCA, coutRCA);


	// Shift modules
	leftRotate	lr1(.In(A), .Cnt(B[3:0]), .Out(outLeftRotate));
  	rightRotate rr1(.In(A), .Cnt(B[3:0]), .Out(outRightRotate)); 
  	leftShift 	ls1(.In(A), .Cnt(B[3:0]), .Out(outLeftShift)); 
  	rightShift 	rs1(.In(A), .Cnt(B[3:0]), .Out(outRightShift)); 

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

	localparam ALU_3		= 5'b111xx;
	localparam SEQ			= 2'b00;
	localparam SLT			= 2'b01;
	localparam SLE			= 2'b10;
	localparam SCO			= 2'b11;
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
	///////////////////////////////////////////
/*
	assign tempNotA[0] = ~A[0]; 
	assign tempNotA[1] = ~A[1]; 
	assign tempNotA[2] = ~A[2];
	assign tempNotA[3] = ~A[3]; 
	assign tempNotA[4] = ~A[4]; 
	assign tempNotA[5] = ~A[5]; 
	assign tempNotA[6] = ~A[6]; 
	assign tempNotA[7] = ~A[7]; 
	assign tempNotA[8] = ~A[8]; 
	assign tempNotA[9] = ~A[9]; 
	assign tempNotA[10] = ~A[10]; 
	assign tempNotA[11] = ~A[11]; 
	assign tempNotA[12] = ~A[12]; 
	assign tempNotA[13] = ~A[13]; 
	assign tempNotA[14] = ~A[14]; 
	assign tempNotA[15] = ~A[15]; 
	assign tempNotB[0] = ~B[0]; 
	assign tempNotB[1] = ~B[1]; 
	assign tempNotB[2] = ~B[2];
	assign tempNotB[3] = ~B[3]; 
	assign tempNotB[4] = ~B[4]; 
	assign tempNotB[5] = ~B[5]; 
	assign tempNotB[6] = ~B[6]; 
	assign tempNotB[7] = ~B[7]; 
	assign tempNotB[8] = ~B[8]; 
	assign tempNotB[9] = ~B[9]; 
	assign tempNotB[10] = ~B[10]; 
	assign tempNotB[11] = ~B[11]; 
	assign tempNotB[12] = ~B[12]; 
	assign tempNotB[13] = ~B[13]; 
	assign tempNotB[14] = ~B[14]; 
	assign tempNotB[15] = ~B[15]; 
	mux2_1 #(.NUM_BITS(16)) (.InA(tempNotA), .InB(A). .S(invA), .Out(newA)); 
	mux2_1 #(.NUM_BITS(16)) (.InA(tempNotB), .InB(B). .S(invB), .Out(newB));
*/





	//Set zero if all the bits of the ripple carry adder output are 0
	assign Zero = ~(|outRCA); 
	// check if output of RCA is positive or negative
	assign Pos = ~(outRCA[15] | Zero );
	assign Neg =  (outRCA[15] | Zero );

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
						ADD : begin
								outReg = coutRCA;
						end
						
						SUB : begin
								outReg = coutRCA;
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
			
			ALU_3: begin
				case (Op[1:0])
					
					SEQ : begin
							outReg = (Zero) ? 16'h0001 : 16'h0000; 
					end
					
					SLT : begin
							outReg = ((A[15] & ~B[15]) | (Neg & ~(A[15]^B[15]))) ? 16'h0001 : 16'h0000; 
					end
					
					SLE : begin
							outReg = ( Zero | (A[15] & ~B[15]) | (Neg & ~(A[15]^B[15]))) ? 16'h0001 : 16'h0000; 
					end
					
					SCO : begin
							//outReg = 
					end
				endcase
			end
			
			
			BTR : begin
				
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
				
			end
			XORI : begin
				
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
				outReg = 16'hXXXX;
			end
			
			NOP : begin
				outReg = 16'hXXXX;
			end	
			
			HALT : begin
				outReg = 16'hXXXX;
			end
			
			RTI : begin
				outReg = 16'hXXXX;
			end
			
			// If Op not recognized, set error
			default : begin
				errRegister = 1'b1; 
			end
			
		endcase
	end
endmodule