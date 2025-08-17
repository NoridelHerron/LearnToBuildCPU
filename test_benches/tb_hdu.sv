`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 11:22:47 AM
// Module Name: testbench for HDU
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module tb_hdu();

    logic clk = 0;
    
    typedef struct packed {
        logic  [4:0] id_rs1, id_rs2;
        logic  [4:0] idex_rs1, idex_rs2, idex_rd, exmem_rd, memwb_rd; 
        logic        idex_memRead, exmem_regWrite, memwb_regWrite;
    } hdu_in;
    
    typedef struct packed {
        logic  [1:0] forwA, forwB;
        logic        stall;
    } hdu_out;
    
    hdu_in  act_in, exp_in;
    hdu_out act_out, exp_out;
    
    // Instantiate DUT
    hdu_v dut (
        .id_rs1(act_in.id_rs1),                 .id_rs2(act_in.id_rs2),
        .idex_rs1(act_in.idex_rs1),             .idex_rs2(act_in.idex_rs2), 
        .idex_rd(act_in.idex_rd),               .exmem_rd(act_in.exmem_rd), 
        .memwb_rd(act_in.memwb_rd),             .idex_memRead(actual_in.A), 
        .exmem_regWrite(act_in.exmem_regWrite), .memwb_regWrite(act_in.memwb_regWrite),
        .forwA(act_in.forwA),                   .forwB(act_in.forwB),
        .stall(act_in.stall)
    );
    
    int total_tests = 1000;
    int pass = 0, passA_exmem = 0, passA_memwb = 0, passB_exmem = 0, passB_memwb = 0, pass_stall = 0;
    int fail = 0, failA_exmem = 0, failA_memwb = 0, failB_exmem = 0, failB_memwb = 0, fail_stall = 0;
    
    class HDU_test;
        rand bit [4:0] rid_rs1, rid_rs2, ridex_rs1, ridex_rs2, ridex_rd, rexmem_rd, rmemwb_rd;
        rand bit       ridex_memRead, rexmem_regWrite, rmemwb_regWrite;
        
        function void apply_inputs();
            act_in.id_rs1         = rid_rs1;
            act_in.id_rs2         = rid_rs2;
            act_in.idex_rs1       = ridex_rs1;
            act_in.idex_rs2       = ridex_rs2;
            act_in.idex_rd        = ridex_rd;
            act_in.exmem_rd       = rexmem_rd;
            act_in.memwb_rd       = rmemwb_rd;
            act_in.idex_memRead   = ridex_memRead;
            act_in.exmem_regWrite = rexmem_regWrite;
            act_in.memwb_regWrite = rmemwb_regWrite;
            
            exp_in.id_rs1         = rid_rs1;
            exp_in.id_rs2         = rid_rs2;
            exp_in.idex_rs1       = ridex_rs1;
            exp_in.idex_rs2       = ridex_rs2;
            exp_in.idex_rd        = ridex_rd;
            exp_in.exmem_rd       = rexmem_rd;
            exp_in.memwb_rd       = rmemwb_rd;
            exp_in.idex_memRead   = ridex_memRead;
            exp_in.exmem_regWrite = rexmem_regWrite;
            exp_in.memwb_regWrite = rmemwb_regWrite;
        endfunction 
        
        task check();
        endtask
    endclass 
endmodule
