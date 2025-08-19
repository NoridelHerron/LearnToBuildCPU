`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/19/2025 
// Module Name: tb_control_unit
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module tb_control_unit();
    logic clk = 0;
    
    typedef struct packed {
        logic  mem_read; // opcode
        logic  mem_write;
        logic  reg_write; 
        logic  jump; 
        logic  branch;
    } cntrl_out;
    
    always #5 clk = ~clk;
    
    logic [6:0] act_in, exp_in;
    cntrl_out   act_out, exp_out;
    
    // Instantiate DUT
    control_unit_s dut (
        .op(act_in),                 
        .mem_read(act_out.mem_read),          
        .mem_write(act_out.mem_write),         
        .reg_write(act_out.reg_write),            
        .jump(act_out.jump),
        .branch(act_out.branch)
    );

    int total_tests = 1000000;
    // Keep track all the test and make sure it covers all the cases
    int pass = 0, fail = 0; 
    int pass_in = 0, pass_r = 0, pass_s = 0, pass_b = 0, pass_j = 0, pass_imm = 0, pass_lw = 0, pass_ul = 0, pass_ua = 0, pass_d = 0;
    int fail_in = 0, fail_mr = 0, fail_mw = 0, fail_rw = 0, fail_j = 0, fail_b = 0;
    
    class cntrl_test;
        rand bit [6:0] r_op;
        
        constraint unique_op {
            r_op dist {
                `R_TYPE  := 20, 
                `S_TYPE  := 10,
                `B_TYPE  := 10, 
                `J_JAL   := 10, 
                `I_IMM   := 20, 
                `I_LOAD  := 10,
                `U_LUI   := 10,
                `U_AUIPC := 10
                //[7'b0000000:7'b1111111] := 10  // catch-all random opcodes
            };
        }
        
        function void apply_input();
            act_in = r_op; 
            exp_in = r_op;
        endfunction
        
        function void expected_output();
            case (exp_in)
                `R_TYPE  : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                
                `S_TYPE  : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b1;
                    exp_out.reg_write = 1'b0;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                
                `B_TYPE  : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b0;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b1;
                end
                
                `J_JAL   : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b1;
                    exp_out.branch    = 1'b0;
                end
                
                `I_IMM   : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                 
                `I_LOAD  : begin 
                    exp_out.mem_read  = 1'b1;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                
                `U_LUI   : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                
                `U_AUIPC : begin 
                    exp_out.mem_read  = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
                
                default  : begin 
                    exp_out.mem_read = 1'b0;
                    exp_out.mem_write = 1'b0;
                    exp_out.reg_write = 1'b1;
                    exp_out.jump      = 1'b0;
                    exp_out.branch    = 1'b0;
                end
            endcase
        endfunction
        
        task check();
            if (act_in == exp_in && act_out === exp_out) begin
                pass++;
                case (exp_in)
                    `R_TYPE  : pass_r++;
                    `S_TYPE  : pass_s++;
                    `B_TYPE  : pass_b++;
                    `J_JAL   : pass_j++;
                    `I_IMM   : pass_imm++;
                    `I_LOAD  : pass_lw++;
                    `U_LUI   : pass_ul++;
                    `U_AUIPC : pass_ua++;
                    default  : pass_d++;
                endcase
                
            end else begin
                if (act_in != exp_in) fail_in++;
                else begin
                    if (act_out.mem_read != exp_out.mem_read) fail_mr++;
                    if (act_out.mem_write != exp_out.mem_write) fail_mw++;
                    if (act_out.reg_write != exp_out.reg_write) fail_rw++;
                    if (act_out.jump != exp_out.jump) fail_j++;
                    if (act_out.branch != exp_out.branch) fail_b++;
                end
            end
        endtask
    endclass
    
    cntrl_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = 7'd0;
        exp_in  = act_in;
        exp_out = '{default:0};

        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply_input();
            txn.expected_output();
            #1;
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" R  : %d tests passed.", pass_r);
            $display(" I  : %d tests passed.", pass_imm);
            $display(" S  : %d tests passed.", pass_s);
            $display(" B  : %d tests passed.", pass_b);
            $display(" L  : %d tests passed.", pass_lw);
            $display(" J  : %d tests passed.", pass_j);
            $display(" UL : %d tests passed.", pass_ul);
            $display(" UA : %d tests passed.", pass_ua);
            $display(" DF : %d tests passed.", pass_d);
            
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_mr != 0) $display(" MEM_READ mismatch   : %d tests failed.", fail_mr);
            if (fail_mw != 0) $display(" MEM_WRITE mismatch  : %d tests failed.", fail_mw);
            if (fail_rw != 0) $display(" REG_WRITE mismatch  : %d tests failed.", fail_rw);
            if (fail_j != 0) $display(" JUMP mismatch : %d tests failed.", fail_j);
            if (fail_b != 0) $display(" BRANCH mismatch : %d tests failed.", fail_b);
        end
        $stop;
    end
endmodule
