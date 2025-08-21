`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 11:22:47 AM
// Module Name: testbench for HDU
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module tb_hdu();

    logic clk = 0;
    
    typedef struct packed {
        logic  [4:0] id_rs1, id_rs2, id_rd;
        logic        id_memRead, id_regWrite; 
        logic  [4:0] idex_rs1, idex_rs2, idex_rd;
        logic        idex_memRead, idex_regWrite;  
        logic  [4:0] exmem_rd; 
        logic        exmem_regWrite;
        logic  [4:0] memwb_rd; 
        logic        memwb_regWrite;
    } hdu_in;
    
    typedef struct packed {
        logic  [1:0] forwA, forwB;
        logic        stall;
    } hdu_out;
    
    always #5 clk = ~clk;
    
    hdu_in  act_in, exp_in;
    hdu_out act_out, exp_out;
    
    // Instantiate DUT
    hdu_v dut (
        .id_rs1(act_in.id_rs1),                 .id_rs2(act_in.id_rs2),
        .idex_rs1(act_in.idex_rs1),             .idex_rs2(act_in.idex_rs2), 
        .idex_rd(act_in.idex_rd),               .exmem_rd(act_in.exmem_rd), 
        .memwb_rd(act_in.memwb_rd),             .idex_memRead(act_in.idex_memRead), 
        .exmem_regWrite(act_in.exmem_regWrite), .memwb_regWrite(act_in.memwb_regWrite),
        .forwA(act_out.forwA),                  .forwB(act_out.forwB),
        .stall(act_out.stall)
    );
    
    int total_tests = 1000000;
    int pass = 0, passA_exmem = 0, passA_memwb = 0, passA_none = 0, passB_exmem = 0, passB_memwb = 0, passB_none = 0, pass_stall = 0;
    int fail = 0, failA_exmem = 0, failA_memwb = 0, failA_none = 0, failB_exmem = 0, failB_memwb = 0, failB_none = 0, fail_stall = 0;
    
    class HDU_test;
        rand bit [4:0] rid_rs1, rid_rs2, rid_rd;
        rand bit       rid_memRead, rid_regWrite;
        
        function void apply_actual();
            act_in.id_rs1           = rid_rs1;
            act_in.id_rs2           = rid_rs2;
            act_in.id_rd            = rid_rd;
            act_in.id_memRead       = rid_memRead;
            act_in.id_regWrite      = rid_regWrite;
            
        endfunction 
        
        function void apply_expected();
            exp_in.id_rs1           = rid_rs1;
            exp_in.id_rs2           = rid_rs2;
            exp_in.id_rd            = rid_rd;
            exp_in.id_memRead       = rid_memRead;
            exp_in.id_regWrite      = rid_regWrite;
        endfunction 
        
        task check();
                 
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                if (exp_out.forwA == 2'b00) passA_none++;
                if (exp_out.forwA == 2'b01) passA_exmem++;
                if (exp_out.forwA == 2'b10) passA_memwb++;
                if (exp_out.forwB == 2'b00) passB_none++;
                if (exp_out.forwB == 2'b01) passB_exmem++;
                if (exp_out.forwB == 2'b10) passB_memwb++;
                if (exp_out.stall == 1'b1)  pass_stall++;
            end else begin
                fail++;
                if (exp_out.forwA != act_out.forwA && exp_out.forwA == 2'b00) failA_none++;
                if (exp_out.forwA != act_out.forwA && exp_out.forwA == 2'b01) failA_exmem++;
                if (exp_out.forwA != act_out.forwA && exp_out.forwA == 2'b10) failA_memwb++;
                if (exp_out.forwB != act_out.forwB && exp_out.forwB == 2'b00) failB_none++;
                if (exp_out.forwB != act_out.forwB && exp_out.forwB == 2'b01) failB_exmem++;
                if (exp_out.forwB != act_out.forwB && exp_out.forwB == 2'b10) failB_memwb++;
                if (exp_out.stall != act_out.stall) fail_stall++;
            end
        endtask
    endclass 
    
    HDU_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = act_in;
        exp_out = '{default:0};
        
        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply_actual();
            txn.apply_expected();
            act_in.idex_rs1         <= act_in.id_rs1;
            act_in.idex_rs2         <= act_in.id_rs2;
            act_in.idex_rd          <= act_in.id_rd;
            act_in.idex_memRead     <= act_in.id_memRead;
            act_in.idex_regWrite    <= act_in.id_regWrite;
            act_in.exmem_rd         <= act_in.idex_rd;
            act_in.exmem_regWrite   <= act_in.idex_regWrite;
            act_in.memwb_rd         <= act_in.exmem_rd;
            act_in.memwb_regWrite   <= act_in.exmem_regWrite;
            
            exp_in.idex_rs1         <= exp_in.id_rs1;
            exp_in.idex_rs2         <= exp_in.id_rs2;
            exp_in.idex_rd          <= exp_in.id_rd;
            exp_in.idex_memRead     <= exp_in.id_memRead;
            exp_in.idex_regWrite    <= exp_in.id_regWrite;
            exp_in.exmem_rd         <= exp_in.idex_rd;
            exp_in.exmem_regWrite   <= exp_in.idex_regWrite;
            exp_in.memwb_rd         <= exp_in.exmem_rd;
            exp_in.memwb_regWrite   <= exp_in.exmem_regWrite;
            
            #1;
            if (exp_in.exmem_regWrite && exp_in.exmem_rd != 5'd0 && exp_in.exmem_rd == exp_in.idex_rs1)
                exp_out.forwA = 2'b01;
            else if (exp_in.memwb_regWrite && exp_in.memwb_rd != 5'd0 && exp_in.memwb_rd == exp_in.idex_rs1)
                exp_out.forwA = 2'b10;
            else
                 exp_out.forwA = 2'b00;
                 
            if (exp_in.exmem_regWrite && exp_in.exmem_rd != 5'd0 && exp_in.exmem_rd == exp_in.idex_rs2)
                exp_out.forwB = 2'b01;
            else if (exp_in.memwb_regWrite && exp_in.memwb_rd != 5'd0 && exp_in.memwb_rd == exp_in.idex_rs2)
                exp_out.forwB = 2'b10;
            else
                 exp_out.forwB = 2'b00;
                 
            if (exp_in.idex_memRead && exp_in.idex_rd != 5'd0 && (exp_in.idex_rd == exp_in.id_rs1 || exp_in.idex_rd == exp_in.id_rs2)) 
                exp_out.stall = 1'b1; 
            else
                exp_out.stall = 1'b0;     
                
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" No hazard rs1     : %d tests passed.", passA_none);
            $display(" EX_MEM due to rs1 : %d tests passed.", passA_exmem);
            $display(" MEM_WB due to rs1 : %d tests passed.", passA_memwb);
            $display(" No hazard rs2     : %d tests passed.", passB_none);
            $display(" EX_MEM due to rs2 : %d tests passed.", passB_exmem);
            $display(" MEM_WB due to rs2 : %d tests passed.", passB_memwb);
            $display(" STALL             : %d tests passed.", pass_stall);
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (failA_none != 0)  $display("inputs No hazard rs1     : %d", failA_none);
            if (failA_exmem != 0) $display("inputs EX_MEM due to rs1 : %d", failA_exmem);
            if (failA_memwb != 0) $display("inputs MEM_WB due to rs1 : %d", failA_memwb);
            if (failB_none != 0)  $display("inputs No hazard rs2     : %d", failB_none);
            if (failB_exmem != 0) $display("inputs EX_MEM due to rs2 : %d", failB_exmem);
            if (failB_memwb != 0) $display("inputs MEM_WB due to rs2 : %d", failB_memwb);
            if (fail_stall != 0)  $display("STALL                    : %d", fail_stall);
        end
        $stop;
    end
endmodule
