//Writeback

module writebackOutput(readData, writeData, aluOutput, PC_Next, memToReg, JAL_en); 

	input[15:0] readData, , aluOutput, PC_Next; 
	input memToReg, JAL_en; 

	output[15:0] writeData;


	//Don't know how we are choosing the select for this mux based on 
	//the JAL_en and memToReg?{JAL_en, memToReg} for .S()?

	mux4_1 mux1(.InA(aluOutput), .InB(readData), .InC(PC_Next), .InD(16'hxxxx), .S(), .Out(writeData)); 

endmodule