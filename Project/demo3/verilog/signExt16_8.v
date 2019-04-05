module signExt16_8(in, out); 

	input[7:0]in;
	input[15:0]out; 

	//Concatenate the first bit 8 times
	assign out = { {8{in[7]}}, in[7:0] };

endmodule
