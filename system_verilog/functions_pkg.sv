
`include "constant_def.svh"
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
        bit [95:0] exp_out = 96'd0;
        
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
    
    function automatic bit [35:0] Get_expected_aluResult(
        input  bit [31:0] operand1, operand2, 
        input  bit [3:0]  aluOp );
    bit [35:0] exp_out = 36'd0;

        case (aluOp)
                `ALU_ADD:  exp_out[31:0] = operand1 + operand2;
                `ALU_SUB:  exp_out[31:0] = operand1 - operand2;
                `ALU_XOR:  exp_out[31:0] = operand1 ^ operand2;
                `ALU_OR:   exp_out[31:0] = operand1 | operand2;
                `ALU_AND:  exp_out[31:0] = operand1 & operand2;
                `ALU_SLL:  exp_out[31:0] = operand1 << operand2[4:0];
                `ALU_SRL:  exp_out[31:0] = operand1 >> operand2[4:0];
                `ALU_SRA:  exp_out[31:0] = $signed(operand1) >>> operand2[4:0];
                `ALU_SLT:  exp_out[31:0] = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
                `ALU_SLTU: exp_out[31:0] = (operand1 < operand2) ? 32'b1 : 32'b0;
                default:   exp_out[31:0] = 32'b0;
            endcase
            
            if (aluOp == `ALU_ADD || aluOp == `ALU_SUB) begin
                if (aluOp == `ALU_ADD) begin
                    exp_out[32] = (exp_out[31:0] < operand1 || exp_out[31:0] < operand2) ? 1'b1 : 1'b0;
                    exp_out[33] = ((operand1[31] == operand2[31]) && (exp_out[31] != operand1[31]))? 1'b1 : 1'b0;
                    
                end else begin
                    exp_out[32] = (operand1 >= operand2) ? 1'b1 : 1'b0;
                    exp_out[33] = ((operand1[31] != operand2[31]) && (exp_out[31] != operand1[31]))? 1'b1 : 1'b0;
                end
                
            end else begin
                exp_out[32] = 1'b0;
                exp_out[33] = 1'b0;
            end
            
            exp_out[34] = (exp_out[31]   == 1'b1)  ? 1'b1 : 1'b0;
            exp_out[35] = (exp_out[31:0] == 32'b0) ? 1'b1 : 1'b0;
    
        return exp_out;
    endfunction
    
    function automatic bit [95:0] Get_expected_forw(
    input  bit [31:0] isForw_ON,
    input  bit [6:0]  op,
    input  bit [31:0] exmem,
    input  bit [31:0] memwb, 
    input  bit [1:0]  forwA, forwB,
    input  bit [31:0] data1, data2, s_data );
    bit [95:0] exp_out = 96'd0;
    
        if (isForw_ON) begin
            case (forwA)
                2'b00   : exp_out[95:64] = data1;
                2'b01   : exp_out[95:64] = exmem;
                2'b10   : exp_out[95:64] = memwb;
                default : exp_out[95:64] = 32'd0;
            endcase
        
            case (forwB)
                2'b00   : begin 
                    exp_out[63:32] = data2;
                    exp_out[31:0]  = s_data;
                end
                
                2'b01   : begin
                    case (op)
                        `R_TYPE : begin
                            exp_out[63:32] = exmem;
                            exp_out[31:0]  = s_data;
                        end
                        
                        `I_IMM, `I_LOAD : begin
                            exp_out[63:32] = data2;
                            exp_out[31:0]  = s_data;
                        end
                        
                        `S_TYPE : begin
                            exp_out[63:32] = data2;
                            exp_out[31:0]  = exmem;
                        end
                        
                        default  : begin
                            exp_out[63:32] = 32'd0;
                            exp_out[31:0]  = 32'd0;
                        end     
                    endcase
                end
                
                2'b10   : begin 
                    case (op)
                        `R_TYPE : begin
                            exp_out[63:32] = memwb;
                            exp_out[31:0]  = s_data;
                        end
                        
                        `I_IMM, `I_LOAD : begin
                            exp_out[63:32] = data2;
                            exp_out[31:0]  = s_data;
                        end
                        
                        `S_TYPE : begin
                            exp_out[63:32] = data2;
                            exp_out[31:0]  = memwb;
                        end                       
                        
                        default  : begin
                            exp_out[63:32] = 32'd0;
                            exp_out[31:0]  = 32'd0;
                        end     
                    endcase
                end
                
                default : begin
                    exp_out[63:32] = 32'd0;
                    exp_out[31:0]  = 32'd0;
                end
            endcase
        
        end else begin
            exp_out[95:64] = data1;
            exp_out[63:32] = data2;
            exp_out[31:0]  = s_data;
        end    
        
        return exp_out;
    endfunction


endpackage