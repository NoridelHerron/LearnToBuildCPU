`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 09:14:38 AM
// Module Name: regFile_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module tb_regFile();
    logic clk = 0;
    
    typedef struct packed {
        logic        isWrite;
        logic [4:0]  rs1, rs2, rd; 
        logic [31:0] writeData; 
    } reg_in;
    
    typedef struct packed {
        logic [31:0] readData1, readData2; 
    } reg_out;

    // DUT signals
    reg_in  act_in, exp_in;
    reg_out act_out, exp_out;
    

    // Instantiate DUT
    regFile_s dut (
        .clk(clk),
        .isWrite(act_in.isWrite),       .rs1(act_in.rs1), 
        .rs2(act_in.rs2),               .rd(act_in.rd),
        .writeData(act_in.writeData), 
        .readData1(act_out.readData1), 
        .readData2(act_out.readData2)
    );
    
    // Clock generation
    always #5 clk = ~clk;

    // Reference model
    logic [31:0] golden_regs[0:31];
    
    
    integer total_tests = 1000000;
    integer pass = 0, fail = 0, fail_in = 0, fail_readData1 = 0, fail_readData2 = 0;
    integer pass_rd0 = 0, pass_rs10 = 0, pass_rs20 = 0, pass_rdrs1 = 0, pass_rdrs2 = 0;

    // Transaction class for stimulus
    class RegTest;
        rand bit        we;
        rand bit [31:0] rand_data;
        rand bit [4:0]  rand_rs1, rand_rs2, rand_rd;

        function void apply();
            // Apply writes
            act_in.isWrite   = we;
            act_in.rd        = rand_rd;  
            act_in.writeData = rand_data; 
            act_in.rs1       = rand_rs1; 
            act_in.rs2       = rand_rs2;
            
            exp_in.isWrite   = we;
            exp_in.rd        = rand_rd;  
            exp_in.writeData = rand_data; 
            exp_in.rs1       = rand_rs1; 
            exp_in.rs2       = rand_rs2;
            
            exp_out.readData1 = (exp_in.rs1 == 0) ? 32'b0 : golden_regs[exp_in.rs1];
            exp_out.readData2 = (exp_in.rs2 == 0) ? 32'b0 : golden_regs[exp_in.rs2];
            
            // Update reference model on posedge clk
            if (exp_in.isWrite && exp_in.rd != 0)
                golden_regs[exp_in.rd] = exp_in.writeData;
           
        endfunction

        task check();
            #1;
            if (act_out === exp_out) begin
                pass++;
                if (act_in.isWrite && act_in.rd == 5'd0 && golden_regs[exp_in.rd] == 32'd0) pass_rd0++;
                if (act_in.rs1 == 5'd0 && exp_out.readData1 == 32'd0) pass_rs10++;
                if (act_in.rs2 == 5'd0 && exp_out.readData2 == 32'd0) pass_rs20++;
                if (act_in.rs1 == act_in.rd && exp_out.readData1 == golden_regs[exp_in.rs1]) pass_rdrs1++;
                if (act_in.rs2 == act_in.rd && exp_out.readData2 == golden_regs[exp_in.rs2]) pass_rdrs2++;
            end else begin
                if (act_in === exp_in)
                    fail_in++;
                if (act_out.readData1 != exp_out.readData1) 
                    fail_readData1++;
                else
                    fail_readData2++;
          
            end  
        endtask
    endclass
    
    RegTest txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = act_in;
        exp_out = act_in;
        golden_regs = '{default:0};


        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply();
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" Write, but rd = 0 : %d tests passed.", pass_rd0);
            $display(" rs1 = 0 : %d tests passed.", pass_rs10);
            $display(" rs2 = 0 : %d tests passed.", pass_rs20);
            $display(" rs1 = rd : %d tests passed.", pass_rdrs1);
            $display(" rs2 = rd : %d tests passed.", pass_rdrs2);
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_in != 0)
                $display("inputs failed = %d", fail_in);
            
            if (fail_readData1 != 0)
                $display("rs1 value failed : %d", fail_readData1);
            else if (fail_readData2 != 0)
                $display("rs2 value failed : %d", fail_readData2);
          
        end
        $stop;
    end
endmodule