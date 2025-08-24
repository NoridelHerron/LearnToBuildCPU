`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/24/2025 07:08:51 AM
// Module Name: tb_exmem
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module tb_exmem();
    logic clk = 0;
    logic rst = 0;

    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
        logic [6:0]  op;
        logic [4:0]  rd;
        logic        mem_read;    
        logic        mem_write;   
        logic        reg_write;
        logic [31:0] result,  s_data;
    } exmem; 
    
    exmem  act_in,  exp_in;
    exmem  act_out, exp_out;
    
    always #5 clk = ~clk;
    
    // Clean, clock-aligned reset
    initial begin
      rst = 1;                            // assert
      repeat (2) @(posedge clk);          // hold for 2 cycles
      rst = 0;                            // deassert
    end

    
    exmem_s uut(
        .clk(clk),                         .reset(rst),
        .ex_isValid(act_in.isValid),       .ex_pc(act_in.pc),               .ex_instr(act_in.instr),
        .ex_rd(act_in.rd),                 .ex_mem_read(act_in.mem_read),   .ex_mem_write(act_in.mem_write), 
        .ex_reg_write(act_in.reg_write),   .ex_result(act_in.result),       .ex_sData(act_in.s_data),
        // Outputs
        .mem_isValid(act_out.isValid),     .mem_pc(act_out.pc),             .mem_instr(act_out.instr),
        .mem_rd(act_out.rd),               .mem_mem_read(act_out.mem_read), .mem_mem_write(act_out.mem_write), 
        .mem_reg_write(act_out.reg_write), .mem_result(act_out.result),     .mem_sData(act_out.s_data)
    );
    
    int total_tests = 1000000;
    int pass        = 0, fail        = 0; 
    int fail_in     = 0, fail_V      = 0, fail_pc     = 0, fail_instr  = 0, fail_rd  = 0;
    int fail_mR     = 0, fail_mW     = 0, fail_rW     = 0, fail_r   = 0,    fail_s   = 0;
    int fail_o      = 0, fail_Vo     = 0, fail_pco    = 0, fail_instro = 0, fail_rdo = 0;
    int fail_mRo    = 0, fail_mWo    = 0, fail_rWo    = 0, fail_ro = 0,     fail_so  = 0;
    
    class exmem_test;
        // In normal case pc must be incremented by 4, but for testing purpose it doesn't matter.
        // As long as it is valid or not stall, what comes in comes out.
        rand bit         isValid, stall;  
        rand bit  [31:0] pc, instr;  
        rand bit  [4:0]  rd;
        rand bit         mR, mW, rW;
        rand bit  [31:0] result, s_data;
        
        function void apply_inputs();
           // isValid = 1; stall = 0;
            // Assign Actual inputs
            act_in.isValid   = isValid;  
            act_in.pc        = pc;       
            act_in.instr     = instr;
            act_in.rd        = rd;       
            act_in.mem_read  = mR;       
            act_in.mem_write = mW;   
            act_in.reg_write = rW;       
            act_in.result    = result; 
            act_in.s_data    = s_data;
            
            // Assign Expected inputs
            exp_in.isValid   = isValid;  
            exp_in.pc        = pc;       
            exp_in.instr     = instr;
            exp_in.rd        = rd;       
            exp_in.mem_read  = mR;       
            exp_in.mem_write = mW;   
            exp_in.reg_write = rW;  
            exp_in.result    = result;
            exp_in.s_data    = s_data;
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
                    if (act_in.rd        !== exp_in.rd)        fail_rd++;
                    if (act_in.mem_read  !== exp_in.mem_read)  fail_mR++;
                    if (act_in.mem_write !== exp_in.mem_write) fail_mW++;
                    if (act_in.reg_write !== exp_in.reg_write) fail_rW++;
                    if (act_in.result    !== exp_in.result)    fail_r++;
                    if (act_in.s_data    !== exp_in.s_data)    fail_s++;
                end else begin
                    fail_o++;
                    if (act_out.isValid   !== exp_out.isValid)   fail_Vo++;
                    if (act_out.pc        !== exp_out.pc)        fail_pco++;
                    if (act_out.instr     !== exp_out.instr)     fail_instro++;
                    if (act_out.rd        !== exp_out.rd)        fail_rdo++;
                    if (act_out.mem_read  !== exp_out.mem_read)  fail_mRo++;
                    if (act_out.mem_write !== exp_out.mem_write) fail_mWo++;
                    if (act_out.reg_write !== exp_out.reg_write) fail_rWo++;
                    if (act_out.result    !== exp_out.result)    fail_ro++;
                    if (act_out.s_data    !== exp_out.s_data)    fail_so++;
                end
            end
        endtask
    endclass
    
    exmem_test txn;
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
                exp_out.isValid   <= exp_in.isValid;   
                exp_out.pc        <= exp_in.pc;       
                exp_out.instr     <= exp_in.instr;
                exp_out.rd        <= exp_in.rd; 
                exp_out.mem_read  <= exp_in.mem_read; 
                exp_out.mem_write <= exp_in.mem_write;   
                exp_out.reg_write <= exp_in.reg_write; 
                exp_out.result    <= exp_in.result;  
                exp_out.s_data    <= exp_in.s_data;
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
                if (fail_rd    != 0)  $display(" RD mismatch           : %d tests failed.", fail_rd);
                if (fail_mR    != 0)  $display(" MEM_READ mismatch     : %d tests failed.", fail_mR);
                if (fail_mW    != 0)  $display(" MEM_WRITE mismatch    : %d tests failed.", fail_mW);
                if (fail_rW    != 0)  $display(" REG_WRITE mismatch    : %d tests failed.", fail_rW);
                if (fail_r     != 0)  $display(" RESULT mismatch       : %d tests failed.", fail_r);
                if (fail_s     != 0)  $display(" STORE DATA mismatch   : %d tests failed.", fail_s);
                
            end else if (fail_o != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_o);
                if (fail_Vo     != 0)  $display(" isValid mismatch      : %d tests failed.", fail_Vo);
                if (fail_pco    != 0)  $display(" PC mismatch           : %d tests failed.", fail_pco);
                if (fail_instro != 0)  $display(" INSTRUCTION mismatch  : %d tests failed.", fail_instro);
                if (fail_rdo    != 0)  $display(" RD mismatch           : %d tests failed.", fail_rdo);
                if (fail_mRo    != 0)  $display(" MEM_READ mismatch     : %d tests failed.", fail_mRo);
                if (fail_mWo    != 0)  $display(" MEM_WRITE mismatch    : %d tests failed.", fail_mWo);
                if (fail_rWo    != 0)  $display(" REG_WRITE mismatch    : %d tests failed.", fail_rWo);
                if (fail_ro     != 0)  $display(" RESULT mismatch       : %d tests failed.", fail_ro);
                if (fail_so     != 0)  $display(" STORE DATA mismatch   : %d tests failed.", fail_so);
            end
        end
        $finish;
    end
endmodule
