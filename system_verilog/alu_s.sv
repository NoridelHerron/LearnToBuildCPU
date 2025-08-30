`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 08:18:51 AM
// Module Name: alu_s
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.svh"

module alu_s (
    input  logic [31:0]   A,
    input  logic [31:0]   B,
    input  logic [3:0]    alu_op,
    output logic [31:0]   result,
    output logic          Z,
    output logic          N,
    output logic          C,
    output logic          V
);
    // Precompute heavy paths once (fast carry chains on FPGA)
    logic [32:0] temp_add;
    logic [32:0] temp_sub;
    logic [31:0] sum;
    logic [31:0] diff;

    // Precompute cheap ops
    logic [31:0] w_sll;
    logic [31:0] w_srl;
    logic [31:0] w_sra;
    logic [31:0] w_and;
    logic [31:0] w_or;
    logic [31:0] w_xor;
    logic [31:0] w_slt;
    logic [31:0] w_sltu;

    // Result select (one small mux after each path)
    always_comb begin
        temp_add = {1'b0, A} + {1'b0, B};
        temp_sub = {1'b0, A} - {1'b0, B};
        sum      = temp_add[31:0];
        diff     = temp_sub[31:0];
    
        // Precompute cheap ops
        w_sll   = A <<  B[4:0];
        w_srl   = A >>  B[4:0];
        w_sra   = $signed(A) >>> B[4:0];
        w_and   = A & B;
        w_or    = A | B;
        w_xor   = A ^ B;
        w_slt   = {31'b0, ($signed(A) <  $signed(B))};
        w_sltu  = {31'b0, (A < B)};

        
        case (alu_op)
            `ALU_ADD : result = sum;
            `ALU_SUB : result = diff;
            `ALU_SLL : result = w_sll;
            `ALU_SRL : result = w_srl;
            `ALU_SRA : result = w_sra;
            `ALU_AND : result = w_and;
            `ALU_OR  : result = w_or;
            `ALU_XOR : result = w_xor;
            `ALU_SLT : result = w_slt;
            `ALU_SLTU: result = w_sltu;
            default  : result = 32'h0;
        endcase

        // Flags from the **selected** operation
        // C: unsigned carry / ~borrow; V: signed overflow
        C = (alu_op == `ALU_ADD) ? temp_add[32] :
            (alu_op == `ALU_SUB) ? ~temp_sub[32] : 1'b0;

        V = (alu_op == `ALU_ADD) ? ((A[31] == B[31]) && (sum[31]  != A[31])) :
            (alu_op == `ALU_SUB) ? ((A[31] != B[31]) && (diff[31] != A[31])) : 1'b0;

        // From selected result
        Z = (result == 32'h0);
        N = result[31];
    end
endmodule 