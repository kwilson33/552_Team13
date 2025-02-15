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
                invA,
                invB,
                PCSrc,
                PCImm,
                Branching,
                MemToReg,
                DMemDump,
                Jump,
                Cin,
                BranchingOrJumping,
				ReadingRs,
				ReadingRt,
                // Inputs
                OpCode,
                Funct,
                rst// use for checking if DMEMDump should be asserted
                );


   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   input rst;
   
   // outputs
   output       err;
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc, 
                PCImm, MemToReg, DMemDump, Jump, invA, invB, Cin, 
                Branching, BranchingOrJumping,ReadingRs,ReadingRt;
   output [1:0] RegDst;
   output [2:0] SESel;

   /* YOUR CODE HERE */
	reg errRegister;
	reg JumpRegister; 
	reg invA_Register, invB_Register, Cin_Register;
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
	reg BranchingRegister;
	reg BranchOrJumpRegister;
	reg ReadingRsRegister, ReadingRtRegister;


	
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
	localparam	ST 			= 5'b10000; 
	localparam 	LD 			= 5'b10001; 
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
	localparam 	SIIC  		= 5'b00010;
	localparam 	NOP 		= 5'b00001;
	localparam 	RTI 		= 5'b00011;
	localparam 	HALT 		= 5'b00000;
	///////////////////////////////////////////

	
	// err is 1 if any of the inputs have an unknown value (x). Check this by
	// using a bitwise XOR to see if any bits unknown.
	// The control logic will also check, if for some reason we didn't correctly
	// define an opcode correctly, err will be set
	assign err = ((^OpCode === 1'bx) ? 1'b1 : 
		     (^Funct === 1'bx) ? 1'b1 : 1'b0) | errRegister;
			 
	
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
	assign DMemDump 	= DMemDumpRegister;// & (~rst); // if rst is high, DMEMDump automatically is 0 to fix IF_ID Latch bug
	assign invA 		= invA_Register;
	assign invB 		= invB_Register;
	assign Cin 			= Cin_Register;
	assign Branching 	= BranchingRegister;
	assign BranchingOrJumping = BranchOrJumpRegister;
	assign ReadingRs 			  = ReadingRsRegister;
	assign ReadingRt 			  = ReadingRtRegister;
	
	

	always@(*) begin
		// most instructions write to a register
		RegWriteRegister = assert;
	
		// these are not asserted for most instructions
		JumpRegister = no_assert;
		DMemWriteRegister = no_assert; 
		DMemEnRegister = no_assert; 
		BranchingRegister = no_assert;
		BranchOrJumpRegister = no_assert;
		
		ReadingRsRegister = assert;
		ReadingRtRegister = assert;
		
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
		ALUSrc2Register = 1'b1;
		//ALUSrc2Register = 1'bx;
		
		// Don't care in default case because not used
		// for every instruction
		RegDstRegister = 2'b00;
		SESelRegister = 3'b000;
		//SESelRegister = 3'bxxx;
		

		// use these for ADD,SUBI, ANDN, etc.
		invA_Register = no_assert;
		invB_Register = no_assert;

		errRegister = no_assert;
		Cin_Register = no_assert;
		
		case (OpCode)
			/////////////////RFORMAT///////////////////////
			ALU_1 : begin
				// R-format instructions mean that
				// bits 4:2 represent the destination register
				RegDstRegister = 2'b00; 
				// ALU should use the 2nd register read from the register file
					case(Funct)
						ADD : begin
							
						end
						
						SUB : begin
							invA_Register = assert;
							Cin_Register = assert;

						end
						
						XOR : begin

						end
						
						ANDN : begin
							//invB_Register = assert; 
						end
					endcase
			end 
			ALU_2: begin // ROL, SLL, ROR, SRL
				// R-format instructions mean that
				// bits 4:2 represent the destination register (Rd)
				RegDstRegister = 2'b00; 
			end
			
			
	
			SEQ : begin
				invB_Register = assert;
				RegDstRegister = 2'b00; 
				Cin_Register = assert;
				
			end
			
			SLT : begin
				invB_Register = assert;
				Cin_Register = assert;
				RegDstRegister = 2'b00; 
			end
			
			SLE : begin
				invB_Register = assert;
				Cin_Register = assert;
				RegDstRegister = 2'b00; 
			end
			
			SCO : begin
				RegDstRegister = 2'b00; 
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
				ReadingRtRegister = no_assert;
			end	
			
			////////////////////IFORMAT-1//////////////////////////
			// I-format 1 instructions mean that
			// bits 7:5 represent the destination register
			SUBI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				invA_Register = assert;
				Cin_Register = assert;
				//sign extend lower 5 bits
				SESelRegister = 3'b010;
				RegDstRegister = 2'b01; 
				ReadingRtRegister = no_assert;
			end
			ADDI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//sign extend lower 5 bits
				SESelRegister = 3'b010;
				RegDstRegister = 2'b01; 
				ReadingRtRegister = no_assert;

			end
			ANDNI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//zero extend lower 5 bits
				SESelRegister = 3'b000;
				RegDstRegister = 2'b01;
				invB_Register = assert;
				ReadingRtRegister = no_assert;
			end
			XORI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				//zero extend lower 5 bits
				SESelRegister = 3'b000;
				RegDstRegister = 2'b01;
				ReadingRtRegister = no_assert;
			end
			ROLI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
				ReadingRtRegister = no_assert;
			end
			SLLI : begin
				RegDstRegister = 2'b01;
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
			end 	 
			RORI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
				ReadingRtRegister = no_assert;
			end	
			SRLI : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				RegDstRegister = 2'b01;
				ReadingRtRegister = no_assert;
			end	
			ST : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;

				// not writing to a register
				RegWriteRegister = no_assert; 
				
				//sign extend lower 5 bits
				SESelRegister = 3'b010;
				
				DMemWriteRegister = assert;
				DMemEnRegister = assert;
				
				RegDstRegister = 2'b01;
				// WE ARE ACTUALLY READING FROM RT EVEN THOUGH IT SAYS RD
				//10000 sss ddd iiiii ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd 
			end
			LD : begin
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				
				// sign extend lower 5 bits
				SESelRegister = 3'b010;
				
				DMemEnRegister = assert;
				RegDstRegister = 2'b01;
				
				// Use memory contents instead of ALU to write to register
				MemToRegRegister = assert;
				
				// Rd <- Mem[Rs + I(sign ext.)], Rd is actually Rt, same bits
				ReadingRtRegister = no_assert;
		
			end
			// Write to Rs for STU
			STU : begin	
				// ALU should use the immediate
				ALUSrc2Register = no_assert;

				//sign extend lower 5 bits
				SESelRegister = 3'b010;
				
				DMemEnRegister = assert;
				DMemWriteRegister = assert;
				RegDstRegister = 2'b10;

				// WE ARE ACTUALLY READING FROM RT EVEN THOUGH IT SAYS RD
				//10000 sss ddd iiiii ST Rd, Rs, immediate Mem[Rs + I(sign ext.)] <- Rd 
			end	

			/////////////////IFORMAT-2////////////////////
			BNEZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b100;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert; 
				BranchingRegister = assert;
				BranchOrJumpRegister = assert;

				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
			end	
			BEQZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b100;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert; 
				BranchingRegister = assert;
				BranchOrJumpRegister = assert;

				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
			end	
			
			BLTZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b100;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert;
				BranchingRegister = assert;
				BranchOrJumpRegister = assert;

				// ALU should use the immediate
				ALUSrc2Register = no_assert; 
				ReadingRtRegister = no_assert;
			end	
			
			BGEZ : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b100;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert; 
				BranchingRegister = assert;
				BranchOrJumpRegister = assert;
				// ALU should use the immediate
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
			end	
			
			// Write to Rs for LBI
			LBI : begin
				// sign extend lower 8 bits
				SESelRegister = 3'b100;
				RegDstRegister = 2'b10;
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
				ReadingRsRegister = no_assert;
			end
			// Write to Rs for SLBI
			SLBI : begin
				//zero extend lower 8 bits
				SESelRegister = 3'b001;
				RegDstRegister = 2'b10;
				ALUSrc2Register = no_assert;
				ReadingRtRegister = no_assert;
			end	
			
			JR : begin
				//sign extend lower 8 bits
				SESelRegister = 3'b100;
				JumpRegister = assert;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert; 
				ALUSrc2Register = no_assert;
				BranchOrJumpRegister = assert;
				ReadingRtRegister = no_assert;
			end 	
			
			JALR : begin
				//sign extend lower 8 bits
				SESelRegister = 3'b100;
				// Write to register 7 since the JALR
				// instruction uses R7 to save context
				JumpRegister = assert; 
				RegDstRegister = 2'b11; 
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				ALUSrc2Register = no_assert;
				BranchOrJumpRegister = assert;
				ReadingRtRegister = no_assert;
			end	
			
			///////////////////JUMP////////////////
			J : begin
				//sign extend lower 11 bits
				SESelRegister = 3'b110;
				PCImmRegister = assert;
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				// not writing to a register
				RegWriteRegister = no_assert; 
				ALUSrc2Register = no_assert;
				BranchOrJumpRegister = assert;
				ReadingRtRegister = no_assert;
				ReadingRsRegister = no_assert;
				
			end	
			
			JAL : begin
				//sign extend lower 11 bits
				SESelRegister = 3'b110;
				// Write to register 7 since the JAL
				// instruction uses R7 to save context
				PCImmRegister = assert;
				RegDstRegister = 2'b11; 
				// use the PC given by the branch/jump
				PCSrcRegister = assert;
				ALUSrc2Register = no_assert;
				BranchOrJumpRegister = assert;
				ReadingRtRegister = no_assert;
				ReadingRsRegister = no_assert;
			end	
			
			////////////////SPECIAL///////////////
			SIIC : begin
				ReadingRsRegister = no_assert;
				ReadingRtRegister = no_assert;
			end
			
			NOP : begin
				RegWriteRegister = no_assert; 
				ReadingRsRegister = no_assert;
				ReadingRtRegister = no_assert;
			end	
			
			HALT : begin
				RegWriteRegister = no_assert;
				DMemDumpRegister = assert; //If reset is high, don't assert DMemDumpRegister
				ReadingRsRegister = no_assert;
				ReadingRtRegister = no_assert;
			end
			
			RTI : begin
				// not writing to a register
				RegWriteRegister = no_assert; 
				// PC <- EPC
				PCSrcRegister = assert;
				ReadingRsRegister = no_assert;
				ReadingRtRegister = no_assert;
			end
			
			// If opcode not recognized, set error
			default : begin
				errRegister = assert; 
			end
			
		endcase
	end

endmodule
