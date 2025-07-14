// Noridel Herron
// Additional testbench and practice testbench in system verilog
`timescale 1ns / 1ps

module tb_decoder( );
    
    logic clk = 0;
    always #5 clk = ~clk; // Clock: 10ns period

    localparam logic [6:0] R_TYPE  = 7'b0110011;
    localparam logic [6:0] S_TYPE  = 7'b0100011;
    localparam logic [6:0] B_TYPE  = 7'b1100011;
    localparam logic [6:0] JAL     = 7'b1101111;
    localparam logic [6:0] IMM     = 7'b0010011;
    localparam logic [6:0] LOAD    = 7'b0000011;
    localparam logic [6:0] ECALL   = 7'b1110111;
    localparam logic [6:0] JALR    = 7'b1100111;
    localparam logic [6:0] U_LUI   = 7'b0110111;
    localparam logic [6:0] U_AUIPC = 7'b0010111;

    typedef struct packed {
        logic [6:0]  op;
        logic [4:0]  rd;
        logic [2:0]  f3;
        logic [4:0]  rs1;
        logic [4:0]  rs2;
        logic [6:0]  f7;
        logic [11:0] imm12;
        logic [19:0] imm20;
    } decoded_t;
    
    logic [31:0] instr;
    decoded_t    actual, expected;
    
    // Instantiate DUT
    decoder_v dut (
        .ID(instr),
        // outputs
        .op(actual.op),
        .rd(actual.rd),
        .funct3(actual.f3),
        .rs1(actual.rs1),
        .rs2(actual.rs2),
        .funct7(actual.f7),
        .imm12(actual.imm12),
        .imm20(actual.imm20)
    );
    
    int total_tests = 100000;
    // Keep track all the test and make sure it covers all the cases
    int pass = 0, fail = 0; 
    // Keep track if all cases are covered including invalid cases
    int pr = 0, pi = 0, pl = 0, ps = 0, pj = 0, pb = 0, pd = 0;
    int pe = 0, pul = 0, pua = 0, pjr = 0;
    // Narrow down bugs
    int fop = 0, frd = 0, ff3 = 0, frs1 = 0, frs2 = 0, ff7 = 0, fimm12 = 0, fimm20 = 0;
    
    class ID;
        rand bit [6:0]  rand_op;
        rand bit [4:0]  rand_rd;
        rand bit [2:0]  rand_f3; 
        rand bit [4:0]  rand_rs1;
        rand bit [4:0]  rand_rs2;
        rand bit [6:0]  rand_f7;
        
        constraint unique_op {
            rand_op dist {
                R_TYPE  := 25, 
                S_TYPE  := 10,
                B_TYPE  := 10, 
                JAL     := 10, 
                IMM     := 15, 
                LOAD    := 10,
                JALR    := 5,
                ECALL   := 5,
                U_LUI   := 5,
                U_AUIPC := 5
                // remove the comment to catch all edge cases
                //[7'b0000000:7'b1111111] := 5  // catch-all random opcodes
            };
        }
        /*
        constraint f7_condition {
            if (rand_f3 == 3'b000 || rand_f3 == 3'b101) {
                rand_f7 inside {7'd0, 7'd32};
            } else {
                rand_f7 == 7'd0;
            }
        }
        */
        function void apply_inputs();
            instr = {rand_f7, rand_rs2, rand_rs1, rand_f3, rand_rd, rand_op};   
        endfunction
        
        task check();
            // EXPECTED OUTPUT
            case(rand_op)
                R_TYPE  : expected = '{op : instr[6:0], rd : instr[11:7], f3 : instr[14:12], rs1 : instr[19:15], rs2 : instr[24:20], f7 : instr[31:25], imm12 : 12'b0, imm20 : 20'b0}; 
                S_TYPE  : expected = '{op : instr[6:0], rd : 5'b0, f3 : instr[14:12], rs1 : instr[19:15], rs2 : instr[24:20], f7 : 5'b0, imm12 : {instr[31:25], instr[11:7]}, imm20 : 20'b0}; 
                B_TYPE  : expected = '{op : instr[6:0], rd : 5'b0, f3 : instr[14:12], rs1 : instr[19:15], rs2 : instr[24:20], f7 : 5'b0, imm12 : {instr[31], instr[7], instr[30:25], instr[11:8]}, imm20 : 20'b0}; 
                JAL     : expected = '{op : instr[6:0], rd : instr[11:7], f3 : 5'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : {instr[31], instr[19:12], instr[20], instr[30:21]}}; 
                JALR    : expected = '{op : instr[6:0], rd : instr[11:7], f3 : instr[14:12], rs1 : instr[19:15], rs2 : 5'b0, f7 : 7'b0, imm12 : instr[31:20], imm20 : 20'b0}; 
                IMM     : expected = '{op : instr[6:0], rd : instr[11:7], f3 : instr[14:12], rs1 : instr[19:15], rs2 : 5'b0, f7 : 7'b0, imm12 : instr[31:20], imm20 : 20'b0};  
                LOAD    : expected = '{op : instr[6:0], rd : instr[11:7], f3 : instr[14:12], rs1 : instr[19:15], rs2 : 5'b0, f7 : 7'b0, imm12 : instr[31:20], imm20 : 20'b0}; 
                ECALL   : expected = '{op : instr[6:0], rd : instr[11:7], f3 : instr[14:12], rs1 : instr[19:15], rs2 : 5'b0, f7 : 7'b0, imm12 : instr[31:20], imm20 : 20'b0}; 
                U_LUI   : expected = '{op : instr[6:0], rd : instr[11:7], f3 : 5'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : instr[31:12]}; 
                U_AUIPC : expected = '{op : instr[6:0], rd : instr[11:7], f3 : 5'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : instr[31:12]}; 
                default : expected = '{op : 7'b0, rd : 5'b0, f3 : 3'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : 20'b0}; 
            endcase 
            
            if (actual === expected) begin
                pass++;
                case(rand_op)
                    R_TYPE  : pr++; 
                    S_TYPE  : ps++; 
                    B_TYPE  : pb++; 
                    JAL     : pj++; 
                    IMM     : pi++;  
                    LOAD    : pl++;
                    JALR    : pjr++; 
                    ECALL   : pe++; 
                    U_LUI   : pul++; 
                    U_AUIPC : pua++; 
                    default : pd++; 
                endcase 
            end else begin 
                // NARROW DOWN BUGS  
                $display("actual.op = %0d : expected.op = %0d ", actual.op, expected.op);
                if (actual.op    !== expected.op)    fop++;
                if (actual.rd    !== expected.rd)    frd++;
                if (actual.f3    !== expected.f3)    ff3++;
                if (actual.rs1   !== expected.rs1)   frs1++;
                if (actual.rs2   !== expected.rs2)   frs2++;
                if (actual.f7    !== expected.f7) begin
                    ff7++;    
                    $display("actual.f7 = %0d : expected.f7 = %0d ", actual.f7, expected.f7);
                end
                if (actual.imm12 !== expected.imm12) begin
                    fimm12++;
                    $display("actual.imm12 = %0d : expected.imm12 = %0d ", actual.imm12, expected.imm12);
                end
                if (actual.imm20 !== expected.imm20) begin
                    fimm20++;
                    $display("actual.imm20 = %0d : expected.imm20 = %0d ", actual.imm20, expected.imm20);
                end
            end
        endtask 
    endclass
    
    ID t;
    initial begin
        $display("Starting DECODER randomized testbench...");
        
        instr     = 32'b0;
        actual    = '{op : 7'b0, rd : 5'b0, f3 : 3'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : 20'b0}; 
        expected  = '{op : 7'b0, rd : 5'b0, f3 : 3'b0, rs1 : 5'b0, rs2 : 5'b0, f7 : 7'b0, imm12 : 12'b0, imm20 : 20'b0}; 
        
        repeat (total_tests) begin
            t = new();
            void'(t.randomize());
            @(posedge clk);
            t.apply_inputs();  
            @(posedge clk); // Have to update on rising edge to ensure that we compare the correct values
            t.check();
        end

        // If there's any error, "Case covered summary" will not be display until everything is resolve
        if (pass == total_tests) begin
            $display("All %0d tests passed!", pass);
            $display("Case Covered Summary!!!");
            $display("R_TYPE        : %0d ", pr);
            $display("S_TYPE        : %0d ", ps);
            $display("B_TYPE        : %0d ", pb);
            $display("IMM           : %0d ", pi);
            $display("LOAD          : %0d ", pl);
            $display("JAL           : %0d ", pj);
            $display("U_LUI         : %0d ", pul);
            $display("U_AUIPC       : %0d ", pua);
            $display("ECALL         : %0d ", pe);
            $display("JALR          : %0d ", pjr);
            $display("INVALID_CASES : %0d ", pd);

        end else begin
            $display("%0d tests failed out of %0d", fail, total_tests);
            if (fop    !== 0) $display("OP    : %0d",  fop);
            if (frd    !== 0) $display("RD    : %0d",  frd);
            if (ff3    !== 0) $display("F3    : %0d",  ff3);
            if (frs1   !== 0) $display("RS1   : %0d",  frs1);
            if (frs2   !== 0) $display("RS2   : %0d ", frs2);
            if (ff7    !== 0) $display("F7    : %0d ", ff7);
            if (fimm12 !== 0) $display("imm12 : %0d ", fimm12);
            if (fimm20 !== 0) $display("imm20 : %0d ", fimm20);
        end
       $stop;
    end
endmodule
