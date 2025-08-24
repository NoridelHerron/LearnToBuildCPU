`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:12:58 AM
// Module Name: exmem_v
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module exmem_s(
        input  logic        clk, reset,
        input  logic        ex_isValid,     
        input  logic [31:0] ex_pc, ex_instr,
        input  logic [4:0]  ex_rd,  
        input  logic        ex_mem_read,   
        input  logic        ex_mem_write, 
        input  logic        ex_reg_write, 
        input  logic [31:0] ex_result, ex_sData,
        output logic        mem_isValid,     
        output logic [31:0] mem_pc, mem_instr,
        output logic [4:0]  mem_rd,  
        output logic        mem_mem_read,   
        output logic        mem_mem_write, 
        output logic        mem_reg_write, 
        output logic [31:0] mem_result, mem_sData
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            mem_isValid    <= 1'd0;
            mem_pc         <= 32'd0;  
            mem_instr      <= 32'd0; 
            mem_rd         <= 5'd0;
            mem_mem_read   <= 1'd0;  
            mem_mem_write  <= 1'd0; 
            mem_reg_write  <= 1'd0;
            mem_result     <= 32'd0;
            mem_sData      <= 32'd0;
    
        // Normal flow
        end else if (ex_isValid) begin
            mem_isValid    <= ex_isValid;
            mem_pc         <= ex_pc;  
            mem_instr      <= ex_instr; 
            mem_rd         <= ex_rd;
            mem_mem_read   <= ex_mem_read;  
            mem_mem_write  <= ex_mem_write; 
            mem_reg_write  <= ex_reg_write; 
            mem_result     <= ex_result;
            mem_sData      <= ex_sData;
        end
    end
    
    
endmodule
