`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 10:30:39 AM
// Module Name: tb_main
//////////////////////////////////////////////////////////////////////////////////
`include "struct_pkg.sv"

module tb_main_sv();

    import struct_pkg::*;
    
    // Simulation constants
    parameter TOTAL_INSTRUCTIONS = 1024;
    parameter PIPELINE_DEPTH     = 5;
    parameter CYCLE_TIME_NS      = 10;
    parameter TOTAL_CYCLES       = TOTAL_INSTRUCTIONS + PIPELINE_DEPTH;
    parameter SIM_TIME_NS        = TOTAL_CYCLES * CYCLE_TIME_NS;

    logic clk;
    logic reset;
    logic isForw_ON;
    if_t  if_stage;
    id_t  id_stage;
    ex_t  ex_stage;
    mem_t mem_stage;
    wb_t  wb_stage;
    
    main_sv uut(
        .clk(clk),                .reset(reset),
        .isForw_ON(isForw_ON),
        .if_stage_out(if_stage),  .id_stage_out(id_stage),
        .ex_stage_out(ex_stage),  .mem_stage_out(mem_stage),
        .wb_stage_out(wb_stage)
    );
    
    initial begin
        isForw_ON  = 1'b1;
        if_stage   = '{default:0};
        id_stage   = '{default:0};
        ex_stage   = '{default:0};
        mem_stage  = '{default:0};
        wb_stage   = '{default:0};
    end
    
    initial clk = 0;
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
