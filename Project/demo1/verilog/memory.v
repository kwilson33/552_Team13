//Memory stage might be done now?

module memory(aluOutput, write_Data, read_Data, mem_Read, mem_Write, rst, dump, clk); 

input clk, dump, rst, mem_Write, mem_Read
input[15:0] aluOutput, write_Data; 


memory2c mem1(.data_out(read_Data), .data_in(write_Data), .addr(aluOutput), .enable(mem_Write | mem_Read), .wr(mem_Write), .createdump(dump), .clk(clk), .rst(rst)); 

endmodule