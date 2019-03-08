/*
   CS/ECE 552, Spring '19
   Homework #6, Problem #1
  
   This module determines all of the control logic for the processor.
*/
module control (/*AUTOARG*/
                // Outputs
                err, 
                RegDst,
                SESel,
                RegWrite,
                DMemWrite,
                DMemEn,
                ALUSrc2,
                PCSrc,
                PCImm,
                MemToReg,
                DMemDump,
                Jump,
                // Inputs
                OpCode,
                Funct
                );


   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   
   // outputs
   output       err;
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc, 
                PCImm, MemToReg, DMemDump, Jump;
   output [1:0] RegDst;
   output [2:0] SESel;

   /* YOUR CODE HERE */
	reg JumpRegister; 
	reg RegWriteRegister; 
	reg DMemWriteRegister;
	reg DMemEnRegister;
	reg	PCImmRegister; 
	reg ALUSrc2Register; 
	reg PCSrcRegister; 
	reg MemToRegRegister; 
	reg	DMemDumpRegister; 
	reg [1:0] RegDstRegister;
	reg [2:0] SESelRegister;
	
	localparam 	assert		= 1'b1; 
	localparam 	no_assert	= 1'b0; 
	
	//////////////Opcodes//////////////////////

	// I-format 1
	localparam	SUBI 		= 5'b01000; 
	localparam 	ADDI 		= 5'b01001; 
	localparam	ANDNI 		= 5'b01010; 
	localparam 	XORI 		= 5'b01011; 
	localparam	ROLI  		= 5'b10100; 
	localparam 	SLLI 		= 5'b10101; 
	localparam	RORI 		= 5'b10110; 
	localparam 	SRLI 		= 5'b10111; 
	localparam	ST 		= 5'b10000; 
	localparam 	LD 		= 5'b10001; 
	localparam	STU 		= 5'b10011; 

	/* 
	 R-format and ALU operations split up
	 but what 2 funct bits are. Or, for
	 ALU_3 case, uses lower two bits of
	 the opcode. BTR is R-format but doesn't
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
	localparam 	NOP 		= 5'b00011;
	localparam 	HALT 		= 5'b00000;
	///////////////////////////////////////////

	
	// err is 1 if any of the inputs have an unknown value (x). Check this by
	// using a bitwise XOR to see if any bits unknown.
	assign err = (^OpCode === 1'bx) ? 1'b1 : 
		     (^Funct === 1'bx) ? 1'b1 : 1'b0;
			 
	
	/* //////////////////TODO/////////////////
	// 	1) BTR instruction??? How does it work
	//	2) Not sure what to default ALUSrc2Register to
	//	3) Did I do MemToReg right?
	//  4) If we're not doing any logic to actually
		   make things work, do we need all those empty cases
		   in ALU_1, ALU_2, ALU_3 for example?? Probably can delete
	*/
	
	// assign all the control signals from their
	// register values
	assign Jump 		= JumpRegister;
	assign PCImm 		= PCImmRegister;
	assign RegDst 		= RegDstRegister;
	assign RegWrite 	= RegWriteRegister;
	assign DMemWrite 	= DMemWriteRegister;
	assign DMemEn 		= DMemEnRegister;
	assign SESel 		= SESelRegister;
	assign ALUSrc2 		= ALUSrc2Register; 
	assign PCSrc 		= PCSrcRegister;
	assign MemToReg 	= MemToRegRegister; 
	assign DMemDump 	= DMemDumpRegister; 


	
	always@(*) begin
		// most instructions write to a register
		RegWriteRegister = assert;
	
		// these are not asserted for most instructions
		JumpRegister = no_assert;
		DMemWriteRegister = no_assert; 
		DMemEnRegister = no_assert; 
		
		// Only case this is asserted is for HALT
		DMemDumpRegister = no_assert;
		
		// In most cases we want the PC to increment by
		// 2 which happens when PCSrc = 0
		PCSrcRegister = no_assert;
		
		// In most cases we write back to the ALU and
		// not memory
		MemToRegRegister = no_assert;
		
		PCImmRegister = no_assert; 
		
		// Will be set to 1 if using Rt was the second operand
		// or 0 if using immediate as second operand
		ALUSrc2Register = 1'bx;
		
		// Don't care in default case because not used
		// for every instruction
		RegDstRegister = 2'bxx;
		SESelRegister = 3'bxxx;
		
		
		case (OpCode)
			/////////////////RFORMAT///////////////////////
			ALU_1 : begin
				// R-format instructions mean that
				// bits 4:2 represent the destination register
				RegDstRegister = 2'b00; 
				// ALU should use the 2nd register read from the register file
				ALUSrc2Register = assert;
					case(Funct)
						ADD : begin

						end
						
						SUB : begin

						end
						
						XOR : begin

						end
						
						ANDN : begin
						
						end
					endcase
			end 
			ALU_2: begin
				// R-format instructions mean that
				// bits 4:2 represent the destination register (Rd)
				RegDstRegister = 2'b00; 
				// ALU should use the 2nd register read from the register file
				ALUSrc2Register = assert;
					case(Funct)
						ROL : begin

						end
						
						SLL : begin

						end
						
						ROR : begin

						end
						
						SRL : begin

						end
					endcase
			end
			
			ALU_3: begin
				// R-format instructions mean that
				// bits 4:2 represent the destination register (Rd)
				RegDstRegister = 2'b00; 
				// ALU should use the 2nd register read from the register file
				ALUSrc2Register = assert;
				// use the lower two bits of the opcode to
				// determine which comparison to do
				case (OpCode[1:0])
					SEQ : begin

					end
					
					SLT : begin

					end
					
					SLE : begin

					end
					
					SCO : begin
					end
				endcase
			end
			
			/* This is also an ALU/R-format instruction but didn't easily
			 * fit into any simple case
			 * Take a single operand Rs and copies it into Rd
			 * but with a left-right reversal of each bit
			 
			 * NOT REALLY SURE IF Rd WOULD BE THE DESTINATION????
			*/
			BTR : begin
				// R-format instructions mean that
				// bits 4:2 represent the destination register (Rd)
				RegDstRegister = 2'b00; 
			end	
			
			////////////////////IFORMAT-1//////////////////////////
			// I-format 1 instructions mean that
			// bits 7:5 represent the destination register
			SUBI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//sign extend lower 5 bits
				SESelRegister = 3'b01x;
				RegDstRegister = 2'b01; 
			end
			ADDI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//sign extend lower 5 bits
				SESelRegister = 3'b01x;
				RegDstRegister = 2'b01; 

			end
			ANDNI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//zero extend lower 5 bits
				SESelRegister = 3'b000;
				RegDstRegister = 2'b01;
			end
			XORI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//zero extend lower 5 bits
				SESelRegister = 3'b000;
				RegDstRegister = 2'b01;
			end
			ROLI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
			end
			SLLI : begin
				RegDstRegister = 2'b01;
			end 	 
			RORI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
			end	
			SRLI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
			end	
			ST : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				
				//sign extend lower 5 bits
				SESelRegister = 3'b01x;
				
				DMemWriteRegister = assert;
				DMemEnRegister = assert;
				
				RegDstRegister = 2'b01;
				// Write back to the output of data memory
				MemToRegRegister = assert;
			end
			LD : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				
				// sign extend lower 5 bits
				SESelRegister = 3'b01x;
				
				DMemEnRegister = assert;
				RegDstRegister = 2'b01;
				
				// Write back to the output of data memory
				MemToRegRegister = assert;
			end
			// Write to Rs for STU
			STU : begin	
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				
				//sign extend lower 5 bits
				SESelRegister = 3'b01x;
				
				DMemEnRegister = assert;
				DMemWriteRegister = assert;
				RegDstRegister = 2'b10;
				
				// Write back to the output of data memory
				MemToRegRegister = assert;
			end	

			/////////////////IFORMAT-2////////////////////
			BNEZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b10x;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			BEQZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b10x;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			BLTZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b10x;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			BGEZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b10x;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			// Write to Rs for LBI
			LBI : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b10x;
				RegDstRegister = 2'b10;
			end
			// Write to Rs for SLBI
			SLBI : begin
				//zero extend lower 8 bits
				SESelRegister = 3'b001;
				RegDstRegister = 2'b10;
			end	
			
			JR : begin
				//sign extend lower 8 bits
				SESelRegister = 3'b10x;
				JumpRegister = assert;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end 	
			
			JALR : begin
				//sign extend lower 8 bits
				SESelRegister = 3'b10x;
				// Write to register 7 since the JALR
				// instruction uses R7 to save context
				JumpRegister = assert; 
				RegDstRegister = 2'b11; 
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			///////////////////JUMP////////////////
			J : begin
				//sign extend lower 11 bits
				SESelRegister = 3'b11x;
				PCImmRegister = assert;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			JAL : begin
				//sign extend lower 11 bits
				SESelRegister = 3'b11x;
				// Write to register 7 since the JAL
				// instruction uses R7 to save context
				PCImmRegister = assert;
				RegDstRegister = 2'b11; 
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
			end	
			
			////////////////SPECIAL///////////////
			siic : begin

			end
			
			NOP : begin
				RegWriteRegister = no_assert; 
				// use the PC given by the branch/jump
				// NOT SURE IF RIGHT
				PCSrcRegister = assert;
			end	
			
			HALT : begin
				RegWriteRegister = no_assert; 
				DMemDumpRegister = assert;
			end
			default : begin
			//	errRegister = assert; 
			end
			
		endcase
	end

endmodule
