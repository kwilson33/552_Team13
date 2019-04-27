/* 
   CS/ECE 552, Spring '19
   Project
  
   Filename        : mem_system.v
   Description     : This is the memory system.  It is the top-level module for all
                     caches, stalling memory, etc. used in the project.
                     This version implements the 2-way set associative cache.
*/
module mem_system(/*AUTOARG*/
                  // Outputs
                  DataOut,
                  Done,
                  Stall,    
                  CacheHit,    
                  err,    
                  // Inputs
                  Addr,
                  DataIn,    
                  Rd,    
                  Wr,   
                  createdump,   
                  clk,   
                  rst  
                  );    
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output        Done;
   output        Stall;
   output        CacheHit;
   output        err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   parameter    NODATAOUT = 16'h0000;

   // to make it binary
   assign memType = memtype[0];   

   // You must pass the memtype parameter 
   // and createdump inputs to the 
   // cache modules

   wire [4:0]    cacheTagOutC0, cacheTagOutC1;
   wire [1:0]    FSMWordOut;
   wire [15:0]   cacheDataOutC0, cacheDataOutC1, memDataOut, FSMDataOut, FSMAddrOut;

   wire          memStall, memErr, cacheErrC0, cacheErrC1, errFSM, FSMEnC0, FSMEnC1, 
                 FSMCompC0, FSMCompC1, cacheWriteC0,
                 cacheWriteC1;
   wire          FSMmemWrite, FSMmemRead, cacheHitOutC0, cacheHitOutC1, cacheDirtyOutC0,
                 cacheDirtyOutC1, cacheValidOutC0, cacheValidOutC1;        
   wire [3:0]    memBusy, state;               

   // internal wires
   wire [15:0]   fsmCacheDataIn, cacheHitDataOut;
   wire          victimway, inVictimWay, inVictWayDCache, inVictWayICache, invalidOP,
                 errOp, holdEn1;

   assign idleHit = ((cacheHitOutC0 && cacheValidOutC0) || 
                     (cacheHitOutC1 && cacheValidOutC1));
   
   /* 
    miss logic - if we aren't in the Done state or in the Idle state and don't have 
    hit1 & valid1 or hit0 & valid0 then we don't want to take any data for DataOut
    */
   assign takeData = ((state == 4'b1100) || (idleHit && state == 4'b0000));
   assign noData = ~takeData;

   // selDCache logic - if not stalling, not memory stalling, not flushing, not an
   // invalid instruction and we're doing a Read or Write - then invert victimway
   assign selDCache = (~invalidOP && ~memStall && ~Stall && (Rd || Wr));   
   
   // first of 2 caches (way 0)
   cache #(.cache_id(0 + memtype)) c0 (// Inputs
                                       .enable(FSMEnC0),
                                       .clk(clk),           
                                       .rst(rst),
                                       .createdump(createdump),
                                       .tag_in(FSMAddrOut[15:11]),   
                                       .index(FSMAddrOut[10:3]),    
                                       .offset({FSMWordOut, 1'b0}),   
                                       .data_in(FSMDataOut),   
                                       .comp(FSMCompC0),
                                       .write(cacheWriteC0),
                                       .valid_in(1'b1),            
                                       // Outputs
                                       .tag_out(cacheTagOutC0),
                                       .data_out(cacheDataOutC0),
                                       .hit(cacheHitOutC0),
                                       .dirty(cacheDirtyOutC0),
                                       .valid(cacheValidOutC0),
                                       .err(cacheErrC0)
                                       );

   // second of 2 caches (way 1)
   cache #(.cache_id(2 + memtype)) c1 (// Inputs
                                       .enable(FSMEnC1),
                                       .clk(clk),
                                       .rst(rst),
                                       .createdump(createdump),
                                       .tag_in(FSMAddrOut[15:11]),
                                       .index(FSMAddrOut[10:3]),
                                       .offset({FSMWordOut, 1'b0}),
                                       .data_in(FSMDataOut),             
                                       .comp(FSMCompC1),
                                       .write(cacheWriteC1),             
                                       .valid_in(1'b1),
                                       // Outputs
                                       .tag_out(cacheTagOutC1),
                                       .data_out(cacheDataOutC1),
                                       .hit(cacheHitOutC1),   
                                       .dirty(cacheDirtyOutC1),
                                       .valid(cacheValidOutC1),
                                       .err(cacheErrC1)
                                       );        

   // 2-1 16-bit mux to decide which cacheDataOut should go into the FSM
   // select uses logic from caches / FSM
   // if one of the caches is enabled, we always want to use that one (i.e. Access
   // Reads)
   mux2_1_16b muxCacheDataOut (.i0(cacheDataOutC0),
                               .i1(cacheDataOutC1),
                               .Sel(holdEn1),
                               .out(fsmCacheDataIn));             
   
   // 2-way set associative cache controller (FSM)
   memStateMachine_Set twoWayStateMach (// Outputs
                                        .fsmDataOut(FSMDataOut), 
                                        .AddrOut(FSMAddrOut), 
                                        .wordOut(FSMWordOut),
                                        .done(Done),
                                        .cacheWrite0(cacheWriteC0),
                                        .cacheWrite1(cacheWriteC1),
                                        .memWrite(FSMmemWrite), 
                                        .memRead(FSMmemRead), 
                                        .comp0(FSMCompC0),         
                                        .comp1(FSMCompC1),         
                                        .enC0(FSMEnC0),          
                                        .enC1(FSMEnC1),
                                        .stallOut(Stall),
                                        .currState(state),
                                        .err(errFSM),
                                        // Inputs
                                        .tagInC0(cacheTagOutC0),
                                        .tagInC1(cacheTagOutC1),
                                        .victimway(inVictimWay),
                                        .cacheDataOut(fsmCacheDataIn), 
                                        .memDataOut(memDataOut), 
                                        .data_in(DataIn), 
                                        .busy(memBusy), 
                                        .Rd(Rd), 
                                        .Wr(Wr), 
                                        .Addr(Addr), 
                                        .clk(clk), 
                                        .rst(rst),             
                                        .validOutC0(cacheValidOutC0),       
                                        .validOutC1(cacheValidOutC1),
                                        .dirtyOutC0(cacheDirtyOutC0),
                                        .dirtyOutC1(cacheDirtyOutC1),
                                        .hitC0(cacheHitOutC0),
                                        .hitC1(cacheHitOutC1), 
                                        .stall(memStall)
                                        );

   four_bank_mem fourBankMem (// Inputs
                              .clk(clk),            
                              .rst(rst),
                              .createdump(createdump),
                              .addr(FSMAddrOut),
                              .data_in(FSMDataOut),
                              .wr(FSMmemWrite),
                              .rd(FSMmemRead),
                              // Outputs
                              .data_out(memDataOut),             
                              .stall(memStall),
                              .busy(memBusy),
                              .err(memErr)
                              );

   // use 2 2-1 muxes to output DataOut correctly
   // if we get a hit0 and valid0, then we want to take that one
   // similarly for hit1 and valid1
   // this should also work for reading after going to memory since hit and valid will
   // be high there too (they just won't cause CacheHit to go high in that state)
   mux2_1_16b muxHit (.i0(cacheDataOutC0),
                      .i1(cacheDataOutC1),
                      .Sel((cacheHitOutC1 && cacheValidOutC1)),
                      .out(cacheHitDataOut));

   // if we have a miss, we want to output 0
   mux2_1_16b muxDataOut (.i0(cacheHitDataOut),
                          .i1(NODATAOUT),       
                          .Sel(noData),
                          .out(DataOut));       

   // victimway FF
   dffe #(1) dffVictim (.d(inVictimWay),
                        .q(victimway),             
                        .clk(clk),
                        .rst(rst),
                        .en(1'b1));          
   
   // muxes for input to victim way
   // for an I Cache, if we aren't stalling, then we want to invert the victimway bit
   // (invert for every instruction fetched)
   mux2_1_16b #(1) muxVictimICache (.i0(victimway), 
                                    .i1(~victimway),
                                    .Sel(~memStall && ~Stall),          
                                    .out(inVictWayICache));          

   // for a D Cache, if we aren't stalling, flushing, or getting an invalid 
   // instruction, and we are doing a read or write, then we want to invert the
   // victimway bit
   // ** Instructions that are flushed have thier contol signals set to 0...thus Read
   // and Write would = 0 for them (so in essence flush is implicit in the logic)
   mux2_1_16b #(1) muxVictimDCache (.i0(victimway), 
                                    .i1(~victimway),          
                                    .Sel(selDCache),            
                                    .out(inVictWayDCache));         

   // depending on the input parameter that tells us if it's an I or D cache, take the
   // correct victimway input (use the parameter memtype as this select)
   mux2_1_16b #(1) muxInVictimWay (.i0(inVictWayICache),
                                   .i1(inVictWayDCache),
                                   .Sel(memType),
                                   .out(inVictimWay));        
   
   // use the upper 5 bits of the address to deduce if the opcode passed in is invalid
   invalidOpCode invOp (// Outputs
                        .err(errOp),
                        .invalidOp(invalidOP),      
                        // Inputs            
                        .Op(FSMAddrOut[15:11]));

   // we want to hold the enable signal for an entire "cycle" of signals, only
   // changing when we're in Idle
   dffe #(1) holdEnC1 (.d(FSMEnC1 && cacheValidOutC1 && cacheDirtyOutC1 && 
                          ~cacheHitOutC1 && inVictimWay),
                       .q(holdEn1),
                       .en((state == 4'b0000)),
                       .clk(clk),
                       .rst(rst));
   
   assign   err = (cacheErrC0 || cacheErrC1 || memErr || errOp || errFSM);
   // if we went to memory to get the value, then we don't want CacheHit to be high
   assign   CacheHit = (((cacheHitOutC0 && cacheValidOutC0) || 
                         (cacheHitOutC1 && cacheValidOutC1)) &&        
                        (state == 4'b0000) && Done);            
   
endmodule // mem_system                 
// DUMMY LINE FOR REV CONTROL :9:
