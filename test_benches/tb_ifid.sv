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
        .is_flush(act_in.is_flush),      .is_stall(act_in.is_stall),
        .is_valid_in(act_in.is_valid),   .pc_in(act_in.pc),   .instr_in(act_in.instr),
        .is_valid_out(act_out.is_valid), .pc_out(act_out.pc), .instr_out(act_out.instr)
    );
    
    int total_tests = 1000;
    int pass = 0, pass_v = 0, pass_inv = 0;
    int fail = 0, fail_v = 0, fail_i = 0, fail_p = 0;
    
    class ifid_test;
        rand bit        r_valid;
        rand bit [31:0] r_instr;
        
        function void apply_in();
            act_in.is_flush = 1'b0;
            act_in.is_stall = 1'b0;
            act_in.is_valid = r_valid;
            act_in.instr    = r_instr;
           
            
            exp_in.is_flush = 1'b0;
            exp_in.is_stall = 1'b0;
            exp_in.is_valid = r_valid;
            exp_in.instr    = r_instr;
            
        endfunction
        
        function void expected();
            if (exp_in.is_valid) begin
                exp_out.is_valid = exp_in.is_valid;
                exp_out.pc       = exp_in.pc;
                exp_out.instr    = exp_in.instr;
            end
        endfunction
        
        task check();
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                if (exp_in.is_valid == 1'b1) pass_v++;
                if (exp_in.is_valid == 1'b0) pass_inv++;
            end else begin
                fail++;
                if (exp_out.is_valid != act_out.is_valid) fail_v++;
                if (exp_out.pc != act_out.pc) fail_p++;
                if (exp_out.instr != act_out.instr) fail_i++;
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
        exp_out = '{default:0};
        
        reset = 1;
        #10;
        reset = 0;
        
        act_in.pc = 32'd0;
        exp_in.pc = 32'd0;
        
        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            //@(posedge clk);
            txn.apply_in();
             act_in.pc       = act_in.pc + 4;
             exp_in.pc       = act_in.pc + 4;
            @(posedge clk);
            txn.expected();
            #1;
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" Valid   : %d tests passed.", pass_v);
            $display(" Invalid : %d tests passed.", pass_inv);
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_v != 0) $display("Valid mismatch : %d", fail_v);
            if (fail_p != 0) $display("pc mismatch    : %d", fail_p);
            if (fail_i != 0) $display("instr mismatch : %d", fail_i);
        end
        $stop;
    end

endmodule
