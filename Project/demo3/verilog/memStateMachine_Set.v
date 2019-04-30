/* 
   CS/ECE 552, Spring '19   
   Project                           
  
   Filename        : memStateMachine.v          
   Description     : This module is contains the logic for a Mealy FSM.  This FSM
                     controls the interaction between the cache and memory for the
                     set associative.            
*/
module memStateMachine_Set (/*AUTOARG*/
                            // Outputs
                            fsmDataOut,
                            AddrOut,  
                            wordOut,
                            done, 
                            cacheWrite0,
                            cacheWrite1, 
                            memWrite,          
                            memRead, 
                            comp0,
                            comp1,
                            enC0,
                            enC1,           
                            stallOut,
                            currState,
                            err,
                            // Inputs
                            victimway,
                            cacheDataOut,             
                            memDataOut, 
                            data_in, 
                            tagInC0,
                            tagInC1,
                            busy, 
                            Rd, 
                            Wr, 
                            Addr,            
                            clk, 
                            rst, 
                            validOutC0,
                            validOutC1,
                            dirtyOutC0,
                            dirtyOutC1,           
                            hitC0,
                            hitC1, 
                            stall,
                            isBranch);

   parameter                  DATA_SIZE = 16, TAG_SIZE = 5, STATE_SIZE = 4;

   parameter                  NODATAOUT = 16'h0, ON = 1'b1, OFF = 1'b0;
   
   // state parameters
   parameter                  // "other" states
                              IDLE = 4'd0, DONE = 4'd12, CACHERW = 4'd11,
                              // Access Write states
                              ACCWRITE0 = 4'd5, ACCWRITE1 = 4'd6, ACCWRITE2 = 4'd7, 
                              ACCWRITE3 = 4'd8, ACCWRITE4 = 4'd9, ACCWRITE5 = 4'd10,
                              // Access Read states
                              ACCREAD1 = 4'd1, ACCREAD2 = 4'd2, ACCREAD3 = 4'd3, 
                              ACCREAD4 = 4'd4; 

   output reg [DATA_SIZE-1:0] fsmDataOut, AddrOut;
   output reg [1:0]           wordOut;
   output reg                 done, cacheWrite0, cacheWrite1, memWrite, memRead, comp0,
                              comp1, enC0, enC1, stallOut;
   output [STATE_SIZE-1:0]    currState;
   output                     err;

   input [DATA_SIZE-1:0]      cacheDataOut, memDataOut, data_in, Addr;
   input [TAG_SIZE-1:0]       tagInC0, tagInC1;
   input [3:0]                busy;
   input                      Rd, Wr, clk, rst, validOutC0, validOutC1, dirtyOutC0,
                              dirtyOutC1, hitC0, hitC1, stall, victimway, isBranch;

   // regs
   reg [STATE_SIZE-1:0]       state;

   // wire
   wire [STATE_SIZE-1:0]      nextState;
   reg                        compRead_Write, compWrite_Read;
   
   // wires for latches
   wire [DATA_SIZE-1:0]       latchAddr, latchDataIn;
   reg [TAG_SIZE-1:0]         correctTag;
   wire                       latchWR, latchRW, latchWay;       

   wire                       errWay, waySel;              
   wire [STATE_SIZE-1:0]      wayState;
   
   // enable signal for various inputs (to be held in FF's)
   reg                        enLatches;          

   // hit and valid signals
   assign hitValid0 = (hitC0 && validOutC0);
   assign hitValid1 = (hitC1 && validOutC1);
   // hit, valid, Rd/Wr, not stall/rst signal
   assign hitStayInIdle = ((hitValid0 || hitValid1) && 
                           ({Rd, Wr} == 2'b01 || {Rd, Wr} == 2'b10) && ~stall && ~rst);
   assign readOrWrite = (~stall && ~rst && ({Rd, Wr} == 2'b10 || {Rd, Wr} == 2'b01));

   // get values from waySelect block to use in Idle state
   waySelect getIdleVals (// Outputs
                          .waySel(waySel),
                          .nextState(wayState),        
                          .err(errWay),
                          // Inputs
                          .hitC0(hitC0),               
                          .hitC1(hitC1),
                          .validC0(validOutC0),          
                          .validC1(validOutC1),       
                          .dirtyC0(dirtyOutC0),
                          .dirtyC1(dirtyOutC1),
                          .victimway(victimway)
                          );
   
   // 2-way set associative cache FSM
   always @* begin
      enLatches = OFF;
      stallOut = ON;
      correctTag = 5'b0;
      case (nextState)
        /*
         Idle is where our state machine will start each "loop."  It will stay here
         if it encounters a hit and is valid (with done --> 1).  Otherwise, based on
         various cases, it will do an Access Read or Write (unless memory is stalling
         or we are in reset).
         */
        IDLE :
          begin
             /*
              if in Idle and our memory is stalling or we're in reset, stay in Idle
              if in Idle and we get {Rd, Wr} == 10 or 01 (and not stalling or
              resetting), need to check dirty, valid, and hit to see if we had a hit
              or not.
              a) hit = valid = 1 --> stay in Idle, done = 1, DataOut = cacheDataOut (if
              reading)
              
              (if either hits, use that one and ignore the other, output right away)
              see State Transition Table for rest
              */
             state = ((rst || stall || hitStayInIdle || isBranch) ? IDLE :    
                      (({Rd,Wr} == 2'b01 || {Rd,Wr} == 2'b10) ? wayState : IDLE));
             
             // we want to take the newly inputted values when in reset
             enLatches = ON;
             // don't stall when in Idle
             stallOut = OFF;
             
             // assign compRead_Write and compWrite_Read as listed in table
             compWrite_Read = ((~stall && ~rst && ~(hitValid0 || hitValid1) && 
                                ({Rd,Wr} == 2'b01)) ? ON : OFF);
             compRead_Write = ((~stall && ~rst && ~(hitValid0 || hitValid1) && 
                                ({Rd,Wr} == 2'b10)) ? ON : OFF);
             
             // assign outputs
             // if we are trying to write to the cache, we want to output the inputted
             // data, otherwise nothing
             fsmDataOut = ((~stall && ~rst && ({Rd,Wr} == 2'b01)) ? data_in : 
                           NODATAOUT);                  
             AddrOut = Addr;         
             wordOut = Addr[2:1];        
             // if we had a hit and it was valid, done should be high
             done = hitStayInIdle;
             // if we're doing a write and that cache has a hit, then we should write
             // it
             cacheWrite0 = ((~rst && ~stall && {Rd, Wr} == 2'b01 && hitValid0) ? ON : 
                            OFF);
             cacheWrite1 = ((~rst && ~stall && {Rd, Wr} == 2'b01 && hitValid1) ? ON : 
                            OFF);
             memWrite = OFF;
             memRead = OFF;
             comp0 = ((readOrWrite) ? ON : OFF);
             comp1 = ((readOrWrite) ? ON : OFF);
             enC0 = ((readOrWrite) ? ON : OFF);
             enC1 = ((readOrWrite) ? ON : OFF);
          end // case: IDLE
        // first cycle of Access Read (read word0 from cache, store word0 to mem bank0)
        ACCREAD1 :
          begin
             // since not worrying about stalling, just go to the next Access Read 
             // state
             state = ACCREAD2;

             // we want to read from the cache here (the correct way of the cache)
             fsmDataOut = cacheDataOut;
             
             done = OFF;
             // always doing a read of the cache (irregardless of way) here
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = ON;       // to write to bank0 of memory
             memRead = OFF;
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);

             // choose the tag corresponding to the correct cache
             correctTag[4:0] = ((latchWay) ? tagInC1 : tagInC0);        
             AddrOut = {correctTag, latchAddr[10:3], 2'b00, 1'b0}; // write to bank0 of
             // memory               
             wordOut = 2'b00;  // read word0 from the cache
          end // case: ACCREAD1
        // second cycle of Access Read (read word1 from cache, store word1 to memory 
        // bank1)
        ACCREAD2 :
          begin
             // since not worrying about stalling, just go to the next Access Read 
             // state
             state = ACCREAD3;

             // we want to either read from or write to the cache here
             fsmDataOut = cacheDataOut;// value from cache to write to memory
             
             done = OFF;
             // always doing a read of the cache (irregardless of way) here
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = ON;
             memRead = OFF;
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             // choose the tag corresponding to the correct cache
             correctTag[4:0] = ((latchWay) ? tagInC1 : tagInC0);
             // tags were different, so we want the tag from the cache
             // since byte addressable
             AddrOut = {correctTag, latchAddr[10:3], 2'b01, 1'b0}; // write to bank1 of
             // mem
             wordOut = 2'b01;  // read word1 from the cache
          end // case: ACCREAD2
        // third cycle of Access Read (read word2 from cache, write word2 to mem bank2)
        ACCREAD3 :             
          begin           
             // since not worrying about stalling, just go to the next Access Read
             // state
             state = ACCREAD4;

             // we want to either read from or write to the cache here
             fsmDataOut = cacheDataOut;// value from cache to write to memory
             done = OFF;
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = ON;
             memRead = OFF;
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             // choose the tag corresponding to the correct cache
             correctTag[4:0] = ((latchWay) ? tagInC1 : tagInC0);         
             // tags were different, so we want the tag from the cache
             // since byte addressable
             AddrOut = {correctTag, latchAddr[10:3], 2'b10, 1'b0}; // write to bank2 of
             // mem
             wordOut = 2'b10;  // read word2 from the cache
          end // case: ACCREAD3
        // fourth cycle of Access Read (read word3 from cache, store word3 to memory
        //  bank3)
        ACCREAD4 :
          begin
             // go to Access Write next (we need to replace the cache line always after
             // an Access Read)
             state = ACCWRITE0;

             fsmDataOut = cacheDataOut;// value from cache to write to memory
             done = OFF;
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = ON;
             memRead = OFF;
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             // choose the tag corresponding to the correct cache
             correctTag[4:0] = ((latchWay) ? tagInC1 : tagInC0);
             // tags were different, so we want the tag from the cache
             // since byte addressable
             AddrOut = {correctTag, latchAddr[10:3], 2'b11, 1'b0}; // write to bank3
             // of mem
             wordOut = 2'b11;
          end // case: ACCREAD4
        // first cycle of doing an Access Write (read bank 0 of memory)
        ACCWRITE0 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next 
             // AccWr state
             state = ACCWRITE1;

             fsmDataOut = NODATAOUT;

             done = OFF;
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = OFF;
             memRead = ON;  // to read bank 0 of mem
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             // **
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             // **       
             AddrOut = {latchAddr[15:3], 2'b0, 1'b0};  // to guarantee read from bank0
             wordOut = latchAddr[2:1];
          end // case: ACCWRITE0
        // second cycle of Access Write (read bank 1 of memory)
        ACCWRITE1 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next
             // AccWr state
             state = ACCWRITE2;

             fsmDataOut = NODATAOUT;
             done = OFF;
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = OFF;
             memRead = ON;
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             // **
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             //      enC0 = OFF;
             //      enC1 = OFF;
             // **    
             AddrOut = {latchAddr[15:3], 2'b01, 1'b0}; // read from bank1
             wordOut = latchAddr[2:1];
          end // case: ACCWRITE1
        // third cycle of Access Read (read bank 2 of memory, write word0 of cache)
        // Note: bank0 of memory returns this cycle, so we can write the cache now
        ACCWRITE2 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next 
             // AccWr state
             state = ACCWRITE3;

             fsmDataOut = memDataOut; // write this to cache word0
             done = OFF;
             // only want to right to the correct way of the cache
             cacheWrite0 = ((latchWay) ? OFF : ON);
             cacheWrite1 = ((latchWay) ? ON : OFF);
             memWrite = OFF;
             memRead = ON;
             // comp = 0 so we can write
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             AddrOut = {latchAddr[15:3], 2'b10, 1'b0};  // read from bank2
             wordOut = 2'b00;                           // want to write to word0
          end // case: ACCWRITE2
        // fourth cycle of Access Read (read bank3 of memory, write word1 of cache)
        ACCWRITE3 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next
             //  AccWr state
             state = ACCWRITE4;

             fsmDataOut = memDataOut; // write this to cache word1
             done = OFF;
             // only want to right to the correct way of the cache
             cacheWrite0 = ((latchWay) ? OFF : ON);
             cacheWrite1 = ((latchWay) ? ON : OFF);
             memWrite = OFF;
             memRead = ON;
             // comp = 0 so we can write
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             AddrOut = {latchAddr[15:3], 2'b11, 1'b0};
             wordOut = 2'b01;         // want to write to word1
          end // case: ACCWRITE3
        // fifth cycle of Access Write (write word2 to cache)
        ACCWRITE4 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next
             //  AccWr state
             state = ACCWRITE5;

             fsmDataOut = memDataOut; // write this to cache word2
             done = OFF;
             // only want to right to the correct way of the cache
             cacheWrite0 = ((latchWay) ? OFF : ON);
             cacheWrite1 = ((latchWay) ? ON : OFF);
             // no longer reading from memory (or writing to it)
             memWrite = OFF;
             memRead = OFF;
             // comp = 0 so we can write
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             AddrOut = latchAddr;
             wordOut = 2'b10;         // want to write to word2
          end // case: ACCWRITE4
        // sixth cycle of Access Write (write word3 to cache)
        ACCWRITE5 :
          begin
             // for now we are ignoring stalls / busy, so we can just go to the next
             //  AccWr state
             state = CACHERW;

             fsmDataOut = memDataOut; // write this to cache word3
             done = OFF;
             // only want to right to the correct way of the cache
             cacheWrite0 = ((latchWay) ? OFF : ON);
             cacheWrite1 = ((latchWay) ? ON : OFF);
             memWrite = OFF;
             memRead = OFF;
             // comp = 0 so we can write
             comp0 = OFF;
             comp1 = OFF;
             // assign each cache to be enabled if it is the correct way
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             AddrOut = latchAddr;
             wordOut = 2'b11;         // want to write to word3
          end // case: ACCWRITE5
        // after doing an Access Write or an Access Read and Access Write, we either
        // want to read from the cache or write to the cache
        CACHERW :
          begin
             // done after this cycle (so go to Done)
             state = DONE;

             /*
              we want to either read from or write to the cache here
              second part is wrong, if we want to do a read, we don't get the data 
              until the next cycle
              */
             fsmDataOut = ((latchWR) ? latchDataIn : NODATAOUT); 
             done = OFF;
             /*
              if we were initially doing a compRead, then we want to read from the
              cache here (valid = 0) 
              if we were initially doing a compWrite, then we want to write to the
              cache here (valid = 1)
              use latchWay to decide which cacheWrite gets a 1 (if any)
              */
             cacheWrite0 = ((~latchWay && latchWR) ? ON : OFF);
             cacheWrite1 = ((latchWay && latchWR) ? ON : OFF);
             memWrite = OFF;
             memRead = OFF;
             // only have the correct way have comp high
             comp0 = ((latchWay) ? OFF : ON);
             comp1 = ((latchWay) ? ON : OFF);
             // only have correct way have en be high
             enC0 = ((latchWay) ? OFF : ON);
             enC1 = ((latchWay) ? ON : OFF);
             AddrOut = latchAddr;
             wordOut = latchAddr[2:1];
          end // case: CACHERW
        // Done simply sets done = 1.  It used to also take DataOut from the cache on
        // a read but that is now handled outside this module.
        DONE :
          begin
             // since we're done, go to Idle next
             state = IDLE;

             fsmDataOut = NODATAOUT;
             done = ON; // since we're done :)
             cacheWrite0 = OFF;
             cacheWrite1 = OFF;
             memWrite = OFF;
             memRead = OFF;
             comp0 = OFF;
             comp1 = OFF;
             // only want the correct way to be enabled (so we can read from the cache)
             enC0 = ((latchRW && ~latchWay) ? ON : OFF);
             enC1 = ((latchRW && latchWay) ? ON : OFF);
             AddrOut = latchAddr;
             wordOut = latchAddr[2:1];
          end // case: DONE
        default :
          begin
             // go to Access Write next                
             state = IDLE;

             fsmDataOut = NODATAOUT;   
             done = OFF;   
             cacheWrite0 = OFF;  
             cacheWrite1 = OFF;     
             memWrite = OFF;  
             memRead = OFF;
             comp0 = OFF;         
             comp1 = OFF;
             enC0 = OFF;
             enC1 = OFF;
             AddrOut = NODATAOUT;
             wordOut = 2'b00;
          end // case: default
      endcase // case(nextState)       
   end // always @*
              
   // for output
   assign currState = nextState;       
   assign err = errWay;
            
   /*
    Here we are using FF's to latch some of the inputs we have.  This way we preserve
    their values in case the user / processor changes them midway through the states.
    */
   // dff to keep track of Read_Write
   dffe #(1) rwSignal (.d(compRead_Write), 
                       .q(latchRW), 
                       .clk(clk), 
                       .rst(rst),
                       .en(enLatches));        
   
   // dff to keep track of Write_Read
   dffe #(1) wrSignal (.d(compWrite_Read), 
                       .q(latchWR),               
                       .clk(clk), 
                       .rst(rst),
                       .en(enLatches));        

   // latch the way select
   dffe #(1) latchWaySel (.d(waySel), 
                          .q(latchWay), 
                          .clk(clk), 
                          .rst(rst),
                          .en(enLatches));
   
   
   // dff to latch data_in
   dffe latchDataSignal (.d(data_in), 
                         .q(latchDataIn), 
                         .clk(clk), 
                         .rst(rst),
                         .en(enLatches));
   
   // dff to latch the address for AccessRead and AccessWrites
   dffe latchAddrSignal (.d(Addr), 
                         .q(latchAddr),          
                         .clk(clk), 
                         .rst(rst),          
                         .en(enLatches));
   
   // FF to hold state variable and clock on posedge         
   dff stateReg[STATE_SIZE-1:0] (.d(state), 
                                 .q(nextState),          
                                 .clk(clk), 
                                 .rst(rst),
                                 .enable(1'b1));        
   
endmodule // memStateMachine_Set  
