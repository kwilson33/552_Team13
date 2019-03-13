module decodeInstruction (//inputs
							instruction, clk, rst, writeData,
						  //outputs
						   err);

	//Inputs
	input [15:0] instruction, writeData;
	input 		 clk, rst; 

	//Outputs
	output err;


	// internal signals
	// which register to write to. Input to regFile
	wire [2:0] writeRegister;

	// output of control
	wire RegWrite, controlErr,
		 DMemWrite, ALUSrc2,
		 PCSrc, PCImm, 
		 MemToReg, DMemEn, 
		 DMemDump, Jump; 

	wire [1:0] RegDest;
	wire [2:0] SESel; 

	// output of register file
	wire [15:0] readData1, readData2;
	wire regErr;

	//We plan to connect these by using the dot operator
	

	assign err = (controlErr | regErr);
	//assign err = 1'b0;
	// control module determines all of the control logic for the processor
	// and also which register to write to 
	control control( // Outputs
					.err(controlErr), .RegDst(RegDest), .ALUSrc2(ALUSrc2), 
					.RegWrite(RegWrite), .DMemWrite(DMemWrite), .DMemEn(DMemEn), 
					.SESel(SESel), .PCSrc(PCSrc), .PCImm(PCImm), 
					.MemToReg(MemToReg), .DMemDump(DMemDump), .Jump(Jump),
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
				 .readData1(readData1), .readData2(readData2), .err(regErr),
				  //Inputs
				 .clk(clk), .rst(rst), .readReg1Sel(instruction[10:8]), 
				 .readReg2Sel(instruction[7:5]), .writeRegSel(writeRegister), 
			   	 .writeData(writeData), .writeEn(regWrite)); 


	
endmodule


