/*
   CS/ECE 552 Spring '19
   Homework #5, Problem 1

   A 16-bit 2-1 Mux (can be configured with N parameter to be a
   different number of bits).
*/
module mux2_1_16b(/*AUTOARG*/
                  // Inputs    
                  i0,      
                  i1,      
                  Sel,
                  // Outputs
                  out);

   parameter N = 16;

   input [N-1:0]    i0, i1;
   input            Sel;

   output [N-1:0]   out;    

   reg [N-1:0]      outreg;

   always @* begin
      case (Sel)    
        2'b0 : outreg = i0;      
        2'b1 : outreg = i1;    
		default: outreg = {N{1'bx}};     // unknown Sel = unknown output
      endcase         
   end                        

   assign out = outreg;

endmodule    
