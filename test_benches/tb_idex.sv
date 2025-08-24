`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/24/2025 07:08:51 AM
// Module Name: tb_idex
//////////////////////////////////////////////////////////////////////////////////


module tb_idex();
    logic clk = 0;
    logic rst = 0;

    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
        logic [6:0]  op;
        logic [4:0]  rd, rs1, rs2;
        logic        mem_read;    
        logic        mem_write;   
        logic        reg_write;   
        logic        jump;       
        logic        branch;      
        logic [3:0]  alu_op;
        logic        stall;      
        logic [31:0] operand1,  operand2,  s_data;
    } id_in;    
    
    typedef struct packed {
        logic        isValid;   
        logic [31:0] pc, instr;
        logic [6:0]  op;
        logic [4:0]  rd, rs1, rs2;
        logic        mem_read;    
        logic        mem_write;   
        logic        reg_write;   
        logic        jump;       
        logic        branch;      
        logic [3:0]  alu_op;    
        logic [31:0] operand1,  operand2,  s_data;
    } ex_out;    
    
    id_in  act_in,  exp_in;
    ex_out act_out, exp_out;
    
    always #5 clk = ~clk;
    
    // Clean, clock-aligned reset
    initial begin
      rst = 1;                            // assert
      repeat (2) @(posedge clk);          // hold for 2 cycles
      rst = 0;                            // deassert
    end

    
    idex_s uut(
        .clk(clk),                       .reset(rst),
        .id_isValid(act_in.isValid),     .id_pc(act_in.pc),               .id_instr(act_in.instr),
        .id_op(act_in.op),               .id_rd(act_in.rd),               .id_rs1(act_in.rs1),       
        .id_rs2(act_in.rs2),             .id_mem_read(act_in.mem_read), 
        .id_mem_write(act_in.mem_write), .id_reg_write(act_in.reg_write), .id_jump(act_in.jump),       
        .id_branch(act_in.branch),       .id_alu_op(act_in.alu_op),       .id_stall(act_in.stall),    
        .id_operand1(act_in.operand1),   .id_operand2(act_in.operand2),   .id_s_data(act_in.s_data),
        // Outputs
        .ex_isValid(act_out.isValid),     .ex_pc(act_out.pc),               .ex_instr(act_out.instr),
        .ex_op(act_out.op),               .ex_rd(act_out.rd),               .ex_rs1(act_out.rs1),       
        .ex_rs2(act_out.rs2),             .ex_mem_read(act_out.mem_read), 
        .ex_mem_write(act_out.mem_write), .ex_reg_write(act_out.reg_write), .ex_jump(act_out.jump),       
        .ex_branch(act_out.branch),       .ex_alu_op(act_out.alu_op),          
        .ex_operand1(act_out.operand1),   .ex_operand2(act_out.operand2),   .ex_s_data(act_out.s_data)
    );
    
    int total_tests = 1000000;
    int pass        = 0, fail        = 0; 
    int fail_in     = 0, fail_V      = 0, fail_pc     = 0, fail_instr  = 0, fail_op  = 0, fail_rd  = 0, fail_rs1  = 0;
    int fail_rs2    = 0, fail_mR     = 0, fail_mW     = 0, fail_rW     = 0, fail_j   = 0, fail_b   = 0, fail_a    = 0;
    int fail_stall  = 0, fail_oper1  = 0, fail_oper2  = 0, fail_sD     = 0;
    int fail_o      = 0, fail_Vo     = 0, fail_pco    = 0, fail_instro = 0, fail_opo = 0, fail_rdo = 0, fail_rs1o = 0;
    int fail_rs2o   = 0, fail_mRo    = 0, fail_mWo    = 0, fail_rWo    = 0, fail_jo = 0, fail_bo = 0, fail_ao  = 0;
    int fail_stallo = 0, fail_oper1o = 0, fail_oper2o  = 0, fail_sDo   = 0;
    
    class idex_test;
        // In normal case pc must be incremented by 4, but for testing purpose it doesn't matter.
        // As long as it is valid or not stall, what comes in comes out.
        rand bit         isValid, stall;  
        rand bit  [31:0] pc, instr;     
        rand bit  [6:0]  op;
        rand bit  [4:0]  rd, rs1, rs2;
        rand bit         mR, mW, rW, j, b;      
        rand bit  [3:0]  aluOp;
        rand bit  [31:0] operand1,  operand2,  s_data;
        
        function void apply_inputs();
           // isValid = 1; stall = 0;
            // Assign Actual inputs
            act_in.isValid   = isValid;  act_in.pc       = pc;       act_in.instr     = instr;
            act_in.op        = op;       act_in.rd       = rd;       act_in.rs1       = rs1;  
            act_in.rs2       = rs2;      act_in.mem_read = mR;       act_in.mem_write = mW;   
            act_in.reg_write = rW;       act_in.jump     = j;        act_in.branch    = b;      
            act_in.alu_op    = aluOp;    act_in.stall    = stall;       
            act_in.operand1  = operand1; act_in.operand2 = operand2; act_in.s_data    = s_data;
            
            // Assign Expected inputs
            exp_in.isValid   = isValid;  exp_in.pc       = pc;       exp_in.instr     = instr;
            exp_in.op        = op;       exp_in.rd       = rd;       exp_in.rs1       = rs1;  
            exp_in.rs2       = rs2;      exp_in.mem_read = mR;       exp_in.mem_write = mW;   
            exp_in.reg_write = rW;       exp_in.jump     = j;        exp_in.branch    = b;      
            exp_in.alu_op    = aluOp;    exp_in.stall    = stall;       
            exp_in.operand1  = operand1; exp_in.operand2 = operand2; exp_in.s_data    = s_data;
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
                    if (act_in.op        !== exp_in.op)        fail_op++;
                    if (act_in.rd        !== exp_in.rd)        fail_rd++;
                    if (act_in.rs1       !== exp_in.rs1)       fail_rs1++;
                    if (act_in.rs2       !== exp_in.rs2)       fail_rs2++;
                    if (act_in.mem_read  !== exp_in.mem_read)  fail_mR++;
                    if (act_in.mem_write !== exp_in.mem_write) fail_mW++;
                    if (act_in.reg_write !== exp_in.reg_write) fail_rW++;
                    if (act_in.jump      !== exp_in.jump )     fail_j++;
                    if (act_in.branch    !== exp_in.branch)    fail_b++;
                    if (act_in.alu_op    !== exp_in.alu_op)    fail_a++;
                    if (act_in.stall     !== exp_in.stall)     fail_stall++;
                    if (act_in.operand1  !== exp_in.operand1)  fail_oper1++;
                    if (act_in.operand2  !== exp_in.operand2)  fail_oper2++;
                    if (act_in.s_data    !== exp_in.s_data)    fail_sD++;
                end else begin
                    fail_o++;
                    if (act_out.isValid   !== exp_out.isValid)   fail_Vo++;
                    if (act_out.pc        !== exp_out.pc)        fail_pco++;
                    if (act_out.instr     !== exp_out.instr)     fail_instro++;
                    if (act_out.op        !== exp_out.op)        fail_opo++;
                    if (act_out.rd        !== exp_out.rd)        fail_rdo++;
                    if (act_out.rs1       !== exp_out.rs1)       fail_rs1o++;
                    if (act_out.rs2       !== exp_out.rs2)       fail_rs2o++;
                    if (act_out.mem_read  !== exp_out.mem_read)  fail_mRo++;
                    if (act_out.mem_write !== exp_out.mem_write) fail_mWo++;
                    if (act_out.reg_write !== exp_out.reg_write) fail_rWo++;
                    if (act_out.jump      !== exp_out.jump )     fail_jo++;
                    if (act_out.branch    !== exp_out.branch)    fail_bo++;
                    if (act_out.alu_op    !== exp_out.alu_op)    fail_ao++;
                    if (act_out.operand1  !== exp_out.operand1)  fail_oper1o++;
                    if (act_out.operand2  !== exp_out.operand2)  fail_oper2o++;
                    if (act_out.s_data    !== exp_out.s_data)    fail_sDo++;
                end
            end
        endtask
    endclass
    
    idex_test txn;
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
                exp_out.isValid   <= exp_in.isValid;   exp_out.pc       <= exp_in.pc;       exp_out.instr     <= exp_in.instr;
                exp_out.op        <= exp_in.op;        exp_out.rd       <= exp_in.rd;       exp_out.rs1       <= exp_in.rs1;  
                exp_out.rs2       <= exp_in.rs2;       exp_out.mem_read <= exp_in.mem_read; exp_out.mem_write <= exp_in.mem_write;   
                exp_out.reg_write <= exp_in.reg_write; exp_out.jump     <= exp_in.jump;     exp_out.branch    <= exp_in.branch;      
                exp_out.alu_op    <= exp_in.alu_op;         
                exp_out.operand1  <= exp_in.operand1;  exp_out.operand2 <= exp_in.operand2; exp_out.s_data    <= exp_in.s_data;
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
                if (fail_op    != 0)  $display(" op mismatch           : %d tests failed.", fail_op);
                if (fail_rd    != 0)  $display(" RD mismatch           : %d tests failed.", fail_rd);
                if (fail_rs1   != 0)  $display(" RS1 mismatch          : %d tests failed.", fail_rs1);
                if (fail_rs2   != 0)  $display(" RS2 mismatch          : %d tests failed.", fail_rs2);
                if (fail_mR    != 0)  $display(" MEM_READ mismatch     : %d tests failed.", fail_mR);
                if (fail_mW    != 0)  $display(" MEM_WRITE mismatch    : %d tests failed.", fail_mW);
                if (fail_rW    != 0)  $display(" REG_WRITE mismatch    : %d tests failed.", fail_rW);
                if (fail_j     != 0)  $display(" JUMP mismatch         : %d tests failed.", fail_j);
                if (fail_b     != 0)  $display(" BRANCH mismatch       : %d tests failed.", fail_b);
                if (fail_a     != 0)  $display(" ALU OP mismatch       : %d tests failed.", fail_a);
                if (fail_stall != 0)  $display(" STALL mismatch        : %d tests failed.", fail_stall);
                if (fail_oper1 != 0)  $display(" OPERAND 1 mismatch    : %d tests failed.", fail_oper1);
                if (fail_oper2 != 0)  $display(" OPERAND 2 mismatch    : %d tests failed.", fail_oper2);
                if (fail_sD    != 0)  $display(" STORE DATA mismatch    : %d tests failed.", fail_sD);
                
            end else if (fail_o != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_o);
                if (fail_Vo     != 0)  $display(" isValid mismatch      : %d tests failed.", fail_Vo);
                if (fail_pco    != 0)  $display(" PC mismatch           : %d tests failed.", fail_pco);
                if (fail_instro != 0)  $display(" INSTRUCTION mismatch  : %d tests failed.", fail_instro);
                if (fail_opo    != 0)  $display(" op mismatch           : %d tests failed.", fail_opo);
                if (fail_rdo    != 0)  $display(" RD mismatch           : %d tests failed.", fail_rdo);
                if (fail_rs1o   != 0)  $display(" RS1 mismatch          : %d tests failed.", fail_rs1o);
                if (fail_rs2o   != 0)  $display(" RS2 mismatch          : %d tests failed.", fail_rs2o);
                if (fail_mRo    != 0)  $display(" MEM_READ mismatch     : %d tests failed.", fail_mRo);
                if (fail_mWo    != 0)  $display(" MEM_WRITE mismatch    : %d tests failed.", fail_mWo);
                if (fail_rWo    != 0)  $display(" REG_WRITE mismatch    : %d tests failed.", fail_rWo);
                if (fail_jo     != 0)  $display(" JUMP mismatch         : %d tests failed.", fail_jo);
                if (fail_bo     != 0)  $display(" BRANCH mismatch       : %d tests failed.", fail_bo);
                if (fail_ao     != 0)  $display(" ALU OP mismatch       : %d tests failed.", fail_ao);
                if (fail_oper1o != 0)  $display(" OPERAND 1 mismatch    : %d tests failed.", fail_oper1o);
                if (fail_oper2o != 0)  $display(" OPERAND 2 mismatch    : %d tests failed.", fail_oper2o);
                if (fail_sDo    != 0)  $display(" STORE DATA mismatch    : %d tests failed.", fail_sDo);
            end
        end
        $finish;
    end
endmodule
