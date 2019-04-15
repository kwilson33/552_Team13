/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// D-flipflop

module dff (en, q, d, clk, rst);

    output         q;
    input          d;
    input          clk;
    input          rst;
    input 			en; 

    reg            state;

    assign #(1) q = state;

    wire in; 

    assign in = en ? d : q; 

    always @(posedge clk) begin
      state = rst ? 0 : in; //changed from d to in
    end

endmodule
// DUMMY LINE FOR REV CONTROL :0:
