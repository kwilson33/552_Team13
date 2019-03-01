module shiftRightArithmetic(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
	
   wire [N-1:0] shiftRightArithmetic8, shiftRightArithmetic8_out; 
   wire [N-1:0] shiftRightArithmetic4, shiftRightArithmetic4_out; 
   wire [N-1:0] shiftRightArithmetic2, shiftRightArithmetic2_out;
   wire [N-1:0] shiftRightArithmetic1;
   
   assign shiftRightArithmetic8 = {{8{In[15]}}, In[15:8]};
   assign shiftRightArithmetic4 = {{4{In[15]}}, shiftRightArithmetic8_out[15:4]};
   assign shiftRightArithmetic2 = {{2{In[15]}}, shiftRightArithmetic4_out[15:2]};
   assign shiftRightArithmetic1 = {{1{In[15]}}, shiftRightArithmetic2_out[15:1]};
   
   // Use four 2-1 16 bit muxes to shiftRightArithmetic left
   mux2_1 		shiftRightArithmetic8_mux	(In, shiftRightArithmetic8, Cnt[3], shiftRightArithmetic8_out),
			shiftRightArithmetic4_mux		(shiftRightArithmetic8_out, shiftRightArithmetic4, Cnt[2], shiftRightArithmetic4_out),
			shiftRightArithmetic2_mux		(shiftRightArithmetic4_out, shiftRightArithmetic2, Cnt[1], shiftRightArithmetic2_out),
			shiftRightArithmetic1_mux		(shiftRightArithmetic2_out, shiftRightArithmetic1, Cnt[0], Out);

endmodule
