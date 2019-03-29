module zeroExt16_8(in, out); 

input [7:0]in;
input [15:0]out; 

assign out = { {8{1'b0}},in[7:0] };

endmodule
