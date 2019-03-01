module shiftRightLogical(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
	
   wire [N-1:0] shiftRightLogical8, shiftRightLogical8_out; 
   wire [N-1:0] shiftRightLogical4, shiftRightLogical4_out; 
   wire [N-1:0] shiftRightLogical2, shiftRightLogical2_out;
   wire [N-1:0] shiftRightLogical1;
   
   assign shiftRightLogical8 = {{8{1'b0}}, In[15:8]};
   assign shiftRightLogical4 = {{4{1'b0}}, shiftRightLogical8_out[15:4]};
   assign shiftRightLogical2 = {{2{1'b0}}, shiftRightLogical4_out[15:2]};
   assign shiftRightLogical1 = {{1{1'b0}}, shiftRightLogical2_out[15:1]};
   
   // Use four 2-1 16 bit muxes to shiftRightLogical left
   mux2_1 		shiftRightLogical8_mux		(In, shiftRightLogical8, Cnt[3], shiftRightLogical8_out),
			shiftRightLogical4_mux		(shiftRightLogical8_out, shiftRightLogical4, Cnt[2], shiftRightLogical4_out),
			shiftRightLogical2_mux		(shiftRightLogical4_out, shiftRightLogical2, Cnt[1], shiftRightLogical2_out),
			shiftRightLogical1_mux		(shiftRightLogical2_out, shiftRightLogical1, Cnt[0], Out);

endmodule
