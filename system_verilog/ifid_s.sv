`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 07:47:43 AM
// Module Name: ifid
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module ifid_s(
        input  logic        clk, reset, is_flush, is_stall,
        input  logic        is_valid_in,     
        input  logic [31:0] pc_in,
        input  logic [31:0] instr_in,
        output logic        is_valid_out,     
        output logic [31:0] pc_out,
        output logic [31:0] instr_out
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pc_out       <= 32'd0;
            is_valid_out <= 1'b0;
            instr_out    <= 32'd0;
    
        // Normal flow
        end else if (is_valid_in) begin
            pc_out       <= pc_in;
            is_valid_out <= is_valid_in;
            instr_out    <= instr_in;
        end
    end
    
endmodule
