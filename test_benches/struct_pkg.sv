`timescale 1ns / 1ps

package struct_pkg;
    
    typedef struct packed {
        logic [6:0]  op; 
        logic [4:0]  rs1, rs2, rd;
        logic        memRead, memWrite, regWrite, jump, branch;
        logic [3:0]  alu_op;        
        logic [1:0]  forwA, forwB;
        logic        stall;
        logic [31:0] operand1,  operand2,  s_data;
    } id_out;

    typedef struct packed {
        logic [31:0] instr; 
        logic [4:0]  idex_rs1, idex_rs2, idex_rd;
        logic        idex_memRead;
        logic        idex_regWrite;
        logic        exmem_regWrite;              
        logic [4:0]  exmem_rd;
        logic        memwb_regWrite;             
        logic [4:0]  memwb_rd;
        logic [31:0] wb_data;
    } id_in;
    
    typedef struct packed {
        logic [4:0]  rs1, rs2, rd;
        logic        memRead;
        logic        regWrite;
    } idex_t;
    
    typedef struct packed {
        logic        regWrite;              
        logic [4:0]  rd;
    } rd_write;
    
    typedef struct packed {
        logic [3:0]  alu_op;
        logic [31:0] A, B;
    } alu_in;
    
    typedef struct packed {
        logic        Z, N, C, V;
        logic [31:0] result;
    } alu_out;
    
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

endpackage 