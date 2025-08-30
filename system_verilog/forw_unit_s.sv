`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: forw_unit
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.svh"

module forw_unit_s(
        input  logic      isForw_ON,
        input  logic [6:0]  op,
        input  logic [31:0] exmem_result, memwb_result,
        input  logic [1:0]  forwA, forwB,
        input  logic [31:0] data1, data2, s_data,
        output logic [31:0] operand1, operand2, sData
    );
    
    always_comb begin
        if (isForw_ON) begin
            case (forwA)
                2'b00   : operand1 = data1;
                2'b01   : operand1 = exmem_result;
                2'b10   : operand1 = memwb_result;
                default : operand1 = 32'd0;
            endcase
            
            case (forwB)
                2'b00   : begin 
                    operand2 = data2;
                    sData    = s_data;
                end
                
                2'b01   : begin
                    case (op)
                        `R_TYPE : begin
                            operand2 = exmem_result;
                            sData    = s_data;
                        end
                        
                        `I_IMM, `I_LOAD : begin
                            operand2 = data2;
                            sData    = s_data;
                        end
                        
                        `S_TYPE : begin
                            operand2 = data2;
                            sData    = exmem_result;
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
                            operand2 = data2;
                            sData    = s_data;
                        end     
                    endcase
                end
                    
                2'b10   : begin 
                    case (op)
                        `R_TYPE : begin
                            operand2 = memwb_result;
                            sData    = s_data;
                        end
                        
                        `S_TYPE : begin
                            operand2 = data2;
                            sData    = memwb_result;
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
                            operand2 = data2;
                            sData    = s_data;
                        end     
                    endcase
                end
                
                default : begin 
                    operand2 = 32'd0;
                end
            endcase
        
        end else begin
            operand1 = data1;
            operand2 = data2;
            sData    = s_data;
        end
    end
endmodule
