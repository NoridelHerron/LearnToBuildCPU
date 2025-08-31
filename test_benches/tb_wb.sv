// Noridel Herron
// 7/14/2025
// WB stage test bench
`timescale 1ns / 1ps

module tb_wb();
    logic clk = 0;
    always #5 clk = ~clk; // Clock: 10ns period
    
    typedef struct packed {
        logic [31:0]  alu_data;
        logic [31:0]  mem_data;
        logic         is_memRead;
        logic         is_memWrite;
    } wb_in;
    
    wb_in        act_in;             // input
    logic [31:0] act_data, exp_data; // outputs
    
    // Instantiate DUT
    WB_s dut (
        // inputs
        .is_memRead(act_in.is_memRead),
        .is_memWrite(act_in.is_memWrite),
        .alu_data(act_in.alu_data),
        .mem_data(act_in.mem_data),
        // output
        .wb_data(act_data)
    );
    
    int total_tests = 10000;
    // Keep track all the test and make sure it covers all the cases
    int pass = 0, fail = 0, num_isRegWrite = 0, num_isMemRead = 0, num_none = 0;
    
    class wb_test;
        rand bit [31:0] rand_alu, rand_mem;
        rand bit        rand_mR, rand_mW;
        
        function void apply_inputs();
                act_in.alu_data     = rand_alu;
                act_in.mem_data     = rand_mem;
                act_in.is_memRead   = rand_mR;
                act_in.is_memWrite  = rand_mW;
        endfunction
        
        task check();
            #1; // wait for the output to settle
            if (rand_mR == 1'b1) 
                exp_data = rand_mem;
            else if (rand_mW == 1'b1)
                exp_data = 32'd0;
            else
                exp_data = rand_alu;
            
           // Compare actual and expected output 
           if (act_data === exp_data ) 
                pass++;
           else
                fail++;   
        endtask     
    endclass
    
    wb_test t;
    
    initial begin
        $display("Starting WB randomized testbench...");
        // Initialiaze input and outputs
        act_in   = '{alu_data: 32'b0, mem_data: 32'b0, is_memRead: 1'b0, is_memWrite: 1'b0};
        act_data = 32'b0;
        exp_data = 32'b0;
        
        repeat (total_tests) begin
            t = new();
            void'(t.randomize());
            @(posedge clk);
            t.apply_inputs();  
            //@(posedge clk); 
            #1;
            t.check();
        end

        // If there's any error, "Case covered summary" will not be display until everything is resolve
        if (pass == total_tests)
            $display("All %0d tests passed!", pass);
        else
            $display("%0d tests failed out of %0d", fail, total_tests);
     
       $stop;
    end
endmodule
