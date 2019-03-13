/*
CS/ECE 552, Spring '19
Homework #5, Problem #1

This module creates a 16-bit register.  It has 1 write port, 2 read
ports, 3 register select inputs, a write enable, a reset, and a clock
input.  All register state changes occur on the rising edge of the
clock. 
*/
module rf (
	// Outputs
	readData1, readData2, err,
	// Inputs
	clk, rst, readReg1Sel, readReg2Sel, writeRegSel, writeData, writeEn
	);
	
	// Synchronous reset
	input        clk, rst;
	input [2:0]  readReg1Sel;
	input [2:0]  readReg2Sel;
	// Write occurs on next rising clock edge
	input [2:0]  writeRegSel;
	input [15:0] writeData;
	input        writeEn;

	output [15:0] readData1;
	output [15:0] readData2;
	// Set to 1 if, for example, and input or enable is an unknown value
	output        err;
	
	// err is 1 if any of the inputs have an unknown value (x). Check this by
	// using a bitwise XOR to see if any bits unknown.
	/*
	assign err = (^clk === 1'bx) ? 1'b1 : 
	(^rst === 1'bx) ? 1'b1 : 
	(^readReg1Sel === 1'bx) ? 1'b1 :
	(^readReg2Sel === 1'bx) ? 1'b1 : 
	(^writeRegSel === 1'bx) ? 1'b1 :
	(^writeData === 1'bx) ? 1'b1 :
	(^writeEn === 1'bx) ? 1'b1 : 1'b0;
	*/
	assign err = 1'b0;

	// 8 outputs for the 8x16 bit registers
	// These will be the passed into the regiter_16bits module where 
	// they will be passed into a 16 bit DFFs. In the DFF they will be the outputs.
	wire[15:0] read0Data, read1Data, read2Data, read3Data, read4Data, read5Data, read6Data, read7Data; 
	
	/* Simple 3-to-8 decoder that outputs if a certain register
     * should be written depending on the value of writeRegSel input.
	 * This decoder also has an enable. If enable is low, output will be
	 * 0 no matter what.
	*/

	wire write0, write1, write2, write3, write4, write5, write6, write7;
	assign write7 = writeEn & (writeRegSel == 7); 
	assign write6 = writeEn & (writeRegSel == 6);
	assign write5 = writeEn & (writeRegSel == 5);
	assign write4 = writeEn & (writeRegSel == 4);
	assign write3 = writeEn & (writeRegSel == 3);
	assign write2 = writeEn & (writeRegSel == 2);
	assign write1 = writeEn & (writeRegSel == 1);
	assign write0 = writeEn & (writeRegSel == 0);

	//Instantiate 8 of the 16 bit registers
	// Each of these registers has their own writeEnable signal depending on the output of the 
	// above decoder
	register_16bits r0(.readData(read0Data), .clk(clk), .rst(rst), .writeData(writeData), .writeEnable(write0)); 
	register_16bits r1(read1Data, clk, rst, writeData, write1); 
	register_16bits r2(read2Data, clk, rst, writeData, write2); 
	register_16bits r3(read3Data, clk, rst, writeData, write3); 
	register_16bits r4(read4Data, clk, rst, writeData, write4); 
	register_16bits r5(read5Data, clk, rst, writeData, write5); 
	register_16bits r6(read6Data, clk, rst, writeData, write6); 
	register_16bits r7(read7Data, clk, rst, writeData, write7); 
	
	// Use a 8 to 1 mux with a 3 bit select to decide which register output to read
	assign readData1 = readReg1Sel[2] ? (readReg1Sel[1] ? (readReg1Sel[0] ? read7Data : read6Data) 
	: (readReg1Sel[0] ? read5Data : read4Data)) : (readReg1Sel[1] ? (readReg1Sel[0] ? read3Data : read2Data)
	: (readReg1Sel[0] ? read1Data : read0Data)); 

	assign readData2 = readReg2Sel[2] ? (readReg2Sel[1] ? (readReg2Sel[0] ? read7Data : read6Data) 
	: (readReg2Sel[0] ? read5Data : read4Data)) : (readReg2Sel[1] ? (readReg2Sel[0] ? read3Data : read2Data)
	: (readReg2Sel[0] ? read1Data : read0Data)); 
endmodule
