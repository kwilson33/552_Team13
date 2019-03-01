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
   
   input        clk, rst;
   input [2:0]  readReg1Sel;
   input [2:0]  readReg2Sel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] readData1;
   output [15:0] readData2;
   output        err;

   /* YOUR CODE HERE */

wire[15:0] out0, out1, out2, out3, out4, out5, out6, out7; 
wire[7:0] write; 

assign write[7] = writeEn & (writeRegSel == 7); 
assign write[6] = writeEn & (writeRegSel == 6);
assign write[5] = writeEn & (writeRegSel == 5);
assign write[4] = writeEn & (writeRegSel == 4);
assign write[3] = writeEn & (writeRegSel == 3);
assign write[2] = writeEn & (writeRegSel == 2);
assign write[1] = writeEn & (writeRegSel == 1);
assign write[0] = writeEn & (writeRegSel == 0);

//module bitreg16 (out, clk, rst, writeData, writeEn); 
//Instantiate 8 of the 16 bit registers
bitreg16 r0(.out(out0), .clk(clk), .rst(rst), .writeData(writeData), .writeEn(write[0])); 
bitreg16 r1(out1, clk, rst, writeData, write[1]); 
bitreg16 r2(out2, clk, rst, writeData, write[2]); 
bitreg16 r3(out3, clk, rst, writeData, write[3]); 
bitreg16 r4(out4, clk, rst, writeData, write[4]); 
bitreg16 r5(out5, clk, rst, writeData, write[5]); 
bitreg16 r6(out6, clk, rst, writeData, write[6]); 
bitreg16 r7(out7, clk, rst, writeData, write[7]); 

assign readData1 = readReg1Sel[2] ? (readReg1Sel[1] ? (readReg1Sel[0] ? out7 : out6) 
	: (readReg1Sel[0] ? out5 : out4)) : (readReg1Sel[1] ? (readReg1Sel[0] ? out3 : out2)
	: (readReg1Sel[0] ? out1 : out0)); 

assign readData2 = readReg2Sel[2] ? (readReg2Sel[1] ? (readReg2Sel[0] ? out7 : out6) 
	: (readReg2Sel[0] ? out5 : out4)) : (readReg2Sel[1] ? (readReg2Sel[0] ? out3 : out2)
	: (readReg2Sel[0] ? out1 : out0)); 


endmodule
