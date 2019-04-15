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
                          .tag_out              (ctag_out),
                          .data_out             (cdata_out),
                          .hit                  (chit),
                          .dirty                (cdirty),
                          .valid                (cvalid),
                          .err                  (cerr),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (ctag_in),
                          .index                (cindex),
                          .offset               (coffset),
                          .data_in              (c_data_in),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));



   // Outputs of four_bank_mem
   wire [15:0] four_bank_DataOut;
   wire four_bank_stall_out, four_bank_busy_out, four_bank_ErrOut;

   // Inputs to four bank mem
   wire [15:0] four_bank_AddressIn, four_bank_DataIn; 
   wire four_bank_Read, four_bank_Write; // outputs from FSM

   // how git repo does it
   // assign four_bank_AddressIn = {tag_mem, cAddr_sel[10:3], offset_mem};
   // assign four_bank_DataIn = DataOut;

      //Cache output wires
   wire [4:0] ctag_out; 
   wire [15:0] cdata_out; 
   wire chit, cdirty, cvalid, cerr; 

   //Cache input wires
   wire [4:0] ctag_in;  
   wire [7:0] cindex; 
   wire [2:0] coffset;
   wire comp, write, valid_in;  

   reg enable; 
   reg comp; 
   reg write; 
   reg [15:0] c_data_in; 


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

