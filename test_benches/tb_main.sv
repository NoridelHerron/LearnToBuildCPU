`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 10:30:39 AM
// Module Name: tb_main
//////////////////////////////////////////////////////////////////////////////////


module tb_main();
    // Simulation constants
    parameter TOTAL_INSTRUCTIONS = 1024;
    parameter PIPELINE_DEPTH     = 5;
    parameter CYCLE_TIME_NS      = 10;
    parameter TOTAL_CYCLES       = TOTAL_INSTRUCTIONS + PIPELINE_DEPTH;
    parameter SIM_TIME_NS        = TOTAL_CYCLES * CYCLE_TIME_NS;

    logic clk;
    logic reset;
    
    typedef struct packed {
        logic        if_isValid;
        logic [31:0] if_pc,       if_instr;
        logic        id_isValid;
        logic [31:0] id_pc,       id_instr;
        logic [6:0]  id_op;
        logic [4:0]  id_rd,       id_rs1,      id_rs2;
        logic        id_memRead,  id_memWrite; 
        logic        id_regWrite, id_jump,     id_branch;
        logic [3:0]  id_aluOp;
        logic [1:0]  id_forwA,    id_forwB;
        logic        id_stall;    
        logic [31:0] id_operand1, id_operand2, id_sData;
        logic [4:0]  ex_rd,       ex_rs1,      ex_rs2;
        logic        ex_regWrite; 
        logic [4:0]  mem_rd;
        logic        mem_regWrite; 
        logic [4:0]  wb_rd;
        logic        wb_regWrite;
        logic [31:0] wb_data;
    } main_out;
    
    main_out act_out;
    
    main_v uut(
        .clk(clk), .reset(reset),
        .if_isValid_out(act_out.if_isValid),
        .if_pc_out(act_out.if_pc),               .if_instr_out(act_out.if_instr),
        .id_isValid_out(act_out.id_isValid),
        .id_pc_out(act_out.id_pc),               .id_instr_out(act_out.id_instr),
        .id_op_out(act_out.id_op),
        .id_rd_out(act_out.id_rd),               .id_rs1_out(act_out.id_rs1),      
        .id_rs2_out(act_out.id_rs2),
        .id_memRead_out(act_out.id_memRead),     .id_memWrite_out(act_out.id_memWrite), 
        .id_regWrite_out(act_out.id_regWrite),   .id_jump_out(act_out.id_jump),     
        .id_branch_out(act_out.id_branch),
        .id_aluOp_out(act_out.id_aluOp),
        .id_forwA_out(act_out.id_forwA),         .id_forwB_out(act_out.id_forwB),
        .id_stall_out(act_out.id_stall),    
        .id_operand1_out(act_out.id_operand1),   .id_operand2_out(act_out.id_operand2), 
        .id_sData_out(act_out.id_sData),
        .ex_rd_out(act_out.ex_rd),               .ex_rs1_out(act_out.ex_rs1),      
        .ex_rs2_out(act_out.ex_rs2),
        .ex_regWrite_out(act_out.ex_regWrite), 
        .mem_rd_out(act_out.mem_rd),
        .mem_regWrite_out(act_out.mem_regWrite), 
        .wb_rd_out(act_out.wb_rd),
        .wb_regWrite_out(act_out.wb_regWrite),
        .wb_data_out(act_out.wb_data) 
    );
    
    initial clk = 0;
    initial act_out = '{default:0};
    always #(CYCLE_TIME_NS / 2) clk = ~clk; // 10ns clock
    
    initial begin
        reset = 1;
        #20 reset = 0; // Deassert reset after 20ns
    end
    
    // Automatically finish after enough cycles
    initial begin
        #(SIM_TIME_NS) $finish;
    end
    
    
endmodule
