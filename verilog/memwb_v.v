`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:12:58 AM
// Module Name: memwb_v
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module memwb_v(
        input             clk, reset,     
        input             mem_isValid,     
        input  [31:0]     mem_pc, mem_instr,
        input  [4:0]      mem_rd,  
        input             mem_mem_read,   
        input             mem_mem_write, 
        input             mem_reg_write, 
        input      [31:0] mem_aluResult, mem_memResult,
        output reg [4:0]  wb_rd,  
        output reg        wb_mem_read,   
        output reg        wb_mem_write, 
        output reg        wb_reg_write, 
        output reg [31:0] wb_aluResult, wb_memResult
    );
    
    always @(posedge clk) begin
        if (reset) begin
            wb_rd         <= 5'd0;
            wb_mem_read   <= 1'd0;  
            wb_mem_write  <= 1'd0; 
            wb_reg_write  <= 1'd0;
            wb_aluResult  <= 32'd0;
            wb_memResult  <= 32'd0;
    
        // Normal flow
        end else if (mem_isValid) begin
            wb_rd         <= mem_rd;
            wb_mem_read   <= mem_mem_read;  
            wb_mem_write  <= mem_mem_write; 
            wb_reg_write  <= mem_reg_write; 
            wb_aluResult  <= mem_aluResult;
            wb_memResult  <= mem_memResult;
        end
    end
    
    
endmodule
