`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/25/2025 05:09:02 AM
// Design Name: 
// Module Name: tb_forw
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module tb_forw();

    typedef struct packed {
        logic        isForw_ON;
        logic [1:0]  forwA, forwB;
        logic [6:0]  op;
        logic [31:0] exmem, memwb;
        logic [31:0] data1, data2, s_data;
    } forw_in;
    
    typedef struct packed {
        logic [31:0] operand1, operand2, sData;
    } forw_out;
    
    logic clk = 0;
    always #5 clk = ~clk;
    
    forw_in  act_in, exp_in;
    forw_out act_out, exp_out;
    
    // Instantiate DUT
    forw_unit_s dut (
        .isForw_ON(act_in.isForw_ON), .op(act_in.op),
        .exmem_result(act_in.exmem),  .memwb_result(act_in.memwb),
        .forwA(act_in.forwA),         .forwB(act_in.forwB),
        .data1(act_in.data1),         .data2(act_in.data2),        .s_data(act_in.s_data),
       .operand1(act_out.operand1),   .operand2(act_out.operand2), .sData(act_out.sData)
    );
    
    int total_tests = 1000000;
    // Keep track all the test and make sure it covers all the cases
    int pass     = 0, fail = 0,     pass_ON  = 0; 
    int pass_fA0 = 0, pass_fA1 = 0, pass_fA2 = 0;
    int pass_fB0 = 0, pass_fB1 = 0, pass_fB2 = 0;
    
    // Help narrow down the bugs
    int fail_in = 0,  fail_fON = 0, fail_fA = 0, fail_fB = 0, fail_op = 0; 
    int fail_em = 0,  fail_mw  = 0, fail_d1 = 0, fail_d2 = 0, fail_sd = 0; 
    int fail_out = 0, fail_o1 = 0,  fail_o2 = 0, fail_os = 0;
    
    int fail_o20 = 0, fail_o21 = 0, fail_o22 = 0;
    
    class forw_test;
        rand bit        r_isForw_ON;
        rand bit [3:0]  r_aluOp;
        rand bit [6:0]  r_op;
        rand bit [1:0]  r_forwA, r_forwB;
        rand bit [31:0] r_data1, r_data2, rs_data;
        rand bit [31:0] r_exmem, r_memwb;
        
        constraint unique_op {
            r_op dist {
                `R_TYPE := 25, 
                `S_TYPE := 25,
               // `B_TYPE := 20,
                `I_IMM  := 25, 
                `I_LOAD := 25
            };
        }
        
        constraint unique_fA {
            r_forwA dist {
                2'd0 := 40, 
                2'd1 := 30, 
                2'd2 := 30
            };
        }
        
        constraint unique_fB {
            r_forwB dist {
                2'd0 := 40, 
                2'd1 := 30, 
                2'd2 := 30
            };
         }
            
            
        function void apply_actual();
            // Assign actual inputs
            act_in.isForw_ON = r_isForw_ON;
            act_in.forwA     = r_forwA; 
            act_in.forwB     = r_forwB;
            act_in.op        = r_op;
            act_in.data1     = r_data1; 
            act_in.data2     = r_data2; 
            act_in.s_data    = rs_data;
            act_in.exmem     = r_exmem; 
            act_in.memwb     = r_memwb; 
            
            // Assign expected inputs
            exp_in.isForw_ON = r_isForw_ON;
            exp_in.forwA     = r_forwA; 
            exp_in.forwB     = r_forwB;
            exp_in.op        = r_op;
            exp_in.data1     = r_data1; 
            exp_in.data2     = r_data2; 
            exp_in.s_data    = rs_data;
            exp_in.exmem     = r_exmem; 
            exp_in.memwb     = r_memwb; 
        endfunction 
        
        function void exp_output;
            if (exp_in.isForw_ON) begin
                case (exp_in.forwA)
                    2'b00   : exp_out.operand1 = exp_in.data1;
                    2'b01   : exp_out.operand1 = exp_in.exmem;
                    2'b10   : exp_out.operand1 = exp_in.memwb;
                    default : exp_out.operand1 = 32'd0;
                endcase
            
                case (exp_in.forwB)
                    2'b00   : begin 
                        exp_out.operand2 = exp_in.data2;
                        exp_out.sData    = exp_in.s_data;
                    end
                    
                    2'b01   : begin
                        case (exp_in.op)
                            `R_TYPE : begin
                                exp_out.operand2 = exp_in.exmem;
                                exp_out.sData    = exp_in.s_data;
                            end
                            
                            `I_IMM, `I_LOAD : begin
                                exp_out.operand2 = exp_in.data2;
                                exp_out.sData    = exp_in.s_data;
                            end
                            
                            `S_TYPE : begin
                                exp_out.operand2 = exp_in.data2;
                                exp_out.sData    = exp_in.exmem;
                            end
                            
                            default  : begin
                                exp_out.operand2 = 32'd0;
                                exp_out.sData    = 32'd0;
                            end     
                        endcase
                    end
                    
                    2'b10   : begin 
                        case (exp_in.op)
                            `R_TYPE : begin
                                exp_out.operand2 = exp_in.memwb;
                                exp_out.sData    = exp_in.s_data;
                            end
                            
                            `I_IMM, `I_LOAD : begin
                                exp_out.operand2 = exp_in.data2;
                                exp_out.sData    = exp_in.s_data;
                            end
                            
                            `S_TYPE : begin
                                exp_out.operand2 = exp_in.data2;
                                exp_out.sData    = exp_in.memwb;
                            end                       
                            
                            default  : begin
                                exp_out.operand2 = 32'd0;
                                exp_out.sData    = 32'd0;
                            end     
                        endcase
                    end
                    
                    default : begin
                        exp_out.operand2 = 32'd0;
                        exp_out.sData    = 32'd0;
                    end
                endcase
            
            end else begin
                exp_out.operand1 = exp_in.data1;
                exp_out.operand2 = exp_in.data2;
                exp_out.sData    = exp_in.s_data;
            end        
        endfunction     
        
        task check();
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                if (act_in.isForw_ON == exp_in.isForw_ON && act_in.isForw_ON == 1'b1) begin
                    pass_ON++;
                    case (act_in.forwA)
                        2'b0  : pass_fA0++;
                        2'b01 : pass_fA1++;
                        2'b10 : pass_fA2++;
                        default:;
                    endcase
                    case (act_in.forwB)
                        2'b0  : pass_fB0++;
                        2'b01 : pass_fB1++;
                        2'b10 : pass_fB2++;
                        default:;
                    endcase
                end
                
            end else begin
                fail++;
                if (act_in !== exp_in) begin
                    fail_in++;
                    if (act_in.isForw_ON !== exp_in.isForw_ON) fail_fON++;
                    if (act_in.forwA     !== exp_in.forwA)     fail_fA++;
                    if (act_in.forwB     !== exp_in.forwB)     fail_fB++;
                    if (act_in.op        !== exp_in.op)        fail_op++;
                    if (act_in.exmem     !== exp_in.exmem)     fail_em++;
                    if (act_in.memwb     !== exp_in.memwb )    fail_mw++;
                    if (act_in.data1     !== exp_in.data1)     fail_d1++;
                    if (act_in.data2     !== exp_in.data2)     fail_d2++;
                    if (act_in.s_data    !== exp_in.s_data)    fail_sd++;
                    
                end else if (act_out !== exp_out) begin
                    fail_out++;
                    if (act_out.operand1  !== exp_out.operand1)  fail_o1++;
                    if (act_out.operand2  !== exp_out.operand2)  fail_o2++;
                    if (act_out.sData     !== exp_out.sData)     fail_os++;
                end
            end
        endtask
    endclass

    forw_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = '{default:0};
        act_out = '{default:0};
        exp_out = '{default:0};

        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply_actual();
            #1;
            txn.exp_output();
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            if (pass_ON != 0) begin
                $display(" ---------- FORWA ------------.");
                $display(" NONE   : %d tests passed.", pass_fA0);
                $display(" EX_MEM : %d tests passed.", pass_fA1);
                $display(" MEM_WB : %d tests passed.", pass_fA2);
                $display(" ---------- FORWB ------------.");
                $display(" NONE   : %d tests passed.", pass_fB0);
                $display(" EX_MEM : %d tests passed.", pass_fB1);
                $display(" MEM_WB : %d tests passed.", pass_fB2);
            end 
            
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_in != 0) begin
                $display("Inputs mismatches     : %d", fail_in);
                if (fail_fON != 0) $display("IS ON mismatches     : %d", fail_fON);
                if (fail_fA  != 0) $display("ForwA mismatches     : %d", fail_fA);
                if (fail_fB  != 0) $display("ForwB mismatches     : %d", fail_in);
                if (fail_op  != 0) $display("OP mismatches        : %d", fail_op);
                if (fail_em  != 0) $display("EXMEM mismatches     : %d", fail_em);
                if (fail_mw  != 0) $display("MEMWB mismatches     : %d", fail_mw);
                if (fail_d1  != 0) $display("DATA 1 mismatches    : %d", fail_d1);
                if (fail_d2  != 0) $display("DATA 2 mismatches    : %d", fail_d2);
                if (fail_sd  != 0) $display("S_DATA  mismatches   : %d", fail_sd);
            end else if (fail_out != 0) begin
                $display("Outputs mismatches     : %d", fail_out);
                if (fail_o1  != 0) $display("OPER 1 mismatches    : %d", fail_o1);
                if (fail_o2  != 0) $display("OPER 2 mismatches    : %d", fail_o2);
                if (fail_os  != 0) $display("S_DATA  mismatches   : %d", fail_os);
            end
            
        end
        $finish;
    end
endmodule

