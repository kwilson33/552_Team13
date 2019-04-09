/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc_hier_pbench();

   /* BEGIN DO NOT TOUCH */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics
   

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 15 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [2:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemDataIn;
   wire [15:0] MemDataOut;
   wire        DCacheHit;
   wire        ICacheHit;
   wire        DCacheReq;
   wire        ICacheReq;
   

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     trace_file;
   integer     sim_log_file;
     
   integer     DCacheHit_count;
   integer     ICacheHit_count;
   integer     DCacheReq_count;
   integer     ICacheReq_count;
   
   proc_hier DUT();

   

   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.ptrace for output");
      inst_count = 0;
      DCacheHit_count = 0;
      ICacheHit_count = 0;
      DCacheReq_count = 0;
      ICacheReq_count = 0;

      trace_file = $fopen("verilogsim.ptrace");
      sim_log_file = $fopen("verilogsim.log");
      
   end

   always @ (posedge DUT.c0.clk) begin
      if (!DUT.c0.rst) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         if (DCacheHit) begin
            DCacheHit_count = DCacheHit_count + 1;      
         end    
         if (ICacheHit) begin
            ICacheHit_count = ICacheHit_count + 1;      
         end    
         if (DCacheReq) begin
            DCacheReq_count = DCacheReq_count + 1;      
         end    
         if (ICacheReq) begin
            ICacheReq_count = ICacheReq_count + 1;      
         end    

         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                   DUT.c0.cycle_count,
                   PC,
                   Inst,
                   RegWrite,
                   WriteRegister,
                   WriteData,
                   MemRead,
                   MemWrite,
                   MemAddress,
                   MemDataIn);
         if (RegWrite) begin
            $fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
                      WriteRegister,
                      WriteData );            
         end
         if (MemRead) begin
            $fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataOut );
         end

         if (MemWrite) begin
            $fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataIn  );
         end
         if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", DUT.c0.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachehit_count %d\n", DCacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachehit_count %d\n", ICacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachereq_count %d\n", DCacheReq_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachereq_count %d\n", ICacheReq_count);

            $fclose(trace_file);
            $fclose(sim_log_file);
            #5;
            $finish;
         end 
      end
      
   end

   /* END DO NOT TOUCH */

   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Edit the example below. You must change the signal
   // names on the right hand side
 
 	  assign PC = DUT.p0.instructionFetch.PC_Register.readData;
    assign Inst = DUT.p0.instructionFetch.instruction;
    
    assign RegWrite = DUT.p0.MEM_WB_Stage.dff_MEMWB_RegWrite_out.q;

    assign WriteRegister = DUT.p0.instructionDecode.writeRegister;
    assign WriteData = DUT.p0.instructionWriteback.writeData;

    //assign MemRead =  DUT.p0.instructionDecode.controlUnit.DMemEn;
    assign MemRead =  (DUT.p0.EX_MEM_Stage.dff_EXMEM_DMemEn_out.q) 
                      & ~(DUT.p0.EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q) 
                      & dataMemory.dataMemoryModule.Done;

    assign MemWrite = (DUT.p0.EX_MEM_Stage.dff_EXMEM_DMemEn_out.q) 
                      & (DUT.p0.EX_MEM_Stage.dff_EXMEM_DMemWrite_out.q) 
                      & dataMemory.dataMemoryModule.Done;
    //assign MemWrite = (DUT.p0.instructionDecode.controlUnit.DMemEnRegister) & (DUT.p0.instructionDecode.controlUnit.DMemWrite);

    //assign MemDataIn = DUT.p0.EX_MEM_Stage.rf_EXMEM_B_out.readData;
    assign MemDataIn = DUT.p0.dataMemory.writeData;
    assign MemDataOut = DUT.p0.dataMemory.readData;
   // assign MemDataOut = DUT.p0.EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData;

     assign MemAddress = DUT.p0.EX_MEM_Stage.rf_EXMEM_aluOutput_out.readData; 

    //TODO: So confused on this
    //assign Halt = DUT.p0.instructionFetch.dump; 
    assign Halt = DUT.p0.dataMemory.dump; 


    
      assign ICacheHit = DUT.p0.instructionFetch.instructionMemory.CacheHit; 
     //assign ICacheHit = 0; // Signal indicating a valid instruction cache hit
     assign ICacheReq = 0; // Signal indicating a valid instruction read request to cache
     assign DCacheHit = DUT.p0.dataMemory.dataMemoryModule.CacheHit;
     assign DCacheReq = 0; // Signal indicating a valid instruction data read or write request to cache
     // assign DCacheHit = 0;
    
   /* Add anything else you want here */

endmodule

// DUMMY LINE FOR REV CONTROL :0:
