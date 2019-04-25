/* 
   CS/ECE 552, Spring '19
   Project
  
   Filename        : dffe.v
   Description     : This module is a 16-bit D FF with an enable.
*/
module dffe (/*AUTOARG*/
             // Outputs
             q,
             // Inputs
             d,
             clk,
             en,
             rst);

   parameter DATA_SIZE = 16;

   output [DATA_SIZE-1:0] q;

   input [DATA_SIZE-1:0]  d;
   input                  clk, rst, en;

   wire [DATA_SIZE-1:0]   inD;

   // instantiate a 16-bit D FF (without enable)
   dff dffNormal[DATA_SIZE-1:0] (// Outputs
                                 .q(q),
                                 // Inputs
                                 .d(inD),
                                 .clk(clk),
                                 .rst(rst),
                                 .enable(1'b1));

   // enable the output of the D FF
   mux2_1_16b #(DATA_SIZE) enabler (// Inputs
                                    .i0(q), 
                                    .i1(d), 
                                    .Sel(en),
                                    // Outputs
                                    .out(inD));
   
endmodule // dffe
