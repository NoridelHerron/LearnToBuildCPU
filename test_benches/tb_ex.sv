`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/25/2025 04:02:42 AM
// Module Name: tb_ex
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"
`include "functions_pkg.sv"

module tb_ex();

    import functions_pkg::*;

    logic clk = 0;
 
    typedef struct packed {
        logic [3:0]  aluOp;
        logic        isForw_ON; 
        logic [6:0]  op;
        logic [31:0] exmem;
        logic [31:0] memwb; 
        logic [1:0]  forwA, forwB;
        logic [31:0] data1, data2, s_data;
    } ex_in;
    
    typedef struct packed {
        logic [31:0] result, sData;
        logic        Z, N, C, V;
    } ex_out;

    always #5 clk = ~clk;
    
    logic [95:0] forw_out = 0;
    logic [35:0] alu_out  = 0;
    ex_in        act_in,  exp_in;
    ex_out       act_out, exp_out;
    
    ex_v uut(
        .alu_op(act_in.aluOp),       .isForw_ON(act_in.isForw_ON),
        .op(act_in.op),              .exmem_result(act_in.exmem), 
        .memwb_result(act_in.memwb), .forwA(act_in.forwA),        
        .forwB(act_in.forwB),        .data1(act_in.data1),        
        .data2(act_in.data2),        .s_data(act_in.s_data),
        .result(act_out.result),     .sData(act_out.sData),
        .Z(act_out.Z),               .N(act_out.N),
        .C(act_out.C),               .V(act_out.V)
    );
    
    int total_tests = 2000000;
    // Keep track all the test and make sure it covers all the cases
    int pass     = 0, fail = 0, pass_default = 0, fail_default = 0;
    int pass_add = 0, pass_sub = 0, pass_xor = 0, pass_or = 0, pass_and = 0;
    int pass_sll = 0, pass_srl = 0, pass_sra = 0, pass_slt = 0, pass_sltu = 0;
 
    int pass_ON  = 0, pass_fA0 = 0, pass_fA1 = 0, pass_fA2 = 0;
    int pass_fB0 = 0, pass_fB1 = 0, pass_fB2 = 0;
    
    // Help narrow down the bugs
    int fail_add    = 0, fail_sub = 0, fail_xor  = 0, fail_or  = 0, fail_and  = 0;
    int fail_sll    = 0, fail_srl = 0, fail_sra  = 0, fail_slt = 0, fail_sltu = 0;
    
    int fail_in = 0,  fail_fON = 0, fail_fA  = 0, fail_fB = 0, fail_op = 0; 
    int fail_em = 0,  fail_mw  = 0, fail_d1  = 0, fail_d2 = 0, fail_sd = 0; 
    int fail_out = 0, fail_res = 0, fail_osD = 0, fail_z = 0, fail_v = 0, fail_c = 0, fail_n = 0;
    
    class ex_test;
        rand bit        r_isON;
        rand bit [3:0]  r_aluOp;
        rand bit [6:0]  r_op;
        rand bit [1:0]  r_forwA, r_forwB;
        rand bit [31:0] r_data1, r_data2, rs_data, r_exmem, r_memwb;
        
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
        
        constraint unique_ALUop {
            r_aluOp dist {
                `ALU_ADD  := 10,
                `ALU_SUB  := 10,
                `ALU_XOR  := 10,
                `ALU_OR   := 10,
                `ALU_AND  := 10,
                `ALU_SLL  := 10,
                `ALU_SRL  := 10,
                `ALU_SRA  := 10,
                `ALU_SLT  := 10,
                `ALU_SLTU := 10
                };
            }
        
        function void apply_actual();
            // I used this for specific debugging purpose.
            // When everything are in place and match up, I randomly assigned the following
            //act_in.isForw_ON = 1;      
          //  act_in.aluOp     = `ALU_SUB;      
           // exp_in.isForw_ON = 1; 
           // exp_in.aluOp     = `ALU_SUB;
            
            // Assign actual inputs
            act_in.isForw_ON = r_isON;     
            act_in.aluOp     = r_aluOp;
            act_in.op        = r_op;
            act_in.forwA     = r_forwA;
            act_in.forwB     = r_forwB;
            act_in.data1     = r_data1;
            act_in.data2     = r_data2;
            act_in.s_data    = rs_data;
            act_in.exmem     = r_exmem;
            act_in.memwb     = r_memwb;
            
            // Assign expected inputs
            exp_in.isForw_ON = r_isON; 
            exp_in.aluOp     = r_aluOp;
            exp_in.op        = r_op;
            exp_in.forwA     = r_forwA;
            exp_in.forwB     = r_forwB;
            exp_in.data1     = r_data1;
            exp_in.data2     = r_data2;
            exp_in.s_data    = rs_data;
            exp_in.exmem     = r_exmem;
            exp_in.memwb     = r_memwb;
        endfunction 
        
        function void exp_output();
            forw_out = Get_expected_forw( exp_in.isForw_ON, exp_in.op, exp_in.exmem, exp_in.memwb, 
                                          exp_in.forwA, exp_in.forwB, exp_in.data1, exp_in.data2, exp_in.s_data );
                                          
            alu_out  = Get_expected_aluResult(forw_out[95:64], forw_out[63:32], exp_in.aluOp);
            
            // Assign outputs
            exp_out.Z      = alu_out[35];
            exp_out.N      = alu_out[34];
            exp_out.V      = alu_out[33];
            exp_out.C      = alu_out[32];
            exp_out.result = alu_out[31:0];
            exp_out.sData  = forw_out[31:0];
            
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
                
                case (exp_in.aluOp)
                    `ALU_ADD : pass_add++;
                    `ALU_SUB : pass_sub++;
                    `ALU_XOR : pass_xor++;
                    `ALU_AND : pass_and++;
                    `ALU_OR  : pass_or++;
                    `ALU_SLL : pass_sll++;
                    `ALU_SLT : pass_slt++;
                    `ALU_SLTU: pass_sltu++;
                    `ALU_SRL : pass_srl++;
                    `ALU_SRA : pass_sra++;
                    default  : pass_default++;
                endcase
                
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
                    case (exp_in.aluOp)
                        `ALU_ADD : fail_add++;
                        `ALU_SUB : fail_sub++;
                        `ALU_XOR : fail_xor++;
                        `ALU_AND : fail_and++;
                        `ALU_OR  : fail_or++;
                        `ALU_SLL : fail_sll++;
                        `ALU_SLT : fail_slt++;
                        `ALU_SLTU: fail_sltu++;
                        `ALU_SRL : fail_srl++;
                        `ALU_SRA : fail_sra++;
                        default  : fail_default++;
                    endcase
                    
                    if (act_out.result !== exp_out.result)fail_res++;
                    if (act_out.sData  !== exp_out.sData) fail_osD++;
                    if (act_out.Z      !== exp_out.Z)     fail_z++;
                    if (act_out.V      !== exp_out.V)     fail_v++;
                    if (act_out.N      !== exp_out.N)     fail_n++;
                    if (act_out.C      !== exp_out.C)     fail_c++;
                    
                end
            end
        endtask
    endclass
    
    ex_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in   = '{default:0};
        exp_in   = '{default:0};
        exp_out  = '{default:0};

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
            
            $display("All %0d tests passed!", pass);
            $display("Case Covered Summary!!!");
            $display("ADD     : %0d ", pass_add);
            $display("SUB     : %0d ", pass_sub);
            $display("SLL     : %0d ", pass_sll);
            $display("SLT     : %0d ", pass_slt);
            $display("SLTU    : %0d ", pass_sltu);
            $display("XOR     : %0d ", pass_xor);
            $display("SRL     : %0d ", pass_srl);
            $display("SRA     : %0d ", pass_sra);
            $display("OR      : %0d ", pass_or);
            $display("AND     : %0d ", pass_and);
            $display("Default : %0d ", pass_default);
            
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
                if (fail_res  != 0) $display("RESULT mismatches      : %d", fail_res);
                if (fail_osD  != 0) $display("S_DATA mismatches      : %d", fail_osD);
                if (fail_z    != 0) $display("Z FLAG  mismatches     : %d", fail_z);
                if (fail_c    != 0) $display("C FLAG  mismatches     : %d", fail_c);
                if (fail_n    != 0) $display("N FLAG  mismatches     : %d", fail_n);
                if (fail_v    != 0) $display("V FLAG  mismatches     : %d", fail_v);
                
                $display("----------OPERATION----------");
                    if (fail_add  !== 0) $display("ADD    : %0d ", fail_add);
                    if (fail_sub  !== 0) $display("SUB    : %0d ", fail_sub);
                    if (fail_sll  !== 0) $display("SLL    : %0d ", fail_sll);
                    if (fail_slt  !== 0) $display("SLT    : %0d ", fail_slt);
                    if (fail_sltu !== 0) $display("SLTU   : %0d ", fail_sltu);
                    if (fail_xor  !== 0) $display("XOR    : %0d ", fail_xor);
                    if (fail_srl  !== 0) $display("SRL    : %0d ", fail_srl);
                    if (fail_sra  !== 0) $display("SRA    : %0d ", fail_sra);
                    if (fail_or   !== 0) $display("OR     : %0d ", fail_or);
                    if (fail_and  !== 0) $display("AND    : %0d ", fail_and);
                    if (fail_res  !== 0) $display("RESULT : %0d ", fail_res);
                    if (fail_z    !== 0) $display("Z      : %0d ", fail_z);
                    if (fail_v    !== 0) $display("V      : %0d ", fail_v);
                    if (fail_n    !== 0) $display("N      : %0d ", fail_n);
                    if (fail_c    !== 0) $display("C      : %0d ", fail_c);
            end 
        end
        $finish;
    end
    
endmodule
