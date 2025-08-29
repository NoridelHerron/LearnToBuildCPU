`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 10:30:39 AM
// Module Name: tb_main
//////////////////////////////////////////////////////////////////////////////////
`include "struct_pkg.sv"

module tb_main();

    import struct_pkg::*;
    
    // Simulation constants
    parameter TOTAL_INSTRUCTIONS = 1024;
    parameter PIPELINE_DEPTH     = 5;
    parameter CYCLE_TIME_NS      = 10;
    parameter TOTAL_CYCLES       = TOTAL_INSTRUCTIONS + PIPELINE_DEPTH;
    parameter SIM_TIME_NS        = TOTAL_CYCLES * CYCLE_TIME_NS;

    logic clk;
    logic reset;
    
    if_t  if_stage;
    id_t  id_stage;
    ex_t  ex_stage;
    mem_t mem_stage;
    wb_t  wb_stage;
    
    main_v #(.isForw_ON(0)) uut(
        .clk(clk), .reset(reset),
        .if_isValid_out(if_stage.isValid),
        .if_pc_out(if_stage.pc),               .if_instr_out(if_stage.instr),
        
        .id_isValid_out(id_stage.isValid),
        .id_pc_out(id_stage.pc),               .id_instr_out(id_stage.instr),
        .id_op_out(id_stage.op),               .id_rd_out(id_stage.rs1),      
        .id_rs2_out(id_stage.rs2),             .id_memRead_out(id_stage.memWrite),
        .id_regWrite_out(id_stage.regWrite),   .id_jump_out(id_stage.jump),    
        .id_branch_out(id_stage.branch),       .id_aluOp_out(id_stage.aluOp),
        .id_forwA_out(id_stage.forwA),         .id_forwB_out(id_stage.forwB),
        .id_stall_out(id_stage.stall),         .id_operand1_out(id_stage.operand1),
        .id_operand2_out(id_stage.operand2),   .id_sData_out(id_stage.sData),
        
        .ex_isValid_out(ex_stage.isValid),
        .ex_pc_out(ex_stage.pc),               .ex_instr_out(ex_stage.instr),
        .ex_op_out(ex_stage.op),               .ex_rd_out(ex_stage.rd),               
        .ex_rs1_out(ex_stage.rs1),             .ex_rs2_out(ex_stage.rs2),
        .ex_memRead_out(ex_stage.memRead),     .ex_memWrite_out(ex_stage.memWrite), 
        .ex_regWrite_out(ex_stage.regWrite),   .ex_jump_out(ex_stage.jump),     
        .ex_branch_out(ex_stage.branch),       .ex_aluOp_out(ex_stage.aluOp),
        .ex_operand1_out(ex_stage.operand1),   .ex_operand2_out(ex_stage.operand2), 
        .ex_sData_out(ex_stage.sData),
        
        .mem_isValid_out(mem_stage.isValid),
        .mem_pc_out(mem_stage.pc),               .mem_instr_out(mem_stage.instr),
        .mem_rd_out(mem_stage.rd),               .mem_regWrite_out(mem_stage.regWrite),
        .mem_memRead_out(mem_stage.memRead),     .mem_memWrite_out(mem_stage.memWrite),  
        .mem_aluRes_out(mem_stage.alu),          .mem_sData_out(mem_stage.store),
        
        .wb_isValid_out(wb_stage.isValid),
        .wb_pc_out(wb_stage.pc),                 .wb_instr_out(wb_stage.instr),
        .wb_rd_out(wb_stage.rd),
        .wb_regWrite_out(wb_stage.regWrite),
        .wb_memRead_out(wb_stage.memRead),       .wb_memWrite_out(wb_stage.memWrite),  
        .wb_alu_out(wb_stage.alu),               .wb_mem_out(wb_stage.mem),
        .wb_data_out(wb_stage.data) 
    );
    
    initial clk = 0;
    always #(CYCLE_TIME_NS / 2) clk = ~clk; // 10ns clock
    
    initial begin
        reset = 1;
        #20 reset = 0; // Deassert reset after 20ns
    end
    
    initial begin
        if_stage   = '{default:0};
        id_stage   = '{default:0};
        ex_stage   = '{default:0};
        mem_stage  = '{default:0};
        wb_stage   = '{default:0};
    end
    
    // Automatically finish after enough cycles
    initial begin
        #(SIM_TIME_NS) $finish;
    end
    
    
endmodule
