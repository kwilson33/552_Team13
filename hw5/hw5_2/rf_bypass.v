/*
   CS/ECE 552, Spring '19
   Homework #5, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module rf_bypass (
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

/*
module rf (
           // Outputs
           readData1, readData2, err,
           // Inputs
           clk, rst, readReg1Sel, readReg2Sel, writeRegSel, writeData, writeEn
           );
*/

// written data from the register file 
wire [15:0] readOutput1, readOutput2;
// determines whether to bypass or not 
wire rfBypass1, rfBypass2;

rf registerFile (.readData1(readOutput1), .readData2(readOutput2), .err(err), .clk(clk), .rst(rst), .readReg1Sel(readReg1Sel), .readReg2Sel(readReg2Sel), .writeRegSel(writeRegSel), .writeData(writeData), .writeEn(writeEn)); 

// Bypass logic that allows data written in one cycle to also be read in one cycle
// If both both the register to write to and the register to read from are the same,
// assign the output of the writeData. Otherwise, give it the normal Register File output

// See if we should be bypassing or not
assign rfBypass1 = writeEn & (writeRegSel == readReg1Sel);
assign rfBypass2 = writeEn & (writeRegSel == readReg2Sel);

// If bypassing, set the written data to the read data
assign readData1 = rfBypass1 ? writeData : readOutput1;
assign readData2 = rfBypass2 ? writeData : readOutput2;


endmodule
