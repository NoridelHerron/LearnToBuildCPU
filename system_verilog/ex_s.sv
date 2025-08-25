`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:53:53 AM
// Module Name: ex_s
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module ex_s( 
        input  logic [3:0]  alu_op,
        input  logic        isForw_ON,
        input  logic [6:0]  op,
        input  logic [31:0] exmem_result, memwb_result,
        input  logic [1:0]  forwA, forwB,
        input  logic [31:0] data1, data2, s_data,
        output logic [31:0] result, sData,
        output logic        Z,
        output logic        N,
        output logic        C,
        output logic        V
    );
    
    logic [31:0] f_data1, f_data2;
    
    forw_unit_s forward(
        .isForw_ON(isForw_ON),       .op(op),
        .exmem_result(exmem_result), .memwb_result(memwb_result),
        .forwA(forwA),               .forwB(forwB),
        .data1(data1),               .data2(data2), 
        .s_data(s_data),
        .operand1(f_data1),          .operand2(f_data2), 
        .sData(sData)
    );
    
    alu_s alu(
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
