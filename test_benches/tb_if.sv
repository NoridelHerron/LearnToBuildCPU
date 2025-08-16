`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: testbench for IF_stage
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_if;

    // Clock & Reset
    logic clk;
    logic reset;
    logic is_flush;
    logic is_stall;
    logic [31:0] branch_target;
    
    // Outputs from DUT
    logic is_valid;
    logic [31:0] pc;
    logic [31:0] instr;

    // DUT instantiation
    if_stage dut (
        .clk(clk),
        .reset(reset),
        .is_flush(is_flush),
        .is_stall(is_stall),
        .branch_target(branch_target),
        .is_valid(is_valid),
        .pc(pc),
        .instr(instr)
    );

    // Clock generator: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Main stimulus
    initial begin
        $display("Starting IF Stage Testbench...");
        reset = 1;
        is_flush = 0;
        is_stall = 0;
        branch_target = 32'h00000010;
        
        #12 reset = 0;
        
        // Normal fetch
        repeat (5) @(posedge clk);
        
        // Trigger a branch flush
        is_flush = 1;
        @(posedge clk);
        is_flush = 0;
        
        // Wait for more cycles
        repeat (3) @(posedge clk);
        
        // Simulate a stall
        is_stall = 1;
        repeat (2) @(posedge clk);
        is_stall = 0;
        
        // More cycles
        repeat (3) @(posedge clk);
        
        $display("Ending IF Stage Testbench...");
        $finish;
        end
    
    // Monitor
    initial begin
        $monitor("T=%0t | PC=%h | Instr=%h | Valid=%b | Flush=%b | Stall=%b",
                  $time, pc, instr, is_valid, is_flush, is_stall);
    end
    
endmodule
