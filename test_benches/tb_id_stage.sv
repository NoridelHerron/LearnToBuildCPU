`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/20/2025 10:01:17 AM
// Module Name: tb_id_stage
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"
`include "functions_pkg.sv"
`include "struct_pkg.sv"

module tb_id_stage();

    import functions_pkg::*;
    import struct_pkg::*;
    
    logic clk = 0;
    
    always #5 clk = ~clk;
    logic [95:0] data_out;
    logic [11:0] imm;
    logic [4:0]  cntrl, haz;
    logic [31:0] readData1, readData2;
    logic [31:0] golden_regs[0:31];
    rd_write     act_memwb, exp_memwb;
    rd_write     act_exmem, exp_exmem;
    idex_t       act_idex, exp_idex;
    id_out       act_out, exp_out;
    logic [31:0] instr;
    id_in        act_in, exp_in;
    
    
    // Instantiate DUT
    id_v uut(
    .clk(clk),
    .instruction(act_in.instr),                  
    .idex_rs1(act_in.idex_rs1),             .idex_rs2(act_in.idex_rs2), 
    .idex_rd(act_in.idex_rd),               .idex_memRead(act_in.idex_memRead), 
    .exmem_regWrite(act_in.exmem_regWrite), .exmem_rd(act_in.exmem_rd),
    .memwb_regWrite(act_in.memwb_regWrite), .memwb_rd(act_in.memwb_rd),
    .wb_data(act_in.wb_data),
    // outputs
    .op(act_out.op),                .rd(act_out.rd), 
    .rs1(act_out.rs1),              .rs2(act_out.rs2),  
    .mem_read(act_out.memRead),     .mem_write(act_out.memWrite),    
    .reg_write(act_out.regWrite),   .jump(act_out.jump), 
    .branch(act_out.branch),        .alu_op(act_out.alu_op),  
    .forwA(act_out.forwA),          .forwB(act_out.forwB),       
    .stall(act_out.stall),          .operand1(act_out.operand1),  
    .operand2(act_out.operand2),    .s_data(act_out.s_data)
    );
   
    
    int total_tests = 1000000;
    int pass = 0, pass_r = 0, pass_i = 0, pass_l = 0, pass_s = 0, pass_b = 0;
    int fail = 0, fail_r = 0, fail_i = 0, fail_l = 0, fail_s = 0, fail_b = 0;
    int fail_input = 0, fail_output = 0;
    int fail_instr = 0,    fail_idex_rs1 = 0, fail_idex_rs2 = 0, fail_idex_rd = 0,  fail_idex_mR = 0;
    int fail_exmem_rW = 0, fail_exmem_rd = 0, fail_memwb_rW = 0, fail_memwb_rd = 0, fail_wb_data = 0;
    int fail_op = 0,       fail_rd = 0,       fail_mR = 0,       fail_mW = 0,       fail_rW = 0;
    int fail_jump = 0,     fail_branch = 0,   fail_aluOp = 0,    fail_fA = 0,       fail_fB = 0;
    int fail_st = 0,       fail_oper1 = 0,    fail_oper2 = 0,    fail_sD = 0;
    
    class id_test;
        rand bit [6:0]  op;
        rand bit [4:0]  rd;
        rand bit [2:0]  f3, bf3; 
        rand bit [4:0]  rs1;
        rand bit [4:0]  rs2;
        rand bit [6:0]  rf7, if7, f7;
        rand bit [11:0] immI, immL, immSB;
        rand bit [31:0] data;
        
        constraint unique_op {
            op dist {
                `R_TYPE  := 20, 
                `S_TYPE  := 20,
                `B_TYPE  := 20, 
               // `J_JAL   := 15, 
                `I_IMM   := 20, 
                `I_LOAD  := 20
            };
        }
        
        constraint unique_f3 {
            f3 dist {
                3'd0  := 15, 3'd1  := 15, 
                3'd2  := 15, 3'd3  := 15, 
                3'd4  := 10, 3'd5  := 10,
                3'd6  := 10, 3'd7  := 10
            };
        }
        
        constraint unique_bf3 {
            bf3 dist {
                3'd0  := 20, 3'd3  := 20, 
                3'd4  := 15, 3'd5  := 15,
                3'd6  := 15, 3'd7  := 15
            };
        }
        
        // r_type
        constraint unique_rf7 {
            (f3 == 3'b000 || f3 == 3'b101) -> 
                (rf7 inside {7'd0, 7'd32, 7'd24});
        }
        
        // i_type
        constraint unique_if7 {
            if (f3 == 3'b101)
                if7 == 7'd32;
            else
                if7 == 7'd0;
        }
        
        function void apply_inputs();
            immI       = {if7, rs2};
            immI[1:0]  = 2'b00;
            immI       = {{20{immI[11]}}, immI};
            immL       = {f7, rs2};
            immL[1:0]  = 2'b00;
            immL       = {{20{immL[11]}}, immL};
            immSB      = {f7, rd};
            immSB[1:0] = 2'b00;
            immSB      = {{20{immSB[11]}}, immSB};
            case(op)
                `R_TYPE  : instr = {rf7, rs2, rs1, f3, rd, op};
                `S_TYPE  : instr = {immSB[11:5], rs2, rs1, 3'd2, immSB[4:0], op};
                `B_TYPE  : instr = {immSB[11:5], rs2, rs1, bf3, immSB[4:0], op};
                `I_IMM   : instr = {immI[11:5], immI[4:0], rs1, f3, rd, op};
                `I_LOAD  : instr = {immL[11:5], immL[4:0], rs1, 3'd2, rd, op};
                default  : instr = {rf7, rs2, rs1, f3, rd, op};
            endcase 
            
            act_in.instr            = instr;
            act_in.idex_rd         = act_idex.rd;
            act_in.idex_rs1        = act_idex.rs1;
            act_in.idex_rs2        = act_idex.rs2;
            act_in.idex_regWrite   = act_idex.regWrite;
            act_in.idex_memRead    = act_idex.memRead;
            
            act_in.exmem_rd        = act_exmem.rd;
            act_in.exmem_regWrite  = act_exmem.regWrite;
            act_in.memwb_rd        = act_memwb.rd; 
            act_in.memwb_regWrite  = act_memwb.regWrite;
            act_in.wb_data         = data;
            
            exp_in.instr           = instr;
            exp_in.idex_rd         = act_idex.rd;
            exp_in.idex_rs1        = act_idex.rs1;
            exp_in.idex_rs2        = act_idex.rs2;
            exp_in.idex_regWrite   = act_idex.regWrite;
            exp_in.idex_memRead    = act_idex.memRead;
            exp_in.exmem_rd        = exp_exmem.rd;
            exp_in.exmem_regWrite  = exp_exmem.regWrite;
            exp_in.memwb_rd        = exp_memwb.rd; 
            exp_in.memwb_regWrite  = exp_memwb.regWrite;
            exp_in.wb_data         = data;
        endfunction
        
        function void expected_outputs();
            exp_in.instr = instr;
            exp_out.op   = exp_in.instr[6:0];
            case (exp_in.instr[6:0])
                `R_TYPE  : begin
                    exp_out.rd   = exp_in.instr[11:7];
                    exp_out.rs1  = exp_in.instr[19:15];
                    exp_out.rs2  = exp_in.instr[24:20];
                end
                
                `S_TYPE, `B_TYPE  : begin
                    exp_out.rd   = 5'd0;
                    exp_out.rs1  = exp_in.instr[19:15];
                    exp_out.rs2  = exp_in.instr[24:20];
                end
               
                `I_IMM, `I_LOAD  : begin
                    exp_out.rd   = exp_in.instr[11:7];
                    exp_out.rs1  = exp_in.instr[19:15];
                    exp_out.rs2  = 5'd0;
                end
                
                default  : instr = '{default:0};
            endcase
            
            cntrl = get_expected_controls(exp_in.instr[6:0]);
            
            exp_out.memRead   = cntrl[4];
            exp_out.memWrite  = cntrl[3];
            exp_out.regWrite  = cntrl[2];
            exp_out.jump      = cntrl[1];
            exp_out.branch    = cntrl[0];
            
            exp_out.alu_op = set_alu_op( exp_in.instr[6:0], exp_in.instr[14:12], exp_in.instr[31:25]);
            
            haz = set_expected_hazard( exp_out.rs1,           exp_out.rs2,           exp_in.idex_memRead, 
                                       exp_in.exmem_regWrite, exp_in.memwb_regWrite, exp_in.idex_rs1, 
                                       exp_in.idex_rs2,       exp_in.idex_rd,        exp_in.exmem_rd, 
                                       exp_in.memwb_rd );
            
            exp_out.forwA  = haz[4:3];
            exp_out.forwB  = haz[2:1];
            exp_out.stall  = haz[0];
            
            readData1 = (exp_in.instr[19:15] == 0) ? 32'b0 : golden_regs[exp_in.instr[19:15]];
            readData2 = (exp_in.instr[24:20] == 0) ? 32'b0 : golden_regs[exp_in.instr[24:20]];
            
            // Update reference model on posedge clk
            if (exp_in.memwb_regWrite && exp_in.memwb_rd != 0)
                golden_regs[exp_in.memwb_rd] = exp_in.wb_data;
                
            case (exp_in.instr[6:0])
                `S_TYPE, `B_TYPE  : imm = immSB;
                `R_TYPE  : imm = 12'd0;
                `I_IMM   : imm = immI;
                `I_LOAD  : imm = immL;
                default  : imm = 12'd0;
            endcase
             
            data_out = get_operand_sdata( readData1, readData2, imm, exp_in.instr[6:0]);
            exp_out.operand1 = data_out[95:64];
            exp_out.operand2 = data_out[63:32]; 
            exp_out.s_data   = data_out[31:0];
        endfunction
        
        task check();
            #1;
            if (act_in === exp_in && act_out === exp_out) begin
                pass++;
                case (exp_in.instr[6:0])
                    `S_TYPE  : pass_s++;
                    `B_TYPE  : pass_b++;
                    `R_TYPE  : pass_r++;
                    `I_IMM   : pass_i++;
                    `I_LOAD  : pass_l++;
                    default  : ;
                endcase
                
            end else begin
                case (exp_in.instr[6:0])
                    `S_TYPE  : fail_s++;
                    `B_TYPE  : fail_b++;
                    `R_TYPE  : fail_r++;
                    `I_IMM   : fail_i++;
                    `I_LOAD  : fail_l++;
                    default  : ;
                endcase
                
                if (act_in !== exp_in) begin
                    fail_input++;
                    if (act_in.instr != exp_in.instr) fail_instr++;
                    if (act_in.idex_rs1 != exp_in.idex_rs1) fail_idex_rs1++;
                    if (act_in.idex_rs2 != exp_in.idex_rs2) fail_idex_rs2++;
                    if (act_in.idex_rd != exp_in.idex_rd) fail_idex_rd++;
                    if (act_in.idex_memRead != exp_in.idex_memRead) fail_idex_mR++;
                    if (act_in.exmem_regWrite != exp_in.exmem_regWrite) fail_exmem_rW++;
                    if (act_in.exmem_rd != exp_in.exmem_rd) fail_exmem_rd++;
                    if (act_in.memwb_regWrite != exp_in.memwb_regWrite) fail_memwb_rW++;
                    if (act_in.memwb_rd != exp_in.memwb_rd) fail_memwb_rd++;
                    if (act_in.wb_data != exp_in.wb_data) fail_wb_data++;
                    
                end else begin
                    fail_output++;
                    if (act_out.op != exp_out.op) fail_op++;
                    if (act_out.rd != exp_out.rd) fail_rd++;
                    if (act_out.memRead != exp_out.memRead) fail_mR++;
                    if (act_out.memWrite != exp_out.memWrite) fail_mW++;
                    if (act_out.regWrite != exp_out.regWrite) fail_rW++;
                    if (act_out.jump != exp_out.jump) fail_jump++;
                    if (act_out.branch != exp_out.branch) fail_branch++;
                    if (act_out.alu_op != exp_out.alu_op) fail_aluOp++;
                    if (act_out.forwA != exp_out.forwA) fail_fA++;
                    if (act_out.forwB != exp_out.forwB) fail_fB++;
                    if (act_out.stall != exp_out.stall) fail_st++;
                    if (act_out.operand1 != exp_out.operand1) fail_oper1++;
                    if (act_out.operand2 != exp_out.operand2) fail_oper2++;
                    if (act_out.s_data != exp_out.s_data) fail_sD++;
                end
            end  
        endtask
    endclass
    
    id_test txn;
    // Test logic
    initial begin
        $display("Starting SystemVerilog randomized testbench...");
        
        // Initialize signals to known values
        act_in      = '{default:0};
        exp_in      = '{default:0};
        exp_out     = '{default:0};
        act_idex    = '{default:0};
        exp_idex    = '{default:0};
        act_exmem   = '{default:0};
        exp_exmem   = '{default:0};
        act_memwb   = '{default:0};
        exp_memwb   = '{default:0};
        golden_regs = '{default:0};


        repeat (total_tests) begin
            txn = new();
            void'(txn.randomize());
            
            @(posedge clk);
            txn.apply_inputs();
            act_idex.rs1       <= act_out.rs1;
            act_idex.rs2       <= act_out.rs2;
            act_idex.rd        <= act_out.rd;
            act_idex.memRead   <= act_out.memRead;
            act_idex.regWrite  <= act_out.regWrite;
            
            act_exmem.rd       <= act_idex.rd;
            act_exmem.regWrite <= act_idex.regWrite;
            
            act_memwb.rd       <= act_exmem.rd;
            act_memwb.regWrite <= act_exmem.regWrite;
            
            exp_idex.rs1       <= exp_out.rs1;
            exp_idex.rs2       <= exp_out.rs2;
            exp_idex.rd        <= exp_out.rd;
            exp_idex.memRead   <= exp_out.memRead;
            exp_idex.regWrite  <= exp_out.regWrite;
            
            exp_exmem.rd       <= exp_idex.rd;
            exp_exmem.regWrite <= exp_idex.regWrite;
            
            exp_memwb.rd       <= exp_exmem.rd;
            exp_memwb.regWrite <= exp_exmem.regWrite;
         
            txn.expected_outputs();
            txn.check();
        end

        if (pass == total_tests) begin
            $display(" All %d tests passed.", total_tests);
            $display(" R  : %d tests passed.", pass_r);
            $display(" I  : %d tests passed.", pass_i);
            $display(" S  : %d tests passed.", pass_s);
            $display(" B  : %d tests passed.", pass_b);
            $display(" L  : %d tests passed.", pass_l);
        end else begin
            $display(" %d out of %d tests failed.", fail, total_tests);
            if (fail_s != 0) $display("S failed = %d", fail_s);
            if (fail_b != 0) $display("B failed = %d", fail_b);
            if (fail_r != 0) $display("R failed = %d", fail_r);
            if (fail_i != 0) $display("I failed = %d", fail_i);
            if (fail_l != 0) $display("L failed = %d", fail_l);
            if (fail_input != 0) begin
                $display("inputs failed = %d", fail_input);
                if (fail_instr != 0)     $display("instr failed    = %d", fail_instr);
                if (fail_idex_rs1 != 0)  $display("idex_rs1 failed = %d", fail_idex_rs1);
                if (fail_idex_rs2 != 0)  $display("idex_rs2 failed = %d", fail_idex_rs2);
                if (fail_idex_rd != 0)   $display("idex_rd failed  = %d", fail_idex_rd);
                if (fail_idex_mR != 0)   $display("idex_mR failed  = %d", fail_idex_mR);
                if (fail_exmem_rW != 0)  $display("exmem_rW failed = %d", fail_exmem_rW);
                if (fail_exmem_rd != 0)  $display("exmem_rd failed = %d", fail_exmem_rd);
                if (fail_memwb_rW != 0)  $display("memwb_rW failed = %d", fail_memwb_rW);
                if (fail_memwb_rd != 0)  $display("memwb_rd failed = %d", fail_memwb_rd);
                if (fail_wb_data != 0)   $display("wb_data failed  = %d", fail_wb_data);
                
            end else begin
                $display("outputs failed = %d", fail_output);
                if (fail_op != 0)     $display("OP     failed = %d", fail_op);
                if (fail_rd != 0)     $display("RD     failed = %d", fail_rd);
                if (fail_mR != 0)     $display("MR     failed = %d", fail_mR);
                if (fail_mW != 0)     $display("MW     failed = %d", fail_mW);
                if (fail_rW != 0)     $display("RW     failed = %d", fail_rW);
                if (fail_jump != 0)   $display("cJ     failed = %d", fail_jump);
                if (fail_branch != 0) $display("cB     failed = %d", fail_branch);
                if (fail_aluOp != 0)  $display("Alu_op failed = %d", fail_aluOp);
                if (fail_fA != 0)     $display("forwA  failed = %d", fail_fA);
                if (fail_fB != 0)     $display("forwB  failed = %d", fail_fB);
                if (fail_st != 0)     $display("stall  failed = %d", fail_st);
                if (fail_oper1 != 0)  $display("oper1  failed = %d", fail_oper1);
                if (fail_oper2 != 0)  $display("oper2  failed = %d", fail_oper2);
                if (fail_sD != 0)     $display("Sdata  failed = %d", fail_sD); 
            end
        end
        $stop;
    end
endmodule
