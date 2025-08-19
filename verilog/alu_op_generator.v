`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 01:00:26 PM
// Design Name: 
// Module Name: alu_op_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "constant_pkg.vh"

module alu_op_generator(
        input  [6:0] op, // opcode
        input  [2:0] f3,
        input  [6:0] f7,
        output reg [3:0] alu_op
    );
    
   always @(*) begin
        case (alu_op)
            `R_TYPE : begin
                case (f3)
                    `F3_ADD_SUB :begin
                        case (f7)
                            `F7_ADD  : alu_op = `ALU_ADD;
                            `F7_SUB  : alu_op = `ALU_SUB;
                            default : alu_op = `ALU_ADD; // force to 0
                        endcase
                    end
                    
                    `F3_SRL_SRA :begin
                        case (f7)
                            `F7_SRL  : alu_op = `ALU_SRL;
                            `F7_SRA  : alu_op = `ALU_SRL;
                            default : alu_op = `ALU_ADD; // force to 0
                        endcase
                    end
                    
                    `F3_SLT  : alu_op = `ALU_SLT;
                    `F3_SLTU : alu_op = `ALU_SLTU;
                    `F3_XOR  : alu_op = `ALU_XOR;
                    `F3_OR   : alu_op = `ALU_OR;
                    `F3_AND  : alu_op = `ALU_AND;
                    `F3_SLL  : alu_op = `ALU_SLL;
                    default : alu_op = `ALU_ADD; // force to 0
                endcase
            end
            
            `I_IMM :begin
                case (f3)
                    `F3_SRLi_SRAi :begin
                        case (f7)
                            `F7_SRLi  : alu_op = `ALU_SRL;
                            `F7_SRAi  : alu_op = `ALU_SRL;
                            default  : alu_op = `ALU_ADD; // force to 0
                        endcase
                    end
                    
                    `F3_ADDi  : alu_op = `ALU_ADD;
                    `F3_SLTi  : alu_op = `ALU_SLT;
                    `F3_SLTiU : alu_op = `ALU_SLTU;
                    `F3_XORi  : alu_op = `ALU_XOR;
                    `F3_ORi   : alu_op = `ALU_OR;
                    `F3_ANDi  : alu_op = `ALU_AND;
                    `F3_SLLi  : alu_op = `ALU_SLL;
                    default  : alu_op  = `ALU_ADD; // force to 0
                endcase
            end
            
            `I_LOAD  : alu_op = `ALU_ADD;
            `S_TYPE  : alu_op = `ALU_ADD;
            ``B_TYPE : alu_op = `ALU_SUB;
            `I_JALR  : alu_op = `ALU_ADD;
            `U_LUI   : alu_op = `ALU_SLL;
            `U_AUIPC : alu_op = `ALU_SLL;
            default  : alu_op = `ALU_ADD; // force to 0
        endcase
    end

endmodule
