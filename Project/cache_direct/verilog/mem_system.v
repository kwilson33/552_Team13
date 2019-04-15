/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (),
                          .data_out             (),
                          .hit                  (),
                          .dirty                (),
                          .valid                (),
                          .err                  (),
                          // Inputs
                          .enable               (),
                          .clk                  (),
                          .rst                  (),
                          .createdump           (),
                          .tag_in               (),
                          .index                (),
                          .offset               (),
                          .data_in              (),
                          .comp                 (),
                          .write                (),
                          .valid_in             ());



   // Outputs of four_bank_mem
   wire [15:0] four_bank_DataOut;
   wire four_bank_stall_out, four_bank_busy_out, four_bank_ErrOut;

   // Inputs to four bank mem
   wire [15:0] four_bank_AddressIn, four_bank_DataIn; 
   wire four_bank_Read, four_bank_Write; // outputs from FSM

   // how git repo does it
   // assign four_bank_AddressIn = {tag_mem, cAddr_sel[10:3], offset_mem};
   // assign four_bank_DataIn = DataOut;


   four_bank_mem mem(// Outputs
                     .data_out          (),
                     .stall             (),
                     .busy              (),
                     .err               (four_bank_ErrOut),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (four_bank_AddressIn),
                     .data_in           (four_bank_DataIn),
                     .wr                (four_bank_Write),
                     .rd                (four_bank_Read));

   
   // your code here

   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
