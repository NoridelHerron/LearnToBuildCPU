`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 08:40:00 AM
// Module Name: id_stage_s
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module id_s(
    input  logic        clk,
    input  logic [31:0] instruction,                  // input from the if/id register
    input  logic [4:0]  idex_rs1, idex_rs2, idex_rd,  // inputs from the id/ex register
    input  logic        idex_memRead, 
    input  logic        exmem_regWrite,               // inputs from the ex/mem register
    input  logic [4:0]  exmem_rd,
    input  logic        memwb_regWrite,               // inputs from the mem/wb register
    input  logic [4:0]  memwb_rd,                  
    input  logic [31:0] wb_data,
    // outputs from decoder
    output logic [6:0]  op, 
    output logic [4:0]  rd, rs1, rs2,  
    // outputs from control unit
    output logic        mem_read,     // read data from the memory
    output logic        mem_write,    // write data to the memory
    output logic        reg_write,    // register write
    output logic        jump,         // jal/jalr
    output logic        branch,       // for branching
    // outputs from alu op generator
    output logic [3:0]  alu_op,       // register write
    // outputs from HDU
    output logic [1:0]  forwA,        // register write
    output logic [1:0]  forwB,        // jal/jalr
    output logic        stall,         // for branching
    // outputs from the data_v 
    output logic [31:0] operand1,  operand2,  s_data
    );
    
    // decoder's signals/wires
    logic [6:0]  d_op, d_f7;
    logic [4:0]  d_rd, d_rs1, d_rs2;
    logic [2:0]  d_f3;
    logic [11:0] d_imm12;
    logic [19:0] d_imm20;
    
    // register source value signals/wires
    logic [31:0] r_regData1, r_regData2;
    
    decoder_s decode(
        .ID(instruction),
        // outputs
        .op(d_op),
        .rd(d_rd),
        .funct3(d_f3),
        .rs1(d_rs1),
        .rs2(d_rs2),
        .funct7(d_f7),
        .imm12(d_imm12),
        .imm20(d_imm20)
    );
    
    // Decoder outputs
    always_comb begin
        op  = d_op;
        rd  = d_rd;
        rs1 = d_rs1;
        rs2 = d_rs2;
    end
    
    control_unit_s control_generator(
        .op(d_op), 
        // outputs
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .jump(jump),
        .branch(branch)
    );
    
    aluOp_gen_s aluOp_generator(
        .op(d_op),       
        .f3(d_f3),
        .f7(d_f7), 
        .imm(d_imm12[11:5]),
        .alu_op(alu_op) // output
    );
    
    hdu_s hazard_detection( 
        .id_rs1(d_rs1),                  .id_rs2(d_rs2),
        .idex_rs1(idex_rs1),             .idex_rs2(idex_rs2),   
        .idex_rd(idex_rd), 
        .exmem_rd(exmem_rd),             .memwb_rd(memwb_rd), 
        .idex_memRead(idex_memRead),     .exmem_regWrite(exmem_regWrite), 
        .memwb_regWrite(memwb_regWrite),
        // outputs
        .forwA(forwA), .forwB(forwB), .stall(stall) 
    );
    
    regFile_s register(
        .clk(clk), 
        .isWrite(memwb_regWrite),
        .rs1(d_rs1),              .rs2(d_rs2), 
        .rd(memwb_rd),            .writeData(wb_data), 
        // outputs
        .readData1(r_regData1),   .readData2(r_regData2) 
    );
    
    data_s operands(
        .op(d_op), 
        .imm12(d_imm12),
        .reg1_data(r_regData1), .reg2_data(r_regData2),
        // outputs
        .operand1(operand1),    .operand2(operand2),    .s_data(s_data)
    );
    
endmodule
