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

   localparam assert = 1'b1; 
   localparam no_assert = 1'b0; 

   //##########################FOUR BANK MEM SIGNALS########################################################
   // Outputs of four_bank_mem
   wire [15:0] four_bank_DataOut;
   wire four_bank_stall_out, four_bank_ErrOut;
   wire [3:0] four_bank_busy_out; 
   // The input to the four_bank_mem is the DataOut of mem_system
   // Inputs to four bank mem
   wire [15:0] four_bank_AddressIn;
   

   // how git repo does it
   // assign four_bank_AddressIn = {tag_mem, cAddr_sel[10:3], offset_mem};
   // assign DataOut = hit ? (hit_sel0 ? cache_data_out0 : cache_data_out1) : (comp ? comp_data_sel : access_data_sel);
   //#########################################################################################################


    //##########################CACHE SIGNALS################################################################
   //Cache output wires
   wire [4:0] cacheTagOut_0, cacheTagOut_1; 
   wire [15:0] cacheDataOut_0, cacheDataOut_1; 

   wire cacheValidIn,
        cacheHitOut_0, cacheHitOut_1, cacheDirtyOut_0, cacheDirtyOut_1, 
        cacheValidOut_0, cacheValidOut_1, cacheErrOut_0, 
        cacheErrOut_1, 

   //Cache input wires
   wire [4:0] cacheTagIn;  
   wire [7:0] cacheIndexIn; 
   wire [2:0] cacheOffsetIn;
          
  //#########################################################################################################

   //###################################################FSM SIGNALS#########################################
   // Done and Stall are outputs of this module
   reg cacheEnableReg, cacheCompareTag, cacheWriteReg_0, cacheWriteReg_1;
   reg [15:0] cacheDataIn_Reg, cacheAddressReg;
   reg [4:0] memoryTag; 
   reg [2:0] memoryOffset;  
   reg four_bank_ReadReg, four_bank_WriteReg, memSystemCacheHitReg;
   // maybe not need 5 bits?
   wire [4:0] currentState;
   
   /*
    Since we can't use always(@posedge clk, negedge rst) 
    to update the state, we have to use a flip flop to
    essentially do the same thing. Enable signal doesn't apply, so always 1
  */





   localparam   IDLE            = 5'b00000; //0
   localparam   COMP_RD         = 5'b00001; //1
   localparam   COMP_WR         = 5'b00010; //2
   localparam   RD_B0           = 5'b00011; //3
   localparam   RD_B1           = 5'b00100; //4
   localparam   RDB2_WRB0       = 5'b00101; //5
   localparam   RDB3_WRB1       = 5'b00110; //6
   localparam   WR_B2           = 5'b00111; //7
   localparam   WR_B3           = 5'b01000; //8
   localparam   EVICT_B0        = 5'b01001; //9
   localparam   EVICT_B1        = 5'b01010; //10
   localparam   EVICT_B2        = 5'b01011; //11
   localparam   EVICT_B3        = 5'b01100; //12
   localparam   FINALLY_WRITE   = 5'b01101; //13
   localparam   ERROR           = 5'b01110; //14
   localparam   DONE            = 5'b01111; //15
   localparam   WRITE_DONE      = 5'b10000; //16

   //#########################################################################################################

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (cacheTagOut_0),
                          .data_out             (cacheDataOut_0),
                          .hit                  (cacheHitOut_0),
                          .dirty                (cacheDirtyOut_0),
                          .valid                (cacheValidOut_0),
                          .err                  (cacheErrOut_0),
                          // Inputs
                          .enable               (cacheEnableReg),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cacheTagIn),
                          .index                (cacheIndexIn),
                          .offset               (cacheOffsetIn),
                          .data_in              (cacheDataIn_Reg),
                          .comp                 (cacheCompareTag),
                          .write                (cacheWrite0),
                          .valid_in             (cacheValidIn)); 

   
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (cacheTagOut_1),
                          .data_out             (cacheDataOut_1),
                          .hit                  (cacheHitOut_1),
                          .dirty                (cacheDirtyOut_1),
                          .valid                (cacheValidOut_1),
                          .err                  (cacheErrOut_1),
                          // Inputs
                          .enable               (cacheEnableReg),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (cacheTagIn),
                          .index                (cacheIndexIn),
                          .offset               (cacheOffsetIn),
                          .data_in              (cacheDataIn_Reg),
                          .comp                 (cacheCompareTag),
                          .write                (cacheWrite1),
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
                     .wr                (four_bank_WriteReg),
                     .rd                (four_bank_ReadReg));



   reg [4:0]  nextState;
   
  

