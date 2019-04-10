module signExt16_5(in, out); 

	input[4:0]in;
	input[15:0]out; 

	//Concatenate the first bit 8 times
	assign out = { {11{in[4]}}, in[4:0] };

endmodule
