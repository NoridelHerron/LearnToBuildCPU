`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/25/2025 04:02:42 AM
// Module Name: tb_ex
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module tb_ex();
    logic clk = 0;
    
    typedef struct packed {
        logic [3:0]  aluOp;
        logic        isForw_ON; 
        logic [6:0]  op;
        logic [31:0] exmem;
        logic [31:0] memwb; 
        logic [1:0]  forwA, forwB;
        logic [31:0] data1, data2, s_data;
    } ex_in;
    
    typedef struct packed {
        logic [31:0] result, sData2;
        logic        Z, N, C, V;
    } ex_out;
    
    always #5 clk = ~clk;
    
    ex_in  act_in, exp_in;
    ex_out act_out, exp_out;
    
    ex_v uut(
        .alu_op(act_in.aluOp),       .isForw_ON(act_in.isForw_ON),
        .op(act_in.op),              .exmem_result(act_in.exmem), 
        .memwb_result(act_in.memwb), .forwA(act_in.forwA),        
        .forwB(act_in.forwB),        .data1(act_in.data1),        
        .data2(act_in.data2),        .s_data(act_in.s_data),
        .result(act_out.result),     .sData(act_out.sData),
        .Z(act_out.Z),               .N(act_out.N),
        .C(act_out.C),               .V(act_out.V)
    );
    
    int total_tests = 10;
    // Keep track all the test and make sure it covers all the cases
    int pass     = 0, fail = 0, pass_default = 0, fail_default = 0;
    int pass_add = 0, pass_sub = 0, pass_xor = 0, pass_or = 0, pass_and = 0;
    int pass_sll = 0, pass_srl = 0, pass_sra = 0, pass_slt = 0, pass_sltu = 0;
    
    // Help narrow down the bugs
    int fail_inA    = 0, fail_inB = 0, fail_inOP = 0;
    int fail_add    = 0, fail_sub = 0, fail_xor  = 0, fail_or  = 0, fail_and  = 0;
    int fail_sll    = 0, fail_srl = 0, fail_sra  = 0, fail_slt = 0, fail_sltu = 0;
    int fail_result = 0, fail_z   = 0, fail_v    = 0, fail_n   = 0, fail_c    = 0;
    
    int passA_exmem = 0, passA_memwb = 0, passA_none = 0;
    int passB_exmem = 0, passB_memwb = 0, passB_none = 0;
    
    class HDU_test;
        rand bit [3:0]  r_aluOp;
        rand bit [6:0]  r_op;
        rand bit [1:0]  r_forwA, r_forwB;
        rand bit [1:0]  r_data1, r_data2, rs_data;
        
        constraint unique_op {
            r_op dist {
                `R_TYPE := 20, 
                `S_TYPE := 20,
                `B_TYPE := 20,
                `I_IMM  := 20, 
                `I_LOAD := 20
            };
        }
        
        constraint unique_ALUop {
            r_aluOp dist {
                `ALU_ADD  := 10,
                `ALU_SUB  := 10,
                `ALU_XOR  := 10,
                `ALU_OR   := 10,
                `ALU_AND  := 10,
                `ALU_SLL  := 10,
                `ALU_SRL  := 10,
                `ALU_SRA  := 10,
                `ALU_SLT  := 10,
                `ALU_SLTU := 10
                };
            }
            
            constraint we_constraint {
                r_forwA inside {2'd0, 2'd2};
                r_forwB inside {2'd0, 2'd2};
            }
        
        function void apply_actual();
            // Assign actual inputs
            act_in.aluOp  = r_aluOp;
            act_in.op     = r_op;
            act_in.forwA  = r_forwA;
            act_in.forwB  = r_forwB;
            act_in.data1  = r_data1;
            act_in.data2  = r_data2;
            act_in.s_data = rs_data;
            
            // Assign expected inputs
            act_in.aluOp  = r_aluOp;
            act_in.op     = r_op;
            act_in.forwA  = r_forwA;
            act_in.forwB  = r_forwB;
            act_in.data1  = r_data1;
            act_in.data2  = r_data2;
            act_in.s_data = rs_data;
        endfunction 
        
        
    endclass
    
endmodule
