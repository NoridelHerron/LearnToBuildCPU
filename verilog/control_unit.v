`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Control Unit
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module control_unit_v(
        input  [6:0] op,       // opcode
        output reg mem_read,   // read data from the memory
        output reg mem_write,  // write data to the memory
        output reg reg_write,  // register write
        output reg jump,       // jal/jalr
        output reg branch      // for branching
    );
    
    always @(*) begin
        case (op)
            `R_TYPE : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            `I_IMM : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            `I_LOAD : begin
                mem_read  = 1'b1;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            `S_TYPE : begin
                mem_read  = 1'b0;
                mem_write = 1'b1;
                reg_write = 1'b0;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            `B_TYPE : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b0;
                jump      = 1'b0;
                branch    = 1'b1;
            end
            
            `J_JAL : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b1;
                branch    = 1'b0;
            end
            
            `I_JALR : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b1;
                branch    = 1'b0;
            end
            
            `U_LUI : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            `U_AUIPC : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b1;
                jump      = 1'b0;
                branch    = 1'b0;
            end
            
            default  : begin
                mem_read  = 1'b0;
                mem_write = 1'b0;
                reg_write = 1'b0;
                jump      = 1'b0;
                branch    = 1'b0;
            end
        endcase
    end
endmodule
