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

   localparam assert = 1'b1; 
   localparam no_assert = 1'b0; 

   //##########################FOUR BANK MEM SIGNALS########################################################
   // Outputs of four_bank_mem
   wire [15:0] four_bank_DataOut;
   wire four_bank_stall_out, four_bank_busy_out, four_bank_ErrOut;

   // The input to the four_bank_mem is the DataOut of mem_system
   // Inputs to four bank mem
   wire [15:0] four_bank_AddressIn;
   

   // how git repo does it
   // assign four_bank_AddressIn = {tag_mem, cAddr_sel[10:3], offset_mem};
   // assign DataOut = hit ? (hit_sel0 ? cache_data_out0 : cache_data_out1) : (comp ? comp_data_sel : access_data_sel);
   //#########################################################################################################


    //##########################CACHE SIGNALS################################################################
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
  //#########################################################################################################


  //###################################################FSM SIGNALS#########################################
   reg cacheEnableReg, Done, Stall, cache_hit, cacheCompareTag, cacheWriteReg, write, read;  
   reg [15:0] cacheDataIn, cacheAddress, memDataIn;
   reg [4:0] memoryTag; 
   reg [2:0] memoryOffset;  
   reg four_bank_Read, four_bank_Write;
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
   enum reg [4:0] {IDLE, COMP_RD, ACCESS_WRITE, COMP_WR, ACCESS_READ, 
                  RD_B0, RD_B1, RDB2_WRB0, RDB3_WRB1, WR_B2, WR_B3, 
                  EVICT_B0, EVICT_B1, EVICT_B2, EVICT_B3, DONE} nextState; 
   //#########################################################################################################
  

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
                          .valid_in             (cacheValidIn)); // maybe hardwire to 1 according to matt


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


   //##########################################ASSIGN WIRES #################################################
   assign cacheValidIn = 1'b1;
  
   assign cacheTagIn =   cacheAddress [15:11]
   assign cacheIndexIn = cacheAddress[10:3];
   assign cacheOffsetIn = cacheAddress[2:0];
   assign four_bank_AddressIn = {cacheTagIn, cacheIndexIn, cacheOffsetIn};

   assign DataOut = cacheDataOut;
   assign err = cacheErrOut | four_bank_ErrOut;

   //#########################################################################################################

   always @(*) begin

      //Initialize things here
      Done = no_assert; 
      Stall = no_assert; 
      write = no_assert; 
      read = no_assert; 

      cacheCompareTag = no_assert; 
      cacheEnableReg = no_assert; 
      cacheWriteReg = no_assert; 
      cacheDataIn = DataIn;
      cacheAddress = Addr; 
        
      memoryTag = Addr[15:11]; 
      memoryOffset = 3'b000; 

      nextState = IDLE;

      case(currentState)

        IDLE: begin 
            Stall = no_assert; 
            cacheEnableReg = assert; 

            nextState = 
        end


        COMP_RD: begin
            cacheEnableReg = assert; 
            cacheCompareTag = assert; 
            cacheWriteReg = no_assert; 

            nextState = 
        end


        COMP_WR: begin
            cacheEnableReg = assert; 
            cacheCompareTag = assert; 
            cacheWriteReg = assert; 

            nextState = 
        end


        ACCESS_WRITE: begin
            cacheEnableReg = assert; 
            cacheCompareTag = no_assert; 
            cacheWriteReg = assert; 

            nextState = 
        end


        ACCESS_READ: begin
            cacheCompareTag = no_assert; 
            cacheWriteReg = no_assert; 


            nextState = RD_B0; 
        end
        


        RD_B0 : begin
            read = assert; 

            nextState = RD_B1; 
        end

        RD_B1 : begin
            read = assert;

            nextState = RDB2_WRB0; 
        end

        RDB2_WRB0 : begin
            read = assert;

            nextState = RDB3_WRB1; 
        end

        RDB3_WRB1 : begin
           read = assert;

           nextState = WR_B2; 
        end

        WR_B2 : begin 

           nextState = WR_B3; 
        end

        WR_B3 : begin

        end

        // cacheWriteReg should be 1 since you come here from CompWR, CompRd
        EVICT_B0 : begin
            four_bank_Write = assert;
            cacheEnableReg = assert;
            memoryTag = cacheTagOut; 
            memoryOffset = 3'b000;
            cacheAddress = {Addr[15:3], 3'b000}; 


             nextState = EVICT_B1; 

        end

        EVICT_B1 : begin
            four_bank_Write = no_assert; 
            cacheEnableReg = assert;
            cacheWriteReg = assert;
            memoryTag = cacheTagOut; 
            memoryOffset = 3'b010;
            cacheAddress = {Addr[15:3], 3'b010}; 

            nextState = EVICT_B2;

        end

        EVICT_B2 : begin
            four_bank_Write = assert; 
            cacheEnableReg = assert;
            memoryTag = cacheTagOut; 
            memoryOffset = 3'b100; 
            cacheAddress = {Addr[15:3], 3'b100}; 

            nextState = EVICT_B3;

        end

        EVICT_B3 : begin
            four_bank_Write = assert;
            cacheEnableReg = assert; 
            memoryOffset = 3'b110;
            memoryTag = cacheTagOut; 
            cacheAddress = {Addr[15:3], 3'b110}; 

            nextState = ACCESS_READ; 

        end 

        DONE: begin
            Done = assert; 
            nextState = IDLE;
        end

        default: begin
            nextState = IDLE;
        end

      endcase 

   end

   
endmodule // mem_system

