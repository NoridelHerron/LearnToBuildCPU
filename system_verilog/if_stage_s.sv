`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: IF_stage
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.svh"

module if_stage_s(
        input  logic        clk, reset, is_flush, is_stall,
        input  logic [31:0] branch_target,
        output logic        is_valid,     
        output logic [31:0] pc,
        output logic [31:0] instr
    );
    
    logic  [31:0] pc_fetch;
    logic [31:0] instr_fetched;
    
    // Instantiate ROM
    rom_s rom (
        .clk(clk),
        .addr(pc_fetch[11:2]),
        .instr(instr_fetched)
    );
  
    always_ff @(posedge clk) begin
        if (reset) begin
            pc_fetch <= 32'd0;
            pc       <= 32'd0;
            is_valid <= 1'b0;
            instr    <= 32'd0;
    
        // Normal flow
        end else if (!is_stall) begin
            // Invalidate the initial memory delay
            if (pc_fetch == 32'd0)
                is_valid <= 1'b0;
            else
                is_valid <= 1'b1;
    
            pc_fetch <= pc_fetch + 32'd4;
            pc       <= pc_fetch;
            instr    <= instr_fetched;
        end
    end
    
endmodule
