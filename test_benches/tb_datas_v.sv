`timescale 1ns / 1ps

`include "constant_def.vh"

module tb_datas_v();

    logic clk = 0;
    
    typedef struct packed {
        logic  [6:0]  op; 
        logic  [11:0] imm12;
        logic  [31:0] reg1_data, reg2_data;
    } data_in;
    
    typedef struct packed {
        logic  [31:0] operand1,  operand2,  s_data;
    } data_out;
    
    always #5 clk = ~clk;
    
    data_in  act_in, exp_in;
    data_out act_out, exp_out;
    
    data_s uut(
        .op(act_in.op),
        .imm12(act_in.imm12),
        .reg1_data(act_in.reg1_data), .reg2_data(act_in.reg2_data),
        .operand1(act_out.operand1),  .operand2(act_out.operand2),  .s_data(act_out.s_data)
    );
    
    int total_tests = 1000000;
    int pass = 0, pass_r = 0, pass_i = 0, pass_l = 0, pass_s = 0;
    int fail = 0, fail_r = 0, fail_i = 0, fail_l = 0, fail_s = 0;
    int fail_input = 0, fail_op = 0, fail_imm = 0, fail_d1 = 0, fail_d2;
    int fail_output = 0, fail_op1 = 0, fail_op2 = 0, fail_sd = 0;
    
    class operand_test;
        rand bit [6:0]  r_op;
        rand bit [11:0] r_imm;
        rand bit [31:0] r_regData1, r_regData2;
        
        constraint unique_op {
            r_op dist {
                `R_TYPE  := 25, 
                `S_TYPE  := 25,
                `I_IMM   := 25, 
                `I_LOAD  := 25
                //[7'b0000000:7'b1111111] := 10  // catch-all random opcodes
            };
        }
        
        constraint imm_div_by_4 {
            r_imm[1:0] == 2'b00;  // Force r_imm to be divisible by 4
        }
        
        function void apply_inputs();
            act_in.op        = r_op;
            act_in.imm12     = r_imm;
            act_in.reg1_data = r_regData1;
            act_in.reg2_data = r_regData2;
            
            exp_in.op        = r_op;
            exp_in.imm12     = r_imm;
            exp_in.reg1_data = r_regData1;
            exp_in.reg2_data = r_regData2;
        endfunction
        
        function void expected_output();
            case (exp_in.op)
                `R_TYPE   : begin
                    exp_out.operand1 = exp_in.reg1_data;
                    exp_out.operand2 = exp_in.reg2_data;
                    exp_out.s_data   = 32'd0;
                end
                
                `I_IMM    : begin
                    exp_out.operand1 = exp_in.reg1_data;
                    exp_out.operand2 = {{20{exp_in.imm12[11]}}, exp_in.imm12};
                    exp_out.s_data   = 32'd0;
                end
                
                `I_LOAD   : begin
                    exp_out.operand1 = exp_in.reg1_data;
                    exp_out.operand2 = {{20{exp_in.imm12[11]}}, exp_in.imm12};
                    exp_out.s_data   = 32'd0;
                end
                
                `S_TYPE   : begin
                    exp_out.operand1 = exp_in.reg1_data;
                    exp_out.operand2 = {{20{exp_in.imm12[11]}}, exp_in.imm12};
                    exp_out.s_data   = exp_in.reg2_data;
                end
                
                default   : begin
                    exp_out.operand1 = 32'd0;
                    exp_out.operand2 = 32'd0;
                    exp_out.s_data   = 32'd0;
                end
            endcase
        endfunction
        
        task check();
            #1;
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                case (act_in.op)
                    `R_TYPE : pass_r++;
                    `I_IMM  : pass_i++;
                    `I_LOAD : pass_l++;
                    `S_TYPE : pass_s++;
                endcase
            end else begin
                fail++;
                if (act_in !== exp_in) begin
                    fail_input++;
                    if (act_in.op != exp_in.op) fail_op++;
                    if (act_in.imm12 != exp_in.imm12) fail_imm++;
                    if (act_in.reg1_data != exp_in.reg1_data) fail_d1++;
                    if (act_in.reg2_data != exp_in.reg2_data) fail_d2++;
                end else begin
                    fail_output++;
                    if (act_out.operand1 != exp_out.operand1) fail_op1++;
                    if (act_out.operand2 != exp_out.operand2) fail_op2++;
                    if (act_out.s_data != exp_out.s_data) fail_s++;
                end
            end
        endtask
    endclass
    
    operand_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = act_in;
        exp_out = act_in;

        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply_inputs();
            txn.expected_output();
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" R: %d tests passed.", pass_r);
            $display(" I: %d tests passed.", pass_i);
            $display(" L: %d tests passed.", pass_l);
            $display(" S: %d tests passed.", pass_s);
            
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_input != 0) begin
                $display(" input mismatch : %d tests failed.", fail_input);
                if (fail_op != 0)  $display(" op mismatch    : %d tests failed.", fail_op);
                if (fail_imm != 0) $display(" imm mismatch   : %d tests failed.", fail_imm);
                if (fail_d1 != 0)  $display(" data1 mismatch : %d tests failed.", fail_d1);
                if (fail_d2 != 0)  $display(" data2 mismatch : %d tests failed.", fail_d2);
            end else if (fail_output != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_output);
                if (fail_op1 != 0)  $display(" operand 1 mismatch    : %d tests failed.", fail_op1);
                if (fail_op2 != 0) $display(" operand 2 mismatch   : %d tests failed.", fail_op2);
                if (fail_s != 0)  $display(" s_data mismatch : %d tests failed.", fail_s);
            end
        end
        $stop;
    end
    
endmodule
