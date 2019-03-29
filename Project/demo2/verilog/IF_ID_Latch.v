module IF_ID_Latch ( instr_in, PC_In, en, clk, rst, instr_out, PC_Out);

//Input from instruction memory
input [15:0] instr_in, PC_In; 
input en, clk, rst; 
output [15:0] instr_out, PC_Out; 


register_16bits rfIFID(.readData(instr_out), .clk(clk), .rst(rst), .writeData(instr_in), .writeEnable(en));
register_16bits rfIFID2(.readData(PC_Out), .clk(clk), .rst(rst), .writeData(PC_In), .writeEnable(en));

//TODO, do something with reset, STALL?

endmodule 

/*
	wire [15:0] instrInSel; 
	assign instrInSel = (rst) ? 16'b00001_xxxxxxxxxxx : instrIn;

	dff16 mod3(.out(instrOut), .in(instrInSel), .en(en), .rst(1'b0), .clk(clk));
*/
