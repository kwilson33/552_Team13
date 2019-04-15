/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, cacheHitOut, err,
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
   output cacheHitOut;
   output err;



   //##########################FOUR BANK MEM SIGNALS##########################
   // Outputs of four_bank_mem
   wire [15:0] four_bank_DataOut;
   wire four_bank_stall_out, four_bank_busy_out, four_bank_ErrOut;

   // The input to the four_bank_mem is the DataOut of mem_system
   // Inputs to four bank mem
   wire [15:0] four_bank_AddressIn;
   wire four_bank_Read, four_bank_Write; // outputs from FSM
   

   // how git repo does it
   // assign four_bank_AddressIn = {tag_mem, cAddr_sel[10:3], offset_mem};
   // assign DataOut = hit ? (hit_sel0 ? cache_data_out0 : cache_data_out1) : (comp ? comp_data_sel : access_data_sel);
   //##################################################################


    //##########################CACHE SIGNALS##########################
   //Cache output wires
   wire [4:0] cacheTagOut; 
   wire [15:0] cacheDataOut; 
   wire cacheHitOut, cacheDirtyOut, cacheValidOut, cacheErrOut; 

   //Cache input wires
   wire [4:0] cacheTagIn;  
   wire [7:0] cacheIndexIn; 
   wire [2:0] cacheOffsetIn;

   wire cacheCompareTag,
        // write is performed to the data selected by "index" and "offset",
        // and (if "comp"=0) to the tag selected by "index". 
        cacheWriteIn, 
        cacheValidIn;  

  //##################################################################


  //##########################FSM SIGNALS##########################
   reg cacheEnableReg; 
   reg cacheCompareTag_Reg; 
   reg cacheWriteReg; 
   reg [15:0] cacheDataIn_Reg; 

   // maybe not need 5 bits?
   wire [4:0] currentState;
   
   /*
    Since we can't use always(@posedge clk, negedge rst) 
    to update the state, we have to use a flip flop to
    essentially do the same thing. Enable signal doesn't apply, so always 1
  */

   //TODO: not sure if the [4:0] thing wirjs
   dff currentStateDFF [4:0] (.d(currentState), .q(nextState), .clk(clk),.rst(rst), .en(1'b1));

   // TODO: not sure if can do this
   //reg [4:0]  nextState;
   enum reg [4:0] {IDLE, COMP_RD, ACCESS_WRITE, COMP_WR, ACCESS_READ, DONE} nextState; 

  //##################################################################

  

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cacheTagOut),
                          .data_out             (cacheDataOut),
                          .hit                  (cacheHitOut),
                          .dirty                (cacheDirtyOut),
                          .valid                (cacheValidOut),
                          .err                  (cacheErrOut),
                          // Inputs
                          .cacheEnableReg       (cacheEnableReg),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cacheTagIn),
                          .index                (cacheIndexIn),
                          .offset               (cacheOffsetIn),
                          .data_in              (cacheDataIn_Reg),
                          .cacheCompareTag      (cacheCompareTag),
                          .write                (cacheWriteReg),
                          .valid_in             (cacheValidIn));


   four_bank_mem mem(// Outputs
                     .data_out          (four_bank_DataOut),
                     .stall             (four_bank_stall_out),
                     .busy              (four_bank_busy_out),
                     .err               (four_bank_ErrOut),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (four_bank_AddressIn),
                     .data_in           (DataOut),
                     .wr                (four_bank_Write),
                     .rd                (four_bank_Read));

   
   // your code here

   
endmodule // mem_system

