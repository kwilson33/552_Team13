/* 
   CS/ECE 552, Spring '19
   Project                          
  
   Filename        : waySelect.v  
   Description     : This module is used with the two-way set associative cache.  It
                     looks at the hit, valid, and dirty signals or both ways, as well
                     as the victimway value, and outputs what value waySel should be.
                     It also outputs what the next state should be (assumes we're in
                     state Idle).
*/
module waySelect (/*AUTOARG*/      
                  // Outputs         
                  waySel,   
                  nextState,  
                  err,          
                  // Inputs
                  hitC0,      
                  hitC1,               
                  validC0,               
                  validC1,        
                  dirtyC0,
                  dirtyC1,
                  victimway
                  );

   parameter               STATE_SIZE = 4, WAY0 = 1'b0, WAY1 = 1'b1;

   output reg [STATE_SIZE-1:0] nextState;
   output                      err;
   output reg                  waySel;   

   input                       hitC0, hitC1, validC0, validC1, dirtyC0, dirtyC1, 
                               victimway;

   // tells which way to select (should only be set in Idle of FSM)
   always @* begin
      casex ({hitC0, validC0, dirtyC0, hitC1, validC1, dirtyC1, victimway})
        /*
         If both ways are invalid, then we want to replace way0
         nextState --> AccWrite0 (0101)
         doing Write, so compWrite_Read = 1
         */
        7'bx0x_x0x_x :
          begin
             nextState = 4'b0101;
             waySel = WAY0;
          end
        /*
         if way0 is invalid but way1 is valid, replace way0
         nextState --> AccWrite0 (0101)   
         doing a Write, so compWrite_Read = 1    
         */
        7'bx0x_x1x_x :
          begin
             nextState = 4'b0101;
             waySel = WAY0;
          end
        /*
         if way1 is invalid but way0 is valid, replace way1
         nextState --> AccWrite0 (0101)
         doing a Write, so compWrite_Read = 1
         */
        7'bx1x_x0x_x :
          begin
             nextState = 4'b0101;
             waySel = WAY1;
          end
        /*
         if both are valid, both miss, neither is dirty, and victimway = 0, replace
         way0; nextState --> AccWrite0 (0101)
         doing a write, so compWrite_Read = 1
         */
        7'b010_010_0 :
          begin
             nextState = 4'b0101;
             waySel = WAY0;
          end
        /*
         if both miss, both are valid, 0 is dirty and 1 is not, with victimway = 0,
         replace way0; nextState --> AccRead1 (0001)
         doing a read, so compRead_Write = 1
         */
        7'b011_010_0 :
          begin
             nextState = 4'b0001;
             waySel = WAY0;
          end
        /*
         if both miss, both are valid, 1 is dirty and 0 is not, with victimway = 0,
         replace way0; nextState --> AccWrite0 (0101)
         doing a write, so compWrite_Read = 1
         */
        7'b010_011_0 :
          begin   
             nextState = 4'b0101;    
             waySel = WAY0;   
          end
        /*
         if both miss, both are valid, both are dirty, with victimway = 0,   
         replace way0; nextState --> AccRead0 (0001)     
         doing a read, so compRead_Write = 1
         */
        7'b011_011_0 :
          begin
             nextState = 4'b0001;
             waySel = WAY0;
          end
        /*
         if both miss, both are valid, neither is dirty, with victimway = 1,
         replace way1; nextState --> AccWrite0 (0101)
         doing a write, so compWrite_Read = 1
         */
        7'b010_010_1 :
          begin
             nextState = 4'b0101;
             waySel = WAY1;
          end
        /*
         if both miss, both are valid, 0 is dirty and 1 is not, with victimway = 1,
         replace way1; nextState --> AccWrite0 (0101)
         doing a write, so compWrite_Read = 1
         */
        7'b011_010_1 :
          begin
             nextState = 4'b0101;
             waySel = WAY1;
          end
        /*
         if both miss, both are valid, 1 is dirty and 0 is not, with victimway = 1,
         replace way1; nextState --> AccRead1 (0001)
         doing a read, so compRead_Write = 1
         */
        7'b010_011_1 :
          begin
             nextState = 4'b0001;   
             waySel = WAY1;   
          end    
        /*
         if both miss, both are valid, both are dirty, with victimway = 1, replace
         way1; nextState --> AccRead1 (0001)
         doing a read, so compRead_Write = 1
         */
        7'b011_011_1 :
          begin
             nextState = 4'b0001;
             waySel = WAY1;
          end
        // stay in Idle if you get here
        // have all signals low if (somehow) we get here
        default :
          begin
             nextState = 4'b0000;    
             waySel = WAY0;      
          end
      endcase // casex({hitC0, validC0, dirtyC0, hitC1, validC1, dirtyC1, victimway})  
   end      

   // no known error states  
   assign err = 1'b0;    
   
endmodule // waySelect               
