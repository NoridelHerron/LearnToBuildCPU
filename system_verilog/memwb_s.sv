`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:12:58 AM
// Module Name: memwb_s
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module memwb_s(
        input  logic        clk, reset,     
        input  logic        mem_isValid,     
        input  logic [31:0] mem_pc, mem_instr,
        input  logic [4:0]  mem_rd,  
        input  logic        mem_mem_read,   
        input  logic        mem_mem_write, 
        input  logic        mem_reg_write, 
        input  logic [31:0] mem_aluResult, mem_memResult,
        output logic        wb_isValid,     
        output logic [31:0] wb_pc, wb_instr,
        output logic [4:0]  wb_rd,  
        output logic        wb_mem_read,   
        output logic        wb_mem_write, 
        output logic        wb_reg_write, 
        output logic [31:0] wb_aluResult, wb_memResult
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            wb_isValid    <= 1'd0;
            wb_pc         <= 32'd0;  
            wb_instr      <= 32'd0; 
            wb_rd         <= 5'd0;
            wb_mem_read   <= 1'd0;  
            wb_mem_write  <= 1'd0; 
            wb_reg_write  <= 1'd0;
            wb_aluResult  <= 32'd0;
            wb_memResult  <= 32'd0;
    
        // Normal flow
        end else if (mem_isValid) begin
            wb_isValid    <= mem_isValid;
            wb_pc         <= mem_pc;  
            wb_instr      <= mem_instr; 
            wb_rd         <= mem_rd;
            wb_mem_read   <= mem_mem_read;  
            wb_mem_write  <= mem_mem_write; 
            wb_reg_write  <= mem_reg_write; 
            wb_aluResult  <= mem_aluResult;
            wb_memResult  <= mem_memResult;
        end
    end
    
    
endmodule
