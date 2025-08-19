`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/19/2025 07:37:11 AM
// Module Name: testbench for ifid register
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module tb_ifid();

    typedef struct packed {
        logic        is_flush, is_stall; 
        logic        is_valid;
        logic [31:0] pc, instr;
    } ifid_in;
    
    typedef struct packed {
        logic        is_valid;
        logic [31:0] pc, instr;
    } ifid_out;
    
    logic   clk, reset;
    ifid_in  act_in, exp_in;
    ifid_out act_out, exp_out;
    
    // Clock generator: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Instantiate if/id register
    ifid_v uut (
        .clk(clk),
        .reset(reset),
        .is_flush(act_in.is_flush),        .is_stall(act_in.is_stall),
        .is_valid_in(act_in.is_valid),  .pc_in(act_in.pc_in), .instr_in(act_in.instr_in),
        .is_valid_in(act_out.is_valid), .pc_in(act_out.pc_in), .instr_in(act_out.instr_in)
    );
    
    always @(posedge clk) begin   
        act_in.is_flush <= 1'b0; // don't need to test it yet since there's no flush yet
        act_in.is_stall <= 1'b0; // don't need to test it yet since there's no stall yet
        act_in.instr    <= act_in.pc + 4;
        
        exp_in.is_flush <= 1'b0; // don't need to test it yet since there's no flush yet
        exp_in.is_stall <= 1'b0; // don't need to test it yet since there's no stall yet
        exp_in.instr    <= exp_in.pc + 4;
    end
    
    int total_tests = 1000000;
    int pass = 0, pass_v = 0, pass_inv = 0;
    int fail = 0, fail_v = 0, fail_i = 0, fail_p = 0;
    
    class ifid_test;
        rand bit        r_valid;
        rand bit [31:0] r_instr;
        
        function void apply_in();
            act_in.is_valid = r_valid;
            act_in.instr    = r_instr;
            
            exp_in.is_valid = r_valid;
            exp_in.instr    = r_instr;
        endfunction
        
        function void expected();
            exp_out.is_valid = exp_in.is_valid;
            exp_out.pc       = exp_in.pc;
            exp_out.instr    = exp_in.instr;
        endfunction
    endclass
    
    task check();
        if (act_in === exp_in && act_out === exp_out) begin
            pass++;
            if (exp_in.is_valid == 1'b1) pass_v++;
            if (exp_in.is_valid == 1'b0) pass_inv++;
        end else begin
            fail++;
            if (exp_out.is_valid == 1'b1) fail_v++;
            if (exp_out.pc == 1'b0) pass_inv++;
        end
    endtask
    

endmodule
