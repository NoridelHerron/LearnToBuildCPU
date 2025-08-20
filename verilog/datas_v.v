`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/20/2025 08:05:47 AM
// Module Name: datas_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module datas_v(
        input      [6:0]   op,
        input      [11:0]  imm12,
        input      [31:0]  reg1_data, reg2_data,
        output reg [31:0]  operand1,  operand2,  s_data
    );
    
    always @(*) begin
        case (op)
            `R_TYPE : begin
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
            `B_TYPE : begin
            end
            
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
