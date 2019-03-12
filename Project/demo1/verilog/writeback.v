//Writeback

module writeback(readData, writeData, aluResult, PCnext, memToReg, JALen); 

input[15:0] readData, , aluResult, PCnext; 
input memToReg, JALen; 

output[15:0] writeData;

localparam dontCare = 16'hxxxx; 

//Don't know how we are choosing the select for this mux based on 
//the JALen and memToReg?{JALen, memToReg} for .S()?

mux4_1 mux1(.InA(aluResult), .InB(readData), .InC(PCnext), .InD(dontCare), .S(), .Out(writeData)); 

endmodule