//////////////////////SPECIFIC TO 2-WAY////////////////////////////

   wire victimwayIN, victimway,  way0_or_way1Dirty, 
        way0_or_way1Valid, way0_or_way1Hit;

   wire [4:0] way0_or_way1TagOut;

   reg invertVictim; 

   dff victimwayDFF (.d(victimwayIN), .q(victimway), .clk(clk),.rst(rst), .en(1'b1));
   assign victimwayIN = (invertVictim) ? ~victimway : victimway; 

   assign err = cacheErrOut_0 | cacheErrOut_1 | four_bank_ErrOut; 

   // if cacheHit0 is low, select  cacheDataOut_1, even if cacheHit1 is also low.
   assign DataOut = cacheHitOut_0 ? cacheDataOut_0 : cacheDataOut_1; 

   assign way0_or_way1TagOut = //TODO

   // FSM stuff - TODO, are dirty and hit assigned right??
   assign way0_or_way1Dirty = (cacheDirtyOut_0 | cacheDirtyOut_1); 
   assign way0_or_way1Hit = cacheHitOut_0 | cacheHitOut_1;
   assign way0_or_way1Valid = cacheValidOut_0 | cacheValidOut_1;

   // depend
   assign cacheWrite0 = (cacheWriteReg) ? () : no_assert; //TODO
   assign cacheWrite1 = (cacheWriteReg) ? () : no_assert;//TODO


   /*
    For the D cache, do not invert victimway for instructions that do not read or write cache, 
    or for invalid instructions, or for instructions that are squashed due to branch misprediction.
    or the I cache, invert victimway for each instruction fetched.

    Use the memtype parameter to decide
    memtype = 1 ==> data memory
    memtype = 0 ==> instruction memory
    */

///////////////////////////////////////////////////////////////////


//////////////////////Same as Direct//////////////////////////
   dff currentStateDFF [4:0] (.d(nextState), .q(currentState), .clk(clk),.rst(rst), .en(1'b1));

   assign cacheTagIn =   cacheAddressReg [15:11]; 
   assign cacheIndexIn = cacheAddressReg[10:3]; 
   assign cacheOffsetIn = cacheAddressReg[2:0];
   assign err = cacheErrOut | four_bank_ErrOut;
   assign four_bank_AddressIn = {memoryTag, Addr[10:3], memoryOffset}; 

//////////////////////////////////////////////////////////////


   
    always @(*) begin

      //Initialize things here
      invertVictim = no_assert; 
      Done = no_assert; 
      Stall = assert; 
      four_bank_WriteReg = no_assert;
      four_bank_ReadReg = no_assert;


      cacheCompareTag = no_assert; 
      cacheEnableReg = no_assert; 
      cacheWriteReg = no_assert; 
      cacheDataIn_Reg = DataIn;
      cacheAddressReg = Addr; 



      memSystemCacheHitReg = no_assert;

        
      memoryTag = Addr[15:11]; 
      memoryOffset = 3'b000; 

      nextState = IDLE;

      case(currentState)

        IDLE: begin 
            Stall = no_assert; 
            cacheEnableReg = assert; 

            nextState = ((Wr & Rd) | (~Wr & ~Rd)) ? IDLE 
                        : (Rd) ? COMP_RD : COMP_WR; 
         end


        COMP_RD: begin
            cacheEnableReg = assert; 
            cacheCompareTag = assert;

            // if (dirty and miss) nextState = EVICT_B0
            // if (!dirty and miss) nextState = RD_B0
            nextState = (way0_or_way1Hit & way0_or_way1Valid) ? DONE : 
                        (~way0_or_way1Dirty & (~way0_or_way1Valid | ~way0_or_way1Hit)) ? RD_B0 :
                        (way0_or_way1Dirty) ? EVICT_B0 : COMP_RD; 
        end


        COMP_WR: begin
            cacheEnableReg = assert; 
            cacheCompareTag = assert; 
            cacheWriteReg = assert; 

            // if (dirty & miss) nextState = EVICT_B0
            // if (!dirty & miss) nextState = RD_B0
            nextState = (way0_or_way1Hit & way0_or_way1Valid) ? DONE : 
                        (~way0_or_way1Dirty & (~way0_or_way1Valid | ~way0_or_way1Hit)) ? RD_B0 :
                        (way0_or_way1Dirty /*| Wr*/) ? EVICT_B0 : COMP_WR; // Kevin added the | Wr
        end

        // only change memoryTag when we want to be writing to the four bank mem, otherwise
        // keep it at Addr[15:11]
        EVICT_B0 : begin
            four_bank_WriteReg = assert;

            cacheEnableReg = assert;
            cacheAddressReg = {Addr[15:3], 3'b000}; 

            memoryTag = way0_or_way1TagOut; 
            memoryOffset = 3'b000;

            nextState = four_bank_stall_out ? EVICT_B0 : EVICT_B1; 

        end

        EVICT_B1 : begin
            four_bank_WriteReg = assert; 

            cacheEnableReg = assert;
            cacheAddressReg = {Addr[15:3], 3'b010}; 

            memoryTag = way0_or_way1TagOut; 
            memoryOffset = 3'b010;
            

            nextState = four_bank_stall_out ? EVICT_B1 : EVICT_B2;
        end

        EVICT_B2 : begin
            four_bank_WriteReg = assert; 

            cacheEnableReg = assert;
            cacheAddressReg = {Addr[15:3], 3'b100};

            memoryTag = way0_or_way1TagOut; 
            memoryOffset = 3'b100; 
             

            nextState = four_bank_stall_out ? EVICT_B2 : EVICT_B3;

        end

        EVICT_B3 : begin
            four_bank_WriteReg = assert;

            cacheEnableReg = assert; 
            cacheAddressReg = {Addr[15:3], 3'b110}; 

            memoryOffset = 3'b110;
            memoryTag = way0_or_way1TagOut; 
            // after done evicting line from the cache and writing it
            // to four_bank_mem, bring in new line from four_bank_mem
            // and store to cache in case you want it later 
            nextState = four_bank_stall_out ? EVICT_B3 : RD_B0;

        end 

        RD_B0 : begin
           // start reading bank 0 of four bank mem
            four_bank_ReadReg = assert; 
            memoryOffset = 3'b000;

            nextState = (four_bank_stall_out) ? RD_B0 : RD_B1; 
        end

        RD_B1 : begin
            // start reading bank 1 of four bank mem
            four_bank_ReadReg = assert;
            memoryOffset = 3'b010;
            //memoryTag = cacheTagOut; 
            //cacheAddressReg = {Addr[15:3], 3'b010}; 
            nextState = (four_bank_stall_out) ? RD_B1 : RDB2_WRB0;  
        end

        //State 5
        RDB2_WRB0 : begin
            four_bank_ReadReg = assert;
            cacheWriteReg = assert;
            cacheEnableReg = assert; 

            // start reading bank 2 of four bank mem
            memoryOffset = 3'b100;
           
            // write bank 0 of four bank mem to the cache
            cacheAddressReg = {Addr[15:3], 3'b000}; 
            cacheDataIn_Reg = four_bank_DataOut;

            nextState = (four_bank_stall_out) ? RDB2_WRB0 : RDB3_WRB1; 
        end

        RDB3_WRB1 : begin
            four_bank_ReadReg = assert;
            cacheWriteReg = assert;
            cacheEnableReg = assert;  

            // start reading bank 3 of four bank mem
            memoryOffset = 3'b110;
          

            // write bank 1 of four bank mem to the cache
            cacheAddressReg = {Addr[15:3], 3'b010}; 
            cacheDataIn_Reg = four_bank_DataOut;

            nextState = (four_bank_stall_out) ? RDB3_WRB1: WR_B2; 
        end

        WR_B2 : begin 
            cacheWriteReg = assert;
            cacheEnableReg = assert; 
                      
            // write bank 2 of four bank mem to the cache
            cacheAddressReg = {Addr[15:3], 3'b100}; 
            cacheDataIn_Reg = four_bank_DataOut;

            nextState = WR_B3; 
        end

        WR_B3 : begin
            cacheWriteReg = assert;
            cacheEnableReg = assert; 
           
            
            // write bank 3 of four bank mem to the cache
            cacheAddressReg = {Addr[15:3], 3'b110}; 
            cacheDataIn_Reg = four_bank_DataOut;

            // done writing four bank mem into the cache, so now
            // we can finally write cache line with new data or 
            // if Wr wasn't high to begin with, skip writing
            nextState = (Wr & ~Rd) ? FINALLY_WRITE : WRITE_DONE; 
        end

        //If we originally intended to do a write when we first started, finally 
        //we can write that data to the cache. 
        FINALLY_WRITE : begin
            cacheEnableReg = assert;
            cacheWriteReg = assert;
            cacheCompareTag = assert; 

            nextState = WRITE_DONE; 
        end

         //When we are done writing, check if there is still more work to be done
        // so it's possible we can skip the idle and continue reading or writing
        WRITE_DONE : begin
            Done = assert;
            Stall = no_assert; 
            cacheEnableReg = assert;
            invertVictim = assert; 
            nextState = ((Wr & Rd) | (~Wr & ~Rd)) ? IDLE 
                        : (Rd) ? COMP_RD : COMP_WR; 
        end

        DONE : begin
            // Assert Done to say that we are done reading or writing
            // Assert CacheHit to say we didn't miss in the cache.
            cacheEnableReg = assert;
            Done = assert;
            memSystemCacheHitReg = assert;
            Stall = no_assert; 

            invertVictim = assert; 
            // check if there is still more work to be done
           // so it's possible we can skip the idle and continue reading or writing
            nextState = ((Wr & Rd) | (~Wr & ~Rd)) ? IDLE 
                        : (Rd) ? COMP_RD : COMP_WR; 
        end

        default: begin
            nextState = IDLE;
        end
      endcase 

   end
   
endmodule // mem_system

   


// DUMMY LINE FOR REV CONTROL :9:
