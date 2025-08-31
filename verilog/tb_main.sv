`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 10:30:39 AM
// Module Name: tb_main
// Description: Testbench for main_v that casts flat bit outputs to SystemVerilog structs
//////////////////////////////////////////////////////////////////////////////////

`include "struct_pkg.sv"
import struct_pkg::*;

module tb_main();

    // Simulation constants
    parameter TOTAL_INSTRUCTIONS = 1024;
    parameter PIPELINE_DEPTH     = 5;
    parameter CYCLE_TIME_NS      = 10;
    parameter TOTAL_CYCLES       = TOTAL_INSTRUCTIONS + PIPELINE_DEPTH;
    parameter SIM_TIME_NS        = TOTAL_CYCLES * CYCLE_TIME_NS;

    logic clk;
    logic reset;
    logic isForw_ON;

    // Structs for decoded outputs
    if_t  if_stage;
    id_t  id_stage;
    ex_t  ex_stage;
    mem_t mem_stage;
    wb_t  wb_stage;

    // Wires from DUT (flat bit-vectors from Verilog module)
    logic [64:0]   if_stage_raw;
    logic [196:0]  id_stage_raw;
    logic [259:0]  ex_stage_raw;
    logic [168:0]  mem_stage_raw;
    logic [168:0]  wb_stage_raw;

    // Instantiate the DUT (main_v is written in Verilog)
    main_v uut(
        .clk(clk),
        .reset(reset),
        .isForw_ON(isForw_ON),
        .if_stage_out(if_stage_raw),
        .id_stage_out(id_stage_raw),
        .ex_stage_out(ex_stage_raw),
        .mem_stage_out(mem_stage_raw),
        .wb_stage_out(wb_stage_raw)
    );

    // Convert flat outputs into structs for easy viewing
    always_comb begin
        isForw_ON = 1;
        if (reset) begin
            if_stage  = '{default:0};
            id_stage  = '{default:0};
            ex_stage  = '{default:0};
            mem_stage = '{default:0};
            wb_stage  = '{default:0};
        end else begin
            if_stage  = if_t'(if_stage_raw);
            id_stage  = id_t'(id_stage_raw);
            ex_stage  = ex_t'(ex_stage_raw);
            mem_stage = mem_t'(mem_stage_raw);
            wb_stage  = wb_t'(wb_stage_raw);
        end
    end

    // Clock generation
    initial clk = 0;
    always #(CYCLE_TIME_NS / 2) clk = ~clk;

    // Reset logic
    initial begin
        reset = 1;
        #20 reset = 0;
    end
    
    // Automatically end simulation
    initial begin
        #(SIM_TIME_NS) $finish;
    end

endmodule
