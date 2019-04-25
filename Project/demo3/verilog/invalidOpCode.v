/* 
   CS/ECE 552, Spring '19
   Project
  
   Filename        : invalidOpCode.v
   Description     : This module contains the logic for the decision on whether an 
                     instruction is valid or not.  An instruction is defined as valid
                     iff it is listed in our ISA specs.
*/
module invalidOpCode (/*AUTOARG*/
                      // Outputs
                      invalidOp,
                      err,
                      // Inputs
                      Op
                      );

   parameter           OP_SIZE = 5, ON = 1'b1, OFF = 1'b0;
   
   output reg          invalidOp, err;
   input [OP_SIZE-1:0] Op;

   /*
    List out all the opcodes. There are ways to optimize the Boolean logic for this.
    */
   always @* begin
      err = OFF;
      case(Op)  
        5'b00000 : invalidOp = OFF;  // HALT
        5'b00001 : invalidOp = OFF;  // NOP
        5'b01000 : invalidOp = OFF;  // SUBI
        5'b01001 : invalidOp = OFF;  // ADDI
        5'b01010 : invalidOp = OFF;  // ANDNI
        5'b01011 : invalidOp = OFF;  // XORI
        5'b10100 : invalidOp = OFF;  // ROLI
        5'b10101 : invalidOp = OFF;  // SLLI
        5'b10110 : invalidOp = OFF;  // RORI
        5'b10111 : invalidOp = OFF;  // SRLI
        5'b10000 : invalidOp = OFF;  // ST
        5'b10011 : invalidOp = OFF;  // STU
        5'b10001 : invalidOp = OFF;  // LD          
        5'b11001 : invalidOp = OFF;  // BTR
        5'b11011 : invalidOp = OFF;  // ADD, SUB, XOR, ANDN
        5'b11010 : invalidOp = OFF;  // ROL, SLL, ROR, SRL
        5'b11100 : invalidOp = OFF;  // SEQ
        5'b11101 : invalidOp = OFF;  // SLT
        5'b11110 : invalidOp = OFF;  // SLE      
        5'b11111 : invalidOp = OFF;  // SCO
        5'b01100 : invalidOp = OFF;  // BEQZ
        5'b01101 : invalidOp = OFF;  // BNEZ
        5'b01110 : invalidOp = OFF;  // BLTZ       
        5'b01111 : invalidOp = OFF;  // BGEZ
        5'b11000 : invalidOp = OFF;  // LBI
        5'b10010 : invalidOp = OFF;  // SLBI      
        5'b00100 : invalidOp = OFF;  // J
        5'b00101 : invalidOp = OFF;  // JR
        5'b00110 : invalidOp = OFF;  // JAL          
        5'b00111 : invalidOp = OFF;  // JALR
        5'b00010 : invalidOp = OFF;  // SIIC     
        5'b00011 : invalidOp = OFF;  // RTI
        default :     
          begin         
             invalidOp = ON; // if none of the opcodes match the address provided
             // then we have an illegal instruction
             err = ON;    
          end  
      endcase // case(Op)         
   end
   
endmodule // invalidOpCode        
