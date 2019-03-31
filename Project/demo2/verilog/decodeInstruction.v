module decodeInstruction (//inputs
							instruction, clk, rst,
						    writeData, writeRegister,
						  //outputs
						   err, dump, A, B);

	//Inputs
	input [15:0] instruction, writeData;
	input 		 clk, rst; 
	input [2:0] writeRegister; // comes from MEM_WB Stage

	// Outputs
	output err, dump;
	// output of register file 
	output [15:0] A, B;

	// output of control
	wire RegWrite, controlErr,
		 DMemWrite, ALUSrc2,
		 PCSrc, PCImm, 
		 MemToReg, DMemEn, 
		 Branching,
		 DMemDump, Jump,
		 invA, invB, Cin;

	wire [1:0] RegDest;
	wire [2:0] SESel; 

	// output of register file
	wire regErr;
	

	assign err = 1'b0;
	//assign err = (controlErr | regErr);
	assign dump = DMemDump;

	//assign err = 1'b0;
	// control module determines all of the control logic for the processor
	// and also which register to write to 
	control controlUnit( // Outputs
					.err(controlErr), .RegDst(RegDest), .ALUSrc2(ALUSrc2), 
					.RegWrite(RegWrite), .DMemWrite(DMemWrite), .DMemEn(DMemEn), 
					.SESel(SESel), .PCSrc(PCSrc), .PCImm(PCImm), .Cin(Cin),
					.MemToReg(MemToReg), .DMemDump(DMemDump), .Jump(Jump),
					.invA(invA), .invB(invB), .Branching(Branching),
					// Inputs
					.OpCode(instruction[15:11]),
					.Funct(instruction[1:0]),
					.rst(rst));


	// Rd = writeRegister
	// use bits [10:8] of instruction to figure out what Rs should be 
	// use bits [7:5] of instruction to figure out what Rt should be 
	rf regFile(// Outputs
				 .readData1(A), .readData2(B), .err(regErr),
				  //Inputs
				 .clk(clk), .rst(rst), .readReg1Sel(instruction[10:8]), 
				 .readReg2Sel(instruction[7:5]), .writeRegSel(writeRegister), 
			   	 .writeData(writeData), .writeEn(RegWrite)); 


	//All Extensions for module in schematic happens here
	wire[15:0] S_extend5_out, S_extend8_out, S_extend11_out,
				Z_extend8_out, Z_extend5_out; 
	//Sign extensions
	signExt16_5		signExtend5(.in(instruction[4:0]), .out(S_extend5_out));
	signExt16_8		signExtend8(.in(instruction[7:0]), .out(S_extend8_out));
	signExt16_11	signExtend11(.in(instruction[10:0]), .out(S_extend11_out));
	//Zero Extensions
	zeroExt16_8		zeroExtend8(.in(instruction[7:0]), .out(Z_extend8_out)); 
	zeroExt16_5		zeroExtend5(.in(instruction[4:0]), .out(Z_extend5_out)); 

	
endmodule


