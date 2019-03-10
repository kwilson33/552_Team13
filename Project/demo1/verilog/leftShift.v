module leftShift(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
	
   wire [N-1:0] leftShift8, leftShift8_out; 
   wire [N-1:0] leftShift4, leftShift4_out; 
   wire [N-1:0] leftShift2, leftShift2_out;
   wire [N-1:0] leftShift1;
   
   assign leftShift8 = {In[7:0],  {8'b00000000}};
   assign leftShift4 = {leftShift8_out[11:0], {4'b0000}};
   assign leftShift2 = {leftShift4_out[13:0], {2'b00}};
   assign leftShift1 = {leftShift2_out[14:0], {1'b0}};
   
   // Use four 2-1 16 bit muxes to shift left
   mux2_1 			shiftLeft8_mux		(In, leftShift8, Cnt[3], leftShift8_out),
				shiftLeft4_mux		(leftShift8_out, leftShift4, Cnt[2], leftShift4_out),
				shiftLeft2_mux		(leftShift4_out, leftShift2, Cnt[1], leftShift2_out),
				shiftLeft1_mux		(leftShift2_out, leftShift1, Cnt[0], Out);

endmodule
