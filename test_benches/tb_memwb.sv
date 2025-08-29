`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/24/2025 07:08:51 AM
// Module Name: tb_memwb
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module tb_memwb();
    logic clk = 0;
    logic rst = 0;

    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
        logic [4:0]  rd;  
        logic        mem_read;   
        logic        mem_write; 
        logic        reg_write; 
        logic [31:0] aluResult, memResult;
    } memwb_in; 
    
    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
        logic [4:0]  rd;  
        logic        mem_read;   
        logic        mem_write; 
        logic        reg_write; 
        logic [31:0] aluResult, memResult;
    } memwb_out; 
    
    memwb_in   act_in,  exp_in;
    memwb_out  act_out, exp_out;
    
    always #5 clk = ~clk;
    
    // Clean, clock-aligned reset
    initial begin
      rst = 1;                            // assert
      repeat (2) @(posedge clk);          // hold for 2 cycles
      rst = 0;                            // deassert
    end

    
    memwb_v uut(
        .clk(clk),                        .reset(rst),
        .mem_isValid(act_in.isValid),     .mem_pc(act_in.pc),               .mem_instr(act_in.instr),
        .mem_rd(act_in.rd),               .mem_mem_read(act_in.mem_read),   .mem_mem_write(act_in.mem_write), 
        .mem_reg_write(act_in.reg_write), .mem_aluResult(act_in.aluResult), .mem_memResult(act_in.memResult),
        // Outputs
        .wb_isValid(act_out.isValid),     .wb_pc(act_out.pc),               .wb_instr(act_out.instr),
        .wb_rd(act_out.rd),               .wb_mem_read(act_out.mem_read),   .wb_mem_write(act_out.mem_write), 
        .wb_reg_write(act_out.reg_write), .wb_aluResult(act_out.aluResult), .wb_memResult(act_out.memResult)
    );
    
    int total_tests = 10000;
    int pass    = 0, fail     = 0, fail_V   = 0, fail_pc  = 0, fail_instr = 0;
    int fail_in = 0, fail_rd  = 0, fail_mR  = 0, fail_mW  = 0, fail_rW  = 0, fail_aRes  = 0, fail_mRes = 0;
    int fail_o  = 0, fail_rdo = 0, fail_mRo = 0, fail_mWo = 0, fail_rWo = 0, fail_aro = 0, fail_mro  = 0;
    
    class memwb_test;
        // In normal case pc must be incremented by 4, but for testing purpose it doesn't matter.
        // As long as it is valid or not stall, what comes in comes out.
        rand bit         isValid, stall;  
        rand bit  [31:0] pc, instr;  
        rand bit  [4:0]  rd;
        rand bit         mR, mW, rW;
        rand bit  [31:0] aluResult, memResult;
        
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
            act_in.aluResult = aluResult;
            act_in.memResult = memResult;
            
            // Assign Expected inputs
            exp_in.isValid   = isValid;  
            exp_in.pc        = pc;       
            exp_in.instr     = instr;
            exp_in.rd        = rd;       
            exp_in.mem_read  = mR;       
            exp_in.mem_write = mW;   
            exp_in.reg_write = rW;  
            exp_in.aluResult = aluResult;
            exp_in.memResult = memResult;
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
                    if (act_in.aluResult !== exp_in.aluResult) fail_aRes++;
                    if (act_in.memResult !== exp_in.memResult) fail_mRes++;
                end else begin
                    fail_o++;
                    if (act_out.rd        !== exp_out.rd)        fail_rdo++;
                    if (act_out.mem_read  !== exp_out.mem_read)  fail_mRo++;
                    if (act_out.mem_write !== exp_out.mem_write) fail_mWo++;
                    if (act_out.reg_write !== exp_out.reg_write) fail_rWo++;
                    if (act_out.aluResult !== exp_out.aluResult) fail_aro++;
                    if (act_out.memResult !== exp_out.memResult) fail_mro++;
                end
            end
        endtask
    endclass
    
    memwb_test txn;
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
                exp_out.aluResult <= exp_in.aluResult;  
                exp_out.memResult <= exp_in.memResult;
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
                if (fail_aRes  != 0)  $display(" ALU RESULT mismatch   : %d tests failed.", fail_aRes);
                if (fail_mRes  != 0)  $display(" MEM RESULT mismatch   : %d tests failed.", fail_mRes);
                
            end else if (fail_o != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_o);
                if (fail_rdo != 0) $display(" RD mismatch           : %d tests failed.", fail_rdo);
                if (fail_mRo != 0) $display(" MEM_READ mismatch     : %d tests failed.", fail_mRo);
                if (fail_mWo != 0) $display(" MEM_WRITE mismatch    : %d tests failed.", fail_mWo);
                if (fail_rWo != 0) $display(" REG_WRITE mismatch    : %d tests failed.", fail_rWo);
                if (fail_aro != 0) $display(" ALU RESULT mismatch   : %d tests failed.", fail_aro);
                if (fail_mro != 0) $display(" MEM RESULT mismatch   : %d tests failed.", fail_mro);
            end
        end
        $finish;
    end
endmodule
