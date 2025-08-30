`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: data_s
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.svh"

module data_s(
        input  logic [6:0]   op,
        input  logic [11:0]  imm12,
        input  logic [31:0]  reg1_data, reg2_data,
        output logic [31:0]  operand1,  operand2,  s_data
    );
    
    always_comb begin
        case (op)
            `R_TYPE, `B_TYPE : begin
                operand1 = reg1_data;
                operand2 = reg2_data;
                s_data   = 32'd0;
            end
            
            `I_IMM : begin
                operand1 = reg1_data;
                operand2 = {{20{imm12[11]}}, imm12};
                s_data   = 32'd0;
            end
            
            `I_LOAD : begin
                operand1 = reg1_data;
                operand2 = {{20{imm12[11]}}, imm12};
                s_data   = 32'd0;
            end
            
            `S_TYPE : begin
                operand1 = reg1_data;
                operand2 = {{20{imm12[11]}}, imm12};
                s_data   = reg2_data;
            end
            
            /* Will take care of this once everything is stable
            
            
            `J_JAL : begin
            end
            
            `I_JALR : begin
            end
            
            `U_LUI : begin
            end
            
            `U_AUIPC : begin
            end
            */
            default  : begin
                operand1 = 32'd0;
                operand2 = 32'd0;
                s_data   = 32'd0;
            end
        endcase
    end
endmodule
