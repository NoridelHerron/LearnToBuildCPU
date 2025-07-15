// Noridel Herron
// 7/14/2025
// WB stage test bench
`timescale 1ns / 1ps

module tb_mem_stage();
    logic clk = 0;

    typedef struct packed {
        logic         mem_read;
        logic         mem_write;
        logic [31:0]  address;
        logic [31:0]  write_data; 
    } dataMem_in;
    
    dataMem_in   act_in;             // input
    logic [31:0] act_data, exp_data; // outputs
    
    // Reference model
    logic [31:0] golden_mem[0:1023];
    //logic [31:0] golden_mem[0:31]; I tend to use smaller array for initial test
    
    // Instantiate DUT
    mem_stage_v dut (
        // inputs
        .clk(clk),
        .is_memRead(act_in.mem_read),
        .is_memWrite(act_in.mem_write),
        .address(act_in.address),
        .S_data(act_in.write_data),
        // output
        .data_out(act_data)
    );
    
    always #5 clk = ~clk; // Clock: 10ns period
    
    int total_tests = 100000;
    // Keep track all the test and make sure it covers all the cases
    int pass = 0, fail = 0, num_isRegWrite = 0, num_isMemRead = 0, num_none = 0;
    
    class wb_test;
        rand bit [31:0] rand_data;
        rand bit [31:0] rand_addr;
        rand bit        rand_mR, rand_mW;
        
        function void apply_inputs();
                act_in.address     = rand_addr;
                act_in.write_data  = rand_data;
                act_in.mem_read    = rand_mR;
                act_in.mem_write   = rand_mW;
        endfunction
        
        task check();
            #1; // wait for the output to settle
            if (rand_mW == 1'b1) 
                golden_mem[rand_addr[11:2]] = rand_data;
            
            if (rand_mR == 1'b1 && rand_mW === 1'b0) 
                exp_data = golden_mem[rand_addr[11:2]];
            else
                exp_data = 32'b0;
                
           // Compare actual and expected output 
           if (act_data === exp_data ) begin
                if (rand_mW === 1'b1 && golden_mem[rand_addr[11:2]] === rand_data && exp_data === 32'b0) 
                    pass++;
                else if (rand_mR === 1'b1 && rand_mW === 1'b0 && exp_data === golden_mem[rand_addr[11:2]]) 
                    pass++;  
                else if (exp_data === 32'b0) 
                    pass++;  
           end else
                fail++;   
        endtask     
    endclass
    
    wb_test t;
    
    initial begin
        $display("Starting DATA MEMORY randomized testbench...");
        // Initialiaze input and outputs
        act_in   = '{mem_read: 1'b0, mem_write: 1'b0, address: 10'b0, write_data: 32'b0 };
        act_data = 32'b0;
        exp_data = 32'b0;
        
        // Initialiaze memory
        golden_mem = '{default:0};
        
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