`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:53:53 AM
// Module Name: ex_v
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module ex_v( 
        input  [3:0]  alu_op,
        input         isForw_ON,
        input  [6:0]  op,
        input  [31:0] exmem_result, memwb_result,
        input  [1:0]  forwA, forwB,
        input  [31:0] data1, data2, s_data,
        output [31:0] result, sData,
        output        Z,
        output        N,
        output        C,
        output        V
    );
    
    wire [31:0] f_data1, f_data2;
    
    forw_unit_v forward(
        .isForw_ON(isForw_ON),
        .op(op),
        .exmem_result(exmem_result), .memwb_result(memwb_result),
        .forwA(forwA), .forwB(forwB),
        .data1(data1), .data2(data2), .s_data(s_data),
        .operand1(f_data1), .operand2(f_data2), .sData(sData)
    );
    
    v_alu alu(
        .A(f_data1),
        .B(f_data2),
        .alu_op(alu_op),
        .result(result),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );
    
endmodule
