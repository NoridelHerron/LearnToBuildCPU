`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/14/2025 07:58:09 AM
// Module Name: alu_tb
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module alu_tb();
    logic clk = 0;
    always #5 clk = ~clk; // Clock: 10ns period
    
    typedef struct packed {
        logic [31:0] A;
        logic [31:0] B;
        logic [3:0]  alu_op;
    } alu_in;
    
     typedef struct packed {
        logic [31:0] result;
        logic Z, V, C, N;
    } alu_out;
    
    // Actual and Expected I/O
    alu_in      actual_in, expected_in;
    alu_out     actual_out, expected_out;
    
    // Instantiate DUT
    v_alu dut (
        .A(actual_in.A),
        .B(actual_in.B),
        .alu_op(actual_in.alu_op),
        // outputs
        .result(actual_out.result),
        .Z(actual_out.Z),
        .N(actual_out.N),
        .C(actual_out.C),
        .V(actual_out.V)
    );
    
    int total_tests = 1000000;
    // Keep track all the test and make sure it covers all the cases
    int pass     = 0, fail = 0, pass_default = 0, fail_default = 0;
    int pass_add = 0, pass_sub = 0, pass_xor = 0, pass_or = 0, pass_and = 0;
    int pass_sll = 0, pass_srl = 0, pass_sra = 0, pass_slt = 0, pass_sltu = 0;
    
    // Help narrow down the bugs
    int fail_inA = 0, fail_inB = 0, fail_inOP = 0;
    int fail_add = 0, fail_sub = 0, fail_xor = 0, fail_or = 0, fail_and = 0;
    int fail_sll = 0, fail_srl = 0, fail_sra = 0, fail_slt = 0, fail_sltu = 0;
    int fail_result = 0, fail_z = 0, fail_v = 0, fail_n = 0, fail_c = 0;
    
    class Alu_test;
        rand bit [31:0] rand_A,  rand_B;
        rand bit [3:0]  rand_op; 
        
        function void apply_inputs();
                actual_in.A        = rand_A;
                actual_in.B        = rand_B;
                actual_in.alu_op   = rand_op;
                
                expected_in.A      = rand_A;
                expected_in.B      = rand_B;
                expected_in.alu_op = rand_op;
        endfunction
        
        task check();
            case (expected_in.alu_op)
                `ALU_ADD:  expected_out.result = rand_A + rand_B;
                `ALU_SUB:  expected_out.result = rand_A - rand_B;
                `ALU_XOR:  expected_out.result = rand_A ^ rand_B;
                `ALU_OR:   expected_out.result = rand_A | rand_B;
                `ALU_AND:  expected_out.result = rand_A & rand_B;
                `ALU_SLL:  expected_out.result = rand_A << rand_B[4:0];
                `ALU_SRL:  expected_out.result = rand_A >> rand_B[4:0];
                `ALU_SRA:  expected_out.result = $signed(rand_A) >>> rand_B[4:0];
                `ALU_SLT:  expected_out.result = ($signed(rand_A) < $signed(rand_B)) ? 32'b1 : 32'b0;
                `ALU_SLTU: expected_out.result = (rand_A < rand_B) ? 32'b1 : 32'b0;
                default: expected_out.result   = 32'b0;
            endcase
            
            if (expected_in.alu_op == `ALU_ADD || expected_in.alu_op == `ALU_SUB) begin
                if (expected_in.alu_op == `ALU_ADD) begin
                    expected_out.C = (expected_out.result < expected_in.A || expected_out.result < expected_in.B) ? 1'b1 : 1'b0;
                    expected_out.V = ((expected_in.A[31] == expected_in.B[31]) && (expected_out.result[31] != expected_in.A[31]))? 1'b1 : 1'b0;
                    
                end else begin
                    expected_out.C = (expected_in.A >= expected_in.B) ? 1'b1 : 1'b0;
                    expected_out.V = ((expected_in.A[31] != expected_in.B[31]) && (expected_out.result[31] != expected_in.A[31]))? 1'b1 : 1'b0;
                end
                
            end else begin
                expected_out.C = 1'b0;
                expected_out.V = 1'b0;
            end
            
            expected_out.N = (expected_out.result[31] == 1'b1) ? 1'b1 : 1'b0;
            expected_out.Z = (expected_out.result == 32'b0)    ? 1'b1 : 1'b0;
            
            if ((actual_in == expected_in) && (actual_out == expected_out)) begin pass++;
                case (expected_in.alu_op)
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
             
            end else begin fail++;
                $display("ACTUAL: alu_op = %0d : Result = %0d | Z = %0d | V = %0d | N = %0d | C = %0d", 
                          actual_in.alu_op, actual_out.result, actual_out.Z, actual_out.V, actual_out.N, actual_out.C);
                $display("EXP   : alu_op = %0d : Result = %0d | Z = %0d | V = %0d | N = %0d | C = %0d", 
                          expected_in.alu_op, expected_out.result, expected_out.Z, expected_out.V, expected_out.N, expected_out.C);
                
                if (actual_in.A !== expected_in.A)           fail_inA++;
                if (actual_in.B !== expected_in.B)           fail_inB++;
                if (actual_in.alu_op !== expected_in.alu_op) fail_inOP++;
                
                if (actual_out !== expected_out) begin
                    case (expected_in.alu_op)
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
                        default : fail_default++;
                    endcase
                    
                    if (actual_out.result !== expected_out.result) fail_result++;
                    if (actual_out.Z !== expected_out.Z)           fail_z++;
                    if (actual_out.V !== expected_out.V)           fail_v++;
                    if (actual_out.C !== expected_out.C)           fail_c++;
                    if (actual_out.N !== expected_out.N)           fail_n++;
                end
            end
        endtask
    endclass
    
    // Test variables
    Alu_test t;

    initial begin
        $display("Starting ALU randomized testbench...");
        
        // Initialize 
        actual_in    = '{ A : 32'b0, B : 32'b0, alu_op : 4'b0};
        expected_in  = '{ A : 32'b0, B : 32'b0, alu_op : 4'b0};
        actual_out   = '{ result : 32'b0, Z : 1'b0, N : 1'b0, C : 1'b0, V : 1'b0};
        expected_out = '{ result : 32'b0, Z : 1'b0, N : 1'b0, C : 1'b0, V : 1'b0};
        
        repeat (total_tests) begin
            t = new();
            void'(t.randomize());
            @(posedge clk);
            t.apply_inputs(); 
            #1; 
            t.check();
        end

        // If there's any error, "Case covered summary" will not be display until everything is resolve
        if (pass == total_tests) begin
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
            $display("%0d tests failed out of %0d", fail, total_tests);
            if (fail_inA    !== 0) $display("A      : %0d",  fail_inA);
            if (fail_inB    !== 0) $display("B      : %0d",  fail_inB);
            if (fail_inOP   !== 0) $display("OP     : %0d",  fail_inOP);
            if (fail_add    !== 0) $display("ADD    : %0d ", fail_add);
            if (fail_sub    !== 0) $display("SUB    : %0d ", fail_sub);
            if (fail_sll    !== 0) $display("SLL    : %0d ", fail_sll);
            if (fail_slt    !== 0) $display("SLT    : %0d ", fail_slt);
            if (fail_sltu   !== 0) $display("SLTU   : %0d ", fail_sltu);
            if (fail_xor    !== 0) $display("XOR    : %0d ", fail_xor);
            if (fail_srl    !== 0) $display("SRL    : %0d ", fail_srl);
            if (fail_sra    !== 0) $display("SRA    : %0d ", fail_sra);
            if (fail_or     !== 0) $display("OR     : %0d ", fail_or);
            if (fail_and    !== 0) $display("AND    : %0d ", fail_and);
            if (fail_result !== 0) $display("RESULT : %0d ", fail_result);
            if (fail_z      !== 0) $display("Z      : %0d ", fail_z);
            if (fail_v      !== 0) $display("V      : %0d ", fail_v);
            if (fail_n      !== 0) $display("N      : %0d ", fail_n);
            if (fail_c      !== 0) $display("C      : %0d ", fail_c);
        end
       $stop;
    end


endmodule
