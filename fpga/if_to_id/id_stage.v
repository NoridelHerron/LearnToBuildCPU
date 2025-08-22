`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/20/2025 10:01:17 AM
// Module Name: id_v (id stage)
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module id_v(
    input         clk,
    input  [31:0] instruction,                  // input from the if/id register
    input  [4:0]  idex_rs1, idex_rs2, idex_rd,  // inputs from the id/ex register
    input         idex_memRead, 
    input         exmem_regWrite,               // inputs from the ex/mem register
    input  [4:0]  exmem_rd,
    input         memwb_regWrite,               // inputs from the mem/wb register
    input  [4:0]  memwb_rd,                  
    input  [31:0] wb_data,
    // outputs from decoder
    output [6:0]  op, 
    output [4:0]  rd, rs1, rs2,  
    // outputs from control unit
    output        mem_read,     // read data from the memory
    output        mem_write,    // write data to the memory
    output        reg_write,    // register write
    output        jump,         // jal/jalr
    output        branch,       // for branching
    // outputs from alu op generator
    output [3:0]  alu_op,       // register write
    // outputs from HDU
    output [1:0]  forwA,        // register write
    output [1:0]  forwB,        // jal/jalr
    output        stall,         // for branching
    // outputs from the data_v 
    output [31:0] operand1,  operand2,  s_data
    );
    
    // decoder's signals/wires
    wire [6:0]  d_op, d_f7;
    wire [4:0]  d_rd, d_rs1, d_rs2;
    wire [2:0]  d_f3;
    wire [11:0] d_imm12;
    wire [19:0] d_imm20;
    
    // register source value signals/wires
    wire [31:0] r_regData1, r_regData2;
    
    decoder_v decode(
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
    assign op  = d_op;
    assign rd  = d_rd;
    assign rs1 = d_rs1;
    assign rs2 = d_rs2;   
    
    control_unit_v control_generator(
        .op(d_op), 
        // outputs
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .jump(jump),
        .branch(branch)
    );
    
    alu_op_generator_v aluOp_generator(
        .op(d_op),       
        .f3(d_f3),
        .f7(d_f7), 
        .imm(d_imm12[11:5]),
        .alu_op(alu_op) // output
    );
    
    hdu_v hazard_detection( 
        .id_rs1(d_rs1),                  .id_rs2(d_rs2),
        .idex_rs1(idex_rs1),             .idex_rs2(idex_rs2),   
        .idex_rd(idex_rd), 
        .exmem_rd(exmem_rd),             .memwb_rd(memwb_rd), 
        .idex_memRead(idex_memRead),     .exmem_regWrite(exmem_regWrite), 
        .memwb_regWrite(memwb_regWrite),
        // outputs
        .forwA(forwA), .forwB(forwB), .stall(stall) 
    );
    
    regFile_v register(
        .clk(clk), 
        .isWrite(memwb_regWrite),
        .rs1(d_rs1),              .rs2(d_rs2), 
        .rd(memwb_rd),            .writeData(wb_data), 
        // outputs
        .readData1(r_regData1),   .readData2(r_regData2) 
    );
    
    datas_v operands(
        .op(d_op), 
        .imm12(d_imm12),
        .reg1_data(r_regData1), .reg2_data(r_regData2),
        // outputs
        .operand1(operand1),    .operand2(operand2),    .s_data(s_data)
    );
    
endmodule
