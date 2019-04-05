module rightShift(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
	
   wire [N-1:0] rightShift8, rightShift8_out; 
   wire [N-1:0] rightShift4, rightShift4_out; 
   wire [N-1:0] rightShift2, rightShift2_out;
   wire [N-1:0] rightShift1;
   
   assign rightShift8 = {{8'b00000000}, In[15:8]};
   assign rightShift4 = {{4'b0000}, rightShift8_out[15:4]};
   assign rightShift2 = {{2'b00}, rightShift4_out[15:2]};
   assign rightShift1 = {{1'b0}, rightShift2_out[15:1]};
   
   // Use four 2-1 16 bit muxes to shift right
   mux2_1 		#(.NUM_BITS(16))	shiftright8_mux		(In, rightShift8, Cnt[3], rightShift8_out),
				shiftright4_mux		(rightShift8_out, rightShift4, Cnt[2], rightShift4_out),
				shiftright2_mux		(rightShift4_out, rightShift2, Cnt[1], rightShift2_out),
				shiftright1_mux		(rightShift2_out, rightShift1, Cnt[0], Out);

endmodule
