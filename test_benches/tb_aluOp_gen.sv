`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/19/2025 09:12:04 AM
// Module Name: tb_aluOp_gen
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module tb_aluOp_gen();
    
    logic clk = 0;
    
    typedef struct packed {
        logic  [6:0] op; // opcode
        logic  [2:0] f3;
        logic  [6:0] f7; 
        logic  [6:0] imm; 
    } aluOp_in;
    
    always #5 clk = ~clk;
    
    aluOp_in    act_in, exp_in;
    logic [3:0] act_out, exp_out;
    
    // Instantiate DUT
    aluOp_gen_s dut (
        .op(act_in.op),                 
        .f3(act_in.f3),          
        .f7(act_in.f7),         
        .imm(act_in.imm),            
        .alu_op(act_out)
    );
    
    int total_tests = 1000000;
    int pass_radd = 0, pass_rsub = 0, pass_rxor = 0, pass_ror = 0, pass_rand = 0;
    int pass_rsll = 0, pass_rsrl = 0, pass_rsra = 0, pass_rslt = 0, pass_rsltu = 0;
    
    int pass_iaddi = 0, pass_ixori = 0, pass_iori = 0, pass_iandi = 0;
    int pass_islli = 0, pass_isrli = 0, pass_israi = 0, pass_islti = 0, pass_isltiu = 0;
    
    int pass_lw = 0, pass_sw = 0, pass_jal = 0, pass = 0;
    int pass_beq = 0, pass_bne = 0, pass_blt = 0, pass_bge = 0, pass_bltu = 0, pass_bgeu = 0;
    
    int fail = 0, fail_r = 0, fail_imm = 0, fail_lw = 0, fail_sw = 0, fail_b = 0, fail_j = 0, fail_default = 0;
    int fail_in = 0, fail_out = 0, fail_op = 0, fail_f3 = 0, fail_f7 = 0, fail_imm = 0;
    
    class aluOp_test;
        rand bit [6:0] r_op, r_f7, r_imm;
        rand bit [2:0] r_f3;
        
        constraint unique_op {
            r_op dist {
                `R_TYPE  := 20, 
                `S_TYPE  := 10,
                `B_TYPE  := 10, 
                `J_JAL   := 10, 
                `I_IMM   := 20, 
                `I_LOAD  := 10,
                `U_LUI   := 10,
                `U_AUIPC := 10
                //[7'b0000000:7'b1111111] := 10  // catch-all random opcodes
            };
        }
        
        constraint unique_f3 {
            r_f3 dist {
                7'd0 := 15, 
                7'd1 := 15,
                7'd2 := 15,
                7'd3 := 15, 
                7'd4 := 10,
                7'd5 := 10,
                7'd6 := 10, 
                7'd7 := 10
            };
        }
        
        constraint unique_f7 {
            r_f7 dist {
                7'd0  := 45, 
                7'h20 := 45,
                7'h11 := 10
            };
        }
        
        constraint unique_imm {
            r_imm dist {
                7'd0  := 45, 
                7'h20 := 45,
                7'h11 := 10
            };
        }
        
        function void apply_input();
            act_in.op   = r_op;
            exp_in.op   = r_op;
            
            case (r_op)
                `S_TYPE  : begin
                    act_in.f3   = 3'b010;
                    act_in.f7   = 7'd0;
                    act_in.imm  = 7'd0;
                    
                    exp_in.f3   = 3'b010;
                    exp_in.f7   = 7'd0;
                    exp_in.imm  = 7'd0;
                end
                
                `B_TYPE  : begin
                    act_in.f7   = 7'd0;
                    act_in.imm  = 7'd0;
                    exp_in.f7   = 7'd0;
                    exp_in.imm  = 7'd0;
                    if (r_f3 == 2'b10 || r_f3 == 2'b11) begin
                        case ($urandom_range(0, 5))
                            0: begin act_in.f3 = 3'b000; exp_in.f3 = 3'b000; end
                            1: begin act_in.f3 = 3'b001; exp_in.f3 = 3'b001; end
                            2: begin act_in.f3 = 3'b100; exp_in.f3 = 3'b100; end
                            3: begin act_in.f3 = 3'b101; exp_in.f3 = 3'b101; end
                            4: begin act_in.f3 = 3'b110; exp_in.f3 = 3'b110; end
                            5: begin act_in.f3 = 3'b111; exp_in.f3 = 3'b111; end
                        endcase
                    end else begin
                        act_in.f3   = r_f3; 
                        exp_in.f3 = r_f3;
                    end
                end
                
                `I_LOAD  : begin
                    act_in.f3   = 3'b010;
                    act_in.f7   = 7'd0;
                    act_in.imm  = 7'd0;
                    
                    exp_in.f3   = 3'b010;
                    exp_in.f7   = 7'd0;
                    exp_in.imm  = 7'd0;
                end
                
                default  : begin
                    act_in.f3   = r_f3;
                    act_in.f7   = r_f7;
                    act_in.imm  = r_imm;
                    
                    exp_in.f3   = r_f3;
                    exp_in.f7   = r_f7;
                    exp_in.imm  = r_imm;
                end
            endcase
        endfunction 
        
        function void expected_output();
            case (exp_in.op)
                `R_TYPE   : begin
                    case (exp_in.f3)
                        `F3_ADD_SUB :begin
                            case (exp_in.f7)
                                `F7_ADD  : exp_out = `ALU_ADD;
                                `F7_SUB  : exp_out = `ALU_SUB;
                                default  : exp_out = `ALU_ADD; // force to 0
                            endcase
                        end
                    
                        `F3_SRL_SRA :begin
                            case (exp_in.f7)
                                `F7_SRL  : exp_out = `ALU_SRL;
                                `F7_SRA  : exp_out = `ALU_SRL;
                                default  : exp_out = `ALU_ADD; // force to 0
                            endcase
                        end
                    
                        `F3_SLT  : exp_out = `ALU_SLT;
                        `F3_SLTU : exp_out = `ALU_SLTU;
                        `F3_XOR  : exp_out = `ALU_XOR;
                        `F3_OR   : exp_out = `ALU_OR;
                        `F3_AND  : exp_out = `ALU_AND;
                        `F3_SLL  : exp_out = `ALU_SLL;
                        default  : exp_out = `ALU_ADD; // force to 0
                        endcase
                end
                
                `I_IMM    : begin
                    case (exp_in.f3)
                        `F3_SRLi_SRAi :begin
                            case (exp_in.imm)
                                `F7_SRLi  : exp_out = `ALU_SRL;
                                `F7_SRAi  : exp_out = `ALU_SRL;
                                default   : exp_out = `ALU_ADD; // force to 0
                            endcase
                        end
                        
                        `F3_ADDi  : exp_out = `ALU_ADD;
                        `F3_SLTi  : exp_out = `ALU_SLT;
                        `F3_SLTiU : exp_out = `ALU_SLTU;
                        `F3_XORi  : exp_out = `ALU_XOR;
                        `F3_ORi   : exp_out = `ALU_OR;
                        `F3_ANDi  : exp_out = `ALU_AND;
                        `F3_SLLi  : exp_out = `ALU_SLL;
                        default   : exp_out = `ALU_ADD; // force to 0
                    endcase
                end
                
                `B_TYPE   : exp_out = `ALU_SUB;
                `U_LUI    : exp_out = `ALU_SLL;
                `U_AUIPC  : exp_out = `ALU_SLL;
                default   : exp_out = `ALU_ADD;
            endcase
        endfunction 
        
         task check();
            #1;
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_ADD_SUB && act_in.f7 == `F7_ADD) pass_radd++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_ADD_SUB && act_in.f7 == `F7_SUB) pass_rsub++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_XOR) pass_rxor++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_OR) pass_ror++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_AND) pass_rand++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_SLL) pass_rsll++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_SRL_SRA && act_in.f7 == `F7_SRL) pass_rsrl++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_SRL_SRA && act_in.f7 == `F7_SRA) pass_rsra++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_SLT) pass_rslt++;
                if (act_in.op == `R_TYPE && act_in.f3 == `F3_SLTU) pass_rsltu++;
                
                if (act_in.op == `I_IMM && act_in.f3 == `F3_ADDi) pass_iaddi++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_XORi) pass_ixori++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_ORi) pass_iori++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_ANDi) pass_iandi++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_SLLi) pass_islli++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_SRLi_SRAi && act_in.imm == `F7_SRLi) pass_isrli++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_SRLi_SRAi && act_in.imm == `F7_SRAi) pass_israi++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_SLTi) pass_islti++;
                if (act_in.op == `I_IMM && act_in.f3 == `F3_SLTiU) pass_isltiu++;
                
                if (act_in.op == `I_LOAD && act_in.f3 == `F3_LW) pass_lw++;
                if (act_in.op == `I_LOAD && act_in.f3 == `F3_SW) pass_sw++;
                if (act_in.op == `J_JAL) pass_jal++;
                
                if (act_in.op == `B_TYPE && act_in.f3 == `BEQ) pass_beq++;
                if (act_in.op == `B_TYPE && act_in.f3 == `BNE) pass_bne++;
                if (act_in.op == `B_TYPE && act_in.f3 == `BLT) pass_blt++;
                if (act_in.op == `B_TYPE && act_in.f3 == `BGE) pass_bge++;
                if (act_in.op == `B_TYPE && act_in.f3 == `BLTU) pass_bltu++;
                if (act_in.op == `B_TYPE && act_in.f3 == `BGEU) pass_bgeu++;
                
            end else begin
                fail++;
                if (act_in === exp_in)
                    fail_in++;
                    if (act_in.op == exp_in.op) fail_op++;
                    if (act_in.f3 == exp_in.f3) fail_f3++;
                    if (act_in.f7 == exp_in.f7) fail_f7++;
                    if (act_in.imm == exp_in.imm) fail_imm++;
                else begin
                    fail_out++;
                    case (act_in.op)
                        `R_TYPE  : fail_r++;
                        `S_TYPE  : fail_sw++;
                        `B_TYPE  : fail_b++;
                        `J_JAL   : fail_j++;
                        `I_IMM   : fail_imm++;
                        `I_LOAD  : fail_lw++;
                        default  : fail_default++;
                    endcase
                end
            end  
        endtask
    endclass
    
    aluOp_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in  = '{default:0};
        exp_in  = act_in;
        exp_out = act_in;

        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            @(posedge clk);
            txn.apply_input();
            txn.expected_output();
            #1;
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" R: ADD    : %d tests passed.", pass_radd);
            $display(" R: SUB    : %d tests passed.", pass_rsub);
            $display(" R: XOR    : %d tests passed.", pass_rxor);
            $display(" R: OR     : %d tests passed.", pass_ror);
            $display(" R: AND    : %d tests passed.", pass_rand);
            $display(" R: SLL    : %d tests passed.", pass_rsll);
            $display(" R: SRL    : %d tests passed.", pass_rsrl);
            $display(" R: SRA    : %d tests passed.", pass_rsra);
            $display(" R: SLT    : %d tests passed.", pass_rslt);
            $display(" R: SLTU   : %d tests passed.", pass_rsltu);
            
            $display(" I: ADDi   : %d tests passed.", pass_iaddi);
            $display(" I: XORi   : %d tests passed.", pass_ixori);
            $display(" I: ORi    : %d tests passed.", pass_iori);
            $display(" I: ANDi   : %d tests passed.", pass_iandi);
            $display(" I: SLLi   : %d tests passed.", pass_islli);
            $display(" I: SRLi   : %d tests passed.", pass_isrli);
            $display(" I: SRAi   : %d tests passed.", pass_israi);
            $display(" I: SLTi   : %d tests passed.", pass_islti);
            $display(" I: SLTiU  : %d tests passed.", pass_isltiu);
            
            $display(" LW        : %d tests passed.", pass_lw);
            $display(" SW        : %d tests passed.", pass_sw);
            $display(" BEQ       : %d tests passed.", pass_beq);
            $display(" BNE       : %d tests passed.", pass_bne);
            $display(" BLT       : %d tests passed.", pass_blt);
            $display(" BGE       : %d tests passed.", pass_bge);
            $display(" BLTU      : %d tests passed.", pass_bltu);
            $display(" BGEU      : %d tests passed.", pass_bgeu);
            
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_in != 0) begin
                if (fail_op != 0) $display(" op mismatch  : %d tests failed.", fail_op);
                if (fail_f3 != 0) $display(" f3 mismatch  : %d tests failed.", fail_f3);
                if (fail_f7 != 0) $display(" f7 mismatch  : %d tests failed.", fail_f7);
                if (fail_imm != 0) $display(" imm mismatch : %d tests failed.", fail_imm);
            end else if (fail_out != 0) begin 
                $display(" output mismatch : %d tests failed.", fail_out);
            end
        end
        $stop;
    end

endmodule
