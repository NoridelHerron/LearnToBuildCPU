`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 07:47:43 AM
// Module Name: ifid
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module ifid_v(
        input  wire        clk, reset, is_flush, is_stall,
        input  wire        is_valid_in,     
        input  wire [31:0] pc_in,
        input  wire [31:0] instr_in,
        output reg         is_valid_out,     
        output reg  [31:0] pc_out,
        output reg  [31:0] instr_out
    );
    
    always @(posedge clk) begin
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
