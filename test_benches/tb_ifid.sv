`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/24/2025 07:08:51 AM
// Module Name: tb_ifid
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module tb_ifid();
    logic clk = 0;
    logic rst = 0;

    typedef struct packed {
        logic        isFlush, isStall, isValid;   
        logic [31:0] pc, instr;
    } ifid_in;    
    
    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
    } id_out;    
    
    ifid_in act_in,  exp_in;
    id_out  act_out, exp_out;
    
    always #5 clk = ~clk;
    
    // Clean, clock-aligned reset
    initial begin
      rst = 1;                            // assert
      repeat (2) @(posedge clk);          // hold for 2 cycles
      rst = 0;                            // deassert
    end

    
    ifid_v uut(
        .clk(clk),                      .reset(rst),
        .is_flush(act_in.isFlush),      .is_stall(act_in.isStall),
        .is_valid_in(act_in.isValid),   .pc_in(act_in.pc),         .instr_in(act_in.instr),
        // Outputs
        .is_valid_out(act_out.isValid), .pc_out(act_out.pc),       .instr_out(act_out.instr)
    );
    
    int total_tests = 1000000;
    int pass    = 0, fail    = 0; 
    int fail_in = 0, fail_V  = 0, fail_pc  = 0, fail_instr  = 0, fail_f = 0, fail_s = 0;
    int fail_o  = 0, fail_Vo = 0, fail_pco = 0, fail_instro = 0;
    
    class ifid_test;
        // In normal case pc must be incremented by 4, but for testing purpose it doesn't matter.
        // As long as it is valid or not stall, what comes in comes out.
        rand bit         isValid, stall, flush;  
        rand bit  [31:0] pc, instr;  
        
        function void apply_inputs();
           // isValid = 1; stall = 0;
            // Assign Actual inputs
            act_in.isValid = isValid;  
            act_in.pc      = pc;    
            act_in.instr   = instr;
            act_in.isFlush = flush;    
            act_in.isStall = stall;    
            
            // Assign Expected inputs
            exp_in.isValid = isValid;  
            exp_in.pc      = pc; 
            exp_in.instr   = instr;
            exp_in.isFlush = flush;    
            exp_in.isStall = stall;  
        endfunction 
        
        task check();
            if (act_in === exp_in && act_out === exp_out) pass++;
            else begin
                fail++;
                if (act_in !== exp_in) begin
                    fail_in++;
                    if (act_in.isValid   !== exp_in.isValid)   fail_V++;
                    if (act_in.pc        !== exp_in.pc)        fail_pc++;
                    if (act_in.instr     !== exp_in.instr)     fail_instr++;
                    if (act_in.isFlush   !== exp_in.isFlush)   fail_f++;
                    if (act_in.isStall   !== exp_in.isStall)   fail_s++;
                    
                end else begin
                    fail_o++;
                    if (act_out.isValid   !== exp_out.isValid)   fail_Vo++;
                    if (act_out.pc        !== exp_out.pc)        fail_pco++;
                    if (act_out.instr     !== exp_out.instr)     fail_instro++;
                end
            end
        endtask
    endclass
    
    ifid_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = act_in;
        act_out = act_in;
        exp_out = act_in;

        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            txn.apply_inputs();
            @(posedge clk);
            if (rst) 
                exp_out <= '{default:0};
            else if (exp_in.isValid) begin
                exp_out.isValid <= exp_in.isValid;   
                exp_out.pc      <= exp_in.pc;       
                exp_out.instr   <= exp_in.instr;
            end
               
            #1;
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_in != 0) begin
                $display(" input mismatch : %d tests failed.", fail_in);
                if (fail_V     != 0)  $display(" isValid mismatch      : %d tests failed.", fail_V);
                if (fail_pc    != 0)  $display(" PC mismatch           : %d tests failed.", fail_pc);
                if (fail_instr != 0)  $display(" INSTRUCTION mismatch  : %d tests failed.", fail_instr);
                if (fail_f     != 0)  $display(" FLUSH mismatch        : %d tests failed.", fail_f);
                if (fail_s     != 0)  $display(" STALL mismatch        : %d tests failed.", fail_s);
                
            end else if (fail_o != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_o);
                if (fail_Vo     != 0)  $display(" isValid mismatch      : %d tests failed.", fail_Vo);
                if (fail_pco    != 0)  $display(" PC mismatch           : %d tests failed.", fail_pco);
                if (fail_instro != 0)  $display(" INSTRUCTION mismatch  : %d tests failed.", fail_instro);
            end
        end
        $finish;
    end
endmodule
