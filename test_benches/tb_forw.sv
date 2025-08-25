`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/25/2025 05:09:02 AM
// Design Name: 
// Module Name: tb_forw
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"
`include "functions_pkg.sv"
`include "struct_pkg.sv"

module tb_forw();
    import functions_pkg::*;
    import struct_pkg::*;
    
    logic clk = 0;
    always #5 clk = ~clk;
    
    forw_in  act_in, exp_in;
    forw_out act_out, exp_out;
    
    // Instantiate DUT
    forw_unit dut (
        .isForw_ON(act_in.isForw_ON), .op(act_in.op),
        .exmem_result(act_in.exmem),  .memwb_result(act_in.memwb),
        .forwA(act_in.forwA),         .forwB(act_in.forwB),
        .data1(act_in.data1),         .data2(act_in.data1),        .s_data(act_in.s_data),
       .operand1(act_out.operand1),   .operand2(act_out.operand2), .sData(act_out.sData)
    );
    
    int total_tests = 100;
    // Keep track all the test and make sure it covers all the cases
    int pass     = 0, fail = 0;
    int pass_fA0 = 0, pass_fA1 = 0, pass_fA2 = 0;
    int pass_fB0 = 0, pass_fB1 = 0, pass_fB2 = 0;
    
    // Help narrow down the bugs
    int fail_inA = 0, fail_inB = 0, fail_inOP = 0;
    int fail_add = 0, fail_sub = 0, fail_xor = 0, fail_or = 0, fail_and = 0;
    int fail_sll = 0, fail_srl = 0, fail_sra = 0, fail_slt = 0, fail_sltu = 0;
    int fail_result = 0, fail_z = 0, fail_v = 0, fail_n = 0, fail_c = 0;
endmodule
