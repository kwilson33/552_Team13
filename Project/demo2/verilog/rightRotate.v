module rightRotate(In, Cnt, Out); 

   parameter   N = 16;
   parameter   C = 4;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   output [N-1:0]  Out;
   
   wire [N-1:0] rightRotate8, rightRotate8_out; 
   wire [N-1:0] rightRotate4, rightRotate4_out; 
   wire [N-1:0] rightRotate2, rightRotate2_out;
   wire [N-1:0] rightRotate1;
   

   assign rightRotate1 = { rightRotate2_out[0], rightRotate2_out[15:1]};
   assign rightRotate2 = { rightRotate4_out[1:0], rightRotate4_out[15:2]};
   assign rightRotate4 = {rightRotate8_out[3:0], rightRotate8_out[15:4]};
   assign rightRotate8 = {In[7:0], In[15:8] };



   
   // Use four 2-1 16 bit muxes to rotate right
   mux2_1    #(.NUM_BITS(16)) rotate8_mux    (In, rightRotate8, Cnt[3], rightRotate8_out),
                              rotate4_mux    (rightRotate8_out, rightRotate4, Cnt[2], rightRotate4_out),
                              rotate2_mux    (rightRotate4_out, rightRotate2, Cnt[1], rightRotate2_out),
                              rotate1_mux    (rightRotate2_out, rightRotate1, Cnt[0], Out);

endmodule
