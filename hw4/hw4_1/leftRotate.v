module leftRotate(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
	
   wire [N-1:0] leftRotate8, leftRotate8_out; 
   wire [N-1:0] leftRotate4, leftRotate4_out; 
   wire [N-1:0] leftRotate2, leftRotate2_out;
   wire [N-1:0] leftRotate1;
   
   assign leftRotate8 = {In[7:0],  In[15:8]};
   assign leftRotate4 = {leftRotate8_out[11:0], leftRotate8_out[15:12]};
   assign leftRotate2 = {leftRotate4_out[13:0], leftRotate4_out[15:14]};
   assign leftRotate1 = {leftRotate2_out[14:0], leftRotate2_out[15]};
   
   // Use four 2-1 16 bit muxes to rotate left
   mux2_1 	rotate8_mux		(In, leftRotate8, Cnt[3], leftRotate8_out),
			rotate4_mux		(leftRotate8_out, leftRotate4, Cnt[2], leftRotate4_out),
			rotate2_mux		(leftRotate4_out, leftRotate2, Cnt[1], leftRotate2_out),
			rotate1_mux		(leftRotate2_out, leftRotate1, Cnt[0], Out);

endmodule
