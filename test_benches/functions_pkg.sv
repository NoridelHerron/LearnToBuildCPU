
`include "constant_def.vh"
`include "struct_pkg.sv"

package functions_pkg;
    import struct_pkg::*;

    function automatic bit [4:0] get_expected_controls(input bit [6:0] opcode);
    bit [4:0] exp_out = 5'd0;

        case (opcode)
            `R_TYPE, `I_IMM, `U_LUI, `U_AUIPC: exp_out[2] = 1'b1;
            `S_TYPE : exp_out[3] = 1'b1;
            `B_TYPE : exp_out[0] = 1'b1;
            `I_LOAD : begin
                exp_out[4] = 1'b1;
                exp_out[2] = 1'b1;
            end
            default: ;
        endcase
    
        return exp_out;
    endfunction

    
    function automatic bit [3:0] set_alu_op(
        input  bit [6:0] opcode, f3, f7
    );
        bit [3:0] exp_out = 5'd0;

        case (opcode)
            `R_TYPE   : begin
                case (f3)
                    `F3_ADD_SUB :begin
                        case (f7)
                            `F7_ADD  : exp_out = `ALU_ADD;
                            `F7_SUB  : exp_out = `ALU_SUB;
                            default  : exp_out = `ALU_ADD; // force to 0
                        endcase
                    end
                
                    `F3_SRL_SRA :begin
                        case (f7)
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
                case (f3)
                    `F3_SRLi_SRAi :begin
                        case (f7)
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
            //`U_LUI    : exp_out = `ALU_SLL;
            //`U_AUIPC  : exp_out = `ALU_SLL;
            default   : exp_out = `ALU_ADD;
        endcase
        return exp_out;
    endfunction
    
    function automatic bit [4:0] set_expected_hazard( 
        input  bit [4:0] id_rs1, id_rs2, 
        input  bit       idex_memRead, exmem_regWrite, memwb_regWrite,
        input  bit [4:0] idex_rs1, idex_rs2, idex_rd,
        input  bit [4:0] exmem_rd, memwb_rd
    );
    
    bit [4:0] exp_out = 5'd0;
        if (exmem_regWrite && exmem_rd != 5'd0 && exmem_rd == idex_rs1)
            exp_out[4:3] = 2'b01;
        else if (memwb_regWrite && memwb_rd != 5'd0 && memwb_rd == idex_rs1)
            exp_out[4:3] = 2'b10;
        else
            exp_out[4:3] = 2'b00;
             
        if (exmem_regWrite && exmem_rd != 5'd0 && exmem_rd == idex_rs2)
            exp_out[2:1] = 2'b01;
        else if (memwb_regWrite && memwb_rd != 5'd0 && memwb_rd == idex_rs2)
            exp_out[2:1] = 2'b10;
        else
             exp_out[2:1] = 2'b00;
             
        if (idex_memRead && (idex_rd == id_rs1 || idex_rd == id_rs2) && idex_rd != 5'd0) 
            exp_out[0] = 1'b1; 
        else
            exp_out[0] = 1'b0;  
            
        return exp_out;
                   
    endfunction 
    
    function automatic bit [95:0] get_operand_sdata( 
        input  bit [31:0] data1, data2,
        input  bit [11:0] imm,
        input  bit [6:0]  op
    );
        bit [95:0] exp_out = 5'd0;
        
        case (op)
            `R_TYPE, `B_TYPE  : begin
                exp_out[95:64] = data1;
                exp_out[63:32] = data2;
                exp_out[31:0]  = 32'd0;
             end
             
            `S_TYPE  : begin
                exp_out[95:64] = data1;
                exp_out[63:32] = {{20{imm[11]}}, imm};
                exp_out[31:0]  = data2;
             end

            `I_LOAD, `I_IMM : begin
                exp_out[95:64] = data1;
                exp_out[63:32] = {{20{imm[11]}}, imm};
                exp_out[31:0]  = 32'd0;
             end

            default: begin
                exp_out[95:64] = 32'd0;
                exp_out[63:32] = 32'd0;
                exp_out[31:0]  = 32'd0;
             end
        endcase
        return exp_out;
    endfunction 
    
    function automatic alu_out Get_expected_aluResult(input alu_in x);
    alu_out expected_out = '{default:0};

        case (x.alu_op)
                `ALU_ADD:  expected_out.result = x.A + x.B;
                `ALU_SUB:  expected_out.result = x.A - x.B;
                `ALU_XOR:  expected_out.result = x.A ^ x.B;
                `ALU_OR:   expected_out.result = x.A | x.B;
                `ALU_AND:  expected_out.result = x.A & x.B;
                `ALU_SLL:  expected_out.result = x.A << x.B[4:0];
                `ALU_SRL:  expected_out.result = x.A >> x.B[4:0];
                `ALU_SRA:  expected_out.result = $signed(x.A) >>> x.B[4:0];
                `ALU_SLT:  expected_out.result = ($signed(x.A) < $signed(x.B)) ? 32'b1 : 32'b0;
                `ALU_SLTU: expected_out.result = (x.A < x.B) ? 32'b1 : 32'b0;
                default:   expected_out.result = 32'b0;
            endcase
            
            if (x.alu_op == `ALU_ADD || x.alu_op == `ALU_SUB) begin
                if (x.alu_op == `ALU_ADD) begin
                    expected_out.C = (expected_out.result < x.A || expected_out.result < x.B) ? 1'b1 : 1'b0;
                    expected_out.V = ((x.A[31] == x.B[31]) && (expected_out.result[31] != x.A[31]))? 1'b1 : 1'b0;
                    
                end else begin
                    expected_out.C = (x.A >= x.B) ? 1'b1 : 1'b0;
                    expected_out.V = ((x.A[31] != x.B[31]) && (expected_out.result[31] != x.A[31]))? 1'b1 : 1'b0;
                end
                
            end else begin
                expected_out.C = 1'b0;
                expected_out.V = 1'b0;
            end
            
            expected_out.N = (expected_out.result[31] == 1'b1) ? 1'b1 : 1'b0;
            expected_out.Z = (expected_out.result == 32'b0)    ? 1'b1 : 1'b0;
    
        return expected_out;
    endfunction

endpackage