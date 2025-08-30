`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 09:11:55 AM
// Module Name: main_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "struct_pkg.sv"   // bring in the source file
import struct_pkg::*;      // import all typedefs, functions, etc.

module main_sv (
    input  logic clk, reset, isForw_ON,
    output if_t  if_stage_out,
    output id_t  id_stage_out,
    output ex_t  ex_stage_out,
    output mem_t mem_stage_out,
    output wb_t  wb_stage_out
    );
    
    logic        is_flush;
    logic [31:0] br_target;
    
    if_t  if_stage;
    id_t  id_stage;
    ex_t  ex_stage;
    mem_t mem_stage;
    wb_t  wb_stage;
    
    initial begin
        if_stage   = '{default:0};
        id_stage   = '{default:0};
        ex_stage   = '{default:0};
        mem_stage  = '{default:0};
        wb_stage   = '{default:0};
    end
    
    //////////////////////////////////////////////////////////////////////////////
    ////////////                     IF STAGE                      //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    if_stage_s if_uut(
        .clk(clk),                   .reset(reset), 
        .is_flush(is_flush),         .is_stall(id_stage.stall), .branch_target(br_target),
        // outputs
        .is_valid(if_stage.isValid), .pc(if_stage.pc),          .instr(if_stage.instr)
    );
    
    //////////////////////////////////////////////////////////////////////////////
    ////////////                     ID STAGE                      //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    ifid_s ifid_uut(
        .clk(clk),                        .reset(reset), 
        .is_flush(is_flush),              .is_stall(id_stage.stall),
        .is_valid_in(if_stage.isValid),   .pc_in(if_stage.pc),       .instr_in(if_stage.instr),   
        // Outputs     
        .is_valid_out(id_stage.isValid),  .pc_out(id_stage.pc),      .instr_out(id_stage.instr)
    );
    
    id_s id_uut(
        .clk(clk),
        .instruction(id_stage.instr),         
        .idex_rs1(ex_stage.rs1),             .idex_rs2(ex_stage.rs2), 
        .idex_rd(ex_stage.rd),               .idex_memRead(ex_stage.memRead), 
        .exmem_regWrite(mem_stage.regWrite), .exmem_rd(mem_stage.rd),
        .memwb_regWrite(wb_stage.regWrite),  .memwb_rd(wb_stage.rd),                  
        .wb_data(wb_stage.data),
        // Outputs
        .op(id_stage.op), .rd(id_stage.rd),  .rs1(id_stage.rs1), .rs2(id_stage.rs2), 
        .mem_read(id_stage.memRead),         .mem_write(id_stage.memWrite),   
        .reg_write(id_stage.regWrite),       .jump(id_stage.jump),      
        .branch(id_stage.branch),            .alu_op(id_stage.aluOp),       
        .forwA(id_stage.forwA),              .forwB(id_stage.forwB),       
        .stall(id_stage.stall),              .operand1(id_stage.operand1),  
        .operand2(id_stage.operand2),        .s_data(id_stage.sData)
    );
    
    //////////////////////////////////////////////////////////////////////////////
    ////////////                     EX STAGE                      //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    idex_s idex_uut(
        .clk(clk),                         .reset(reset), 
        .id_isValid(id_stage.isValid),     .id_pc(id_stage.pc),      
        .id_instr(id_stage.instr),         .id_op(id_stage.op),              
        .id_rd(id_stage.rd),               .id_rs1(id_stage.rs1), 
        .id_rs2(id_stage.rs2),             .id_mem_read(id_stage.memRead),     
        .id_mem_write(id_stage.memWrite),  .id_reg_write(id_stage.regWrite),   
        .id_jump(id_stage.jump),           .id_branch(id_stage.branch),       
        .id_alu_op(id_stage.aluOp),        .id_stall(id_stage.stall),       
        .id_operand1(id_stage.operand1),   .id_operand2(id_stage.operand2),   
        .id_s_data(id_stage.sData),        
        // Outputs
        .ex_isValid(ex_stage.isValid),     
        .ex_pc(ex_stage.pc),               .ex_instr(ex_stage.instr),
        .ex_op(ex_stage.op),               .ex_rd(ex_stage.rd), 
        .ex_rs1(ex_stage.rs1),             .ex_rs2(ex_stage.rs2),  
        .ex_mem_read(ex_stage.memRead),    .ex_mem_write(ex_stage.memWrite), 
        .ex_reg_write(ex_stage.regWrite),  .ex_jump(ex_stage.jump),       
        .ex_branch(ex_stage.branch),       .ex_alu_op(ex_stage.aluOp),
        .ex_operand1(ex_stage.operand1),   .ex_operand2(ex_stage.operand2),  
        .ex_s_data(ex_stage.sData)
    );
    
    ex_s ex_uut( 
        .alu_op(ex_stage.aluOp),          .isForw_ON(isForw_ON),
        .op(ex_stage.op),                  .exmem_result(mem_stage.alu), 
        .memwb_result(wb_stage.data),      .forwA(id_stage.forwA), 
        .forwB(id_stage.forwB),            .data1(ex_stage.operand1), 
        .data2(ex_stage.operand2),         .s_data(ex_stage.sData),
        // Outputs
        .result(ex_stage.result),          .sData(ex_stage.store),
        .Z(ex_stage.Z), .N(ex_stage.N),    .C(ex_stage.C), .V(ex_stage.V)
    );
    
    //////////////////////////////////////////////////////////////////////////////
    ////////////                    MEM STAGE                       //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    exmem_s exmem_uut(
        .clk(clk),                           .reset(reset), 
        // Inputs directly from the ID/EX reg
        .ex_isValid(ex_stage.isValid),       .ex_pc(ex_stage.pc), 
        .ex_instr(ex_stage.instr),           .ex_rd(ex_stage.rd),  
        .ex_mem_read(ex_stage.memRead),     .ex_mem_write(ex_stage.memWrite), 
        .ex_reg_write(ex_stage.regWrite),   
        // Inputs directly from the EX STAGE
        .ex_result(ex_stage.result),         .ex_sData(ex_stage.sData),           
        // Outputs
        .mem_isValid(mem_stage.isValid),     
        .mem_pc(mem_stage.pc),               .mem_instr(mem_stage.instr),
        .mem_rd(mem_stage.rd),               .mem_mem_read(mem_stage.memRead),   
        .mem_mem_write(mem_stage.memWrite),  .mem_reg_write(mem_stage.regWrite), 
        .mem_result(mem_stage.alu),          .mem_sData(mem_stage.store)
    );
   
    mem_stage_s mem_stage_uut(
        .clk(clk),
        // // Inputs from EX/MEM reg
        .is_memRead(mem_stage.memRead),
        .is_memWrite(mem_stage.memWrite),
        .address(mem_stage.alu),
        .S_data(mem_stage.store),
        // Output
        .data_out(mem_stage.mem)  
    );
    
    //////////////////////////////////////////////////////////////////////////////
    ////////////                     WB STAGE                       //////////////
    //////////////////////////////////////////////////////////////////////////////
    
    memwb_s memwb_uut(
        // Inputs directly from the EX/MEM reg
        .clk(clk),                           .reset(reset), 
        .mem_isValid(mem_stage.isValid),     .mem_pc(mem_stage.pc), 
        .mem_instr(mem_stage.instr),         .mem_rd(mem_stage.rd),  
        .mem_mem_read(mem_stage.memRead),    .mem_mem_write(mem_stage.memWrite), 
        .mem_reg_write(mem_stage.regWrite),  .mem_aluResult(mem_stage.alu), 
        // Input from MEM STAGE
        .mem_memResult(mem_stage.mem),    
        // Outputs
        .wb_isValid(wb_stage.isValid),             .wb_pc(wb_stage.pc), 
        .wb_instr(wb_stage.instr),                 .wb_rd(wb_stage.rd),  
        .wb_mem_read(wb_stage.memRead),            .wb_mem_write(wb_stage.memWrite), 
        .wb_reg_write(wb_stage.regWrite),          .wb_aluResult(wb_stage.alu),   
        .wb_memResult(wb_stage.mem)
    );
    
    WB_s WB_uut(
        // Inputs directly from the MEM/WB reg
        .is_memRead(wb_stage.memRead), 
        .is_memWrite(wb_stage.memWrite), 
        .alu_data(wb_stage.alu), 
        .mem_data(wb_stage.mem),
        // Outputs
        .wb_data(wb_stage.data) 
    );
    
    assign if_stage_out  = if_stage;
    assign id_stage_out  = id_stage;
    assign ex_stage_out  = ex_stage;
    assign mem_stage_out = mem_stage;
    assign wb_stage_out  = wb_stage;
endmodule

