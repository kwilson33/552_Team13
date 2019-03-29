module decodeInstruction (//inputs
							instruction, clk, rst, writeData,
						  //outputs
						   err, dump, A, B);

	//Inputs
	input [15:0] instruction, writeData;
	input 		 clk, rst; 

	// Outputs
	output err, dump;
	// output of register file 
	output [15:0] A, B;


	// internal signals
	// which register to write to. Input to regFile
	wire [2:0] writeRegister;

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

	//We plan to connect these by using the dot operator
	

	assign err = (controlErr | regErr);
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
					.Funct(instruction[1:0]));


	//RegDstRegister
	// 00 - 4:2
	// 01 - 7:5
	// 10 - 10:8
	// 11 - 111

	// choose what reg to write to depending on output RegDstRegister of control
	mux4_1 #(.NUM_BITS(3)) writeRegSelMux (.InA(instruction[4:2]), .InB(instruction[7:5]), 
					       .InC(instruction[10:8]), .InD(3'b111),
					       .S(RegDest), .Out(writeRegister));

	// Rd = writeRegister
	// use bits [10:8] of instruction to figure out what Rs should be 
	// use bits [7:5] of instruction to figure out what Rt should be 
	rf regFile(// Outputs
				 .readData1(A), .readData2(B), .err(regErr),
				  //Inputs
				 .clk(clk), .rst(rst), .readReg1Sel(instruction[10:8]), 
				 .readReg2Sel(instruction[7:5]), .writeRegSel(writeRegister), 
			   	 .writeData(writeData), .writeEn(RegWrite)); 


	
endmodule


