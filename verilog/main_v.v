`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 09:11:55 AM
// Module Name: main_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module main_v #(parameter isForw_ON = 1)(
    input  clk, reset,
    output reg        if_isValid_out,
    output reg [31:0] if_pc_out,       if_instr_out,
    output reg        id_isValid_out,
    output reg [31:0] id_pc_out,       id_instr_out,
    output reg [6:0]  id_op_out,
    output reg [4:0]  id_rd_out,       id_rs1_out,      id_rs2_out,
    output reg        id_memRead_out,  id_memWrite_out, 
    output reg        id_regWrite_out, id_jump_out,     id_branch_out,
    output reg [3:0]  id_aluOp_out,
    output reg [1:0]  id_forwA_out,    id_forwB_out,
    output reg        id_stall_out,    
    output reg [31:0] id_operand1_out, id_operand2_out, id_sData_out,
    output reg [4:0]  ex_rd_out,       ex_rs1_out,      ex_rs2_out,
    output reg        ex_regWrite_out, 
    output reg [4:0]  mem_rd_out,
    output reg        mem_regWrite_out, 
    output reg [4:0]  wb_rd_out,
    output reg        wb_regWrite_out,
    output reg [31:0] wb_data_out 
    );
    
    wire        is_flush;
    wire [31:0] br_target;
    
    // IF STAGE signals
    wire        if_isValid;
    wire [31:0] if_pc, if_instr;
    
    // ID STAGE signals
    wire        id_isValid;
    wire [31:0] id_pc, id_instr;                        
    wire [6:0]  id_op;                                                    
    wire [4:0]  id_rd, id_rs1, id_rs2;                                    
    wire        id_memRead, id_memWrite, id_regWrite, id_jump, id_branch; 
    wire [3:0]  id_aluOp;  
    wire [1:0]  id_forwA, id_forwB;  
    wire        id_stall;  
    wire [31:0] id_operand1, id_operand2, id_sData;  
    
    // EX STAGE signal
    wire        ex_isValid;     
    wire [31:0] ex_pc, ex_instr;
    wire [6:0]  ex_op; 
    wire [4:0]  ex_rd, ex_rs1, ex_rs2;  
    wire        ex_mem_read;  
    wire        ex_mem_write; 
    wire        ex_reg_write;   
    wire        ex_jump;       
    wire        ex_branch;    
    wire [3:0]  ex_alu_op;
    wire [31:0] ex_operand1,  ex_operand2,  ex_s_data;
    wire [31:0] ex_result, ex_sData;
    wire        ex_Z, ex_N, ex_C, ex_V;
    
    // MEM STAGE signals
    wire [31:0] exmem_result;
    reg [4:0]  mem_rd;
    reg        mem_regWrite;
    
    // WB STAGE SIGNALS
    wire [31:0] memwb_result;
    reg [4:0]  wb_rd;
    reg        wb_regWrite;
    reg [31:0] wb_data;
    
    
    // IF Stage
    if_stage_v if_uut(
        .clk(clk),             .reset(reset), 
        .is_flush(is_flush),   .is_stall(id_stall), .branch_target(br_target),
        // outputs
        .is_valid(if_isValid), .pc(if_pc),          .instr(if_instr)
    );
    
    always @(*) begin
        if_isValid_out   = if_isValid;
        if_pc_out        = if_pc;       
        if_instr_out     = if_instr;
    end;
    
    // IF/ID register
    ifid_v ifid_uut(
        .clk(clk),                  .reset(reset), 
        .is_flush(is_flush),        .is_stall(id_stall),
        .is_valid_in(if_isValid),   .pc_in(if_pc),    .instr_in(if_instr),   
        // Outputs     
        .is_valid_out(id_isValid),  .pc_out(id_pc),     .instr_out(id_instr)
    );
    
    always @(*) begin
        id_isValid_out   = id_isValid;
        id_pc_out        = id_pc;       
        id_instr_out     = id_instr;
    end;
    
    id_v id_uut(
        .clk(clk),
        .instruction(id_instr),         
        .idex_rs1(ex_rs1),             .idex_rs2(ex_rs2), 
        .idex_rd(ex_rd),               .idex_memRead(ex_memRead), 
        .exmem_regWrite(mem_regWrite), .exmem_rd(mem_rd),
        .memwb_regWrite(wb_regWrite),  .memwb_rd(wb_rd),                  
        .wb_data(wb_data),
        // Outputs
        .op(id_op), .rd(id_rd),        .rs1(id_rs1), .rs2(id_rs2), 
        .mem_read(id_memRead),         .mem_write(id_memWrite),   
        .reg_write(id_regWrite),       .jump(id_jump),      
        .branch(id_branch),            .alu_op(id_aluOp),       
        .forwA(id_forwA),              .forwB(id_forwB),       
        .stall(id_stall),              .operand1(id_operand1),  
        .operand2(id_operand2),        .s_data(id_sData)
    );
    
    idex_v idex_uut(
        .clk(clk),                   .reset(reset), 
        .id_isValid(id_isValid),     .id_pc(id_pc),      
        .id_instr(id_instr),         .id_op(id_op),              
        .id_rd(id_rd),               .id_rs1(id_rs1), 
        .id_rs2(id_rs2),             .id_mem_read(id_memRead),     
        .id_mem_write(id_memWrite),  .id_reg_write(id_regWrite),   
        .id_jump(id_jump),           .id_branch(id_branch),       
        .id_alu_op(id_aluOp),        .id_stall(id_stall),       
        .id_operand1(id_operand1),   .id_operand2(id_operand2),   
        .id_s_data(id_sData),        .ex_isValid(ex_isValid),     
        .ex_pc(ex_pc),               .ex_instr(ex_instr),
        .ex_op(ex_op),               .ex_rd(ex_rd), 
        .ex_rs1(ex_rs1),             .ex_rs2(ex_rs2),  
        .ex_mem_read(ex_mem_read),   .ex_mem_write(ex_mem_write), 
        .ex_reg_write(ex_reg_write), .ex_jump(ex_jump),       
        .ex_branch(ex_branch),       .ex_alu_op(ex_alu_op),
        .ex_operand1(ex_operand1),   .ex_operand2(ex_operand2),  
        .ex_s_data(ex_s_data)
    );
    
    ex_v ex_uut( 
        .alu_op(ex_alu_op),          .isForw_ON(isForw_ON),
        .op(ex_op),                  .exmem_result(exmem_result), 
        .memwb_result(memwb_result), .forwA(id_forwA), 
        .forwB(id_forwB),            .data1(ex_operand1), 
        .data2(ex_operand2),         .s_data(ex_s_data),
        // Outputs
        .result(ex_result),          .sData(ex_sData),
        .Z(ex_Z), .N(ex_N),          .C(ex_C), .V(ex_V)
    );
    
    exmem_v exmem_uut(
        .clk(clk),                     .reset(reset), 
        .ex_isValid(ex_isValid),       .ex_pc(ex_pc), 
        .ex_instr(ex_instr),           .ex_rd(ex_rd),  
        .ex_mem_read(ex_mem_read),     .ex_mem_write(ex_mem_write), 
        .ex_reg_write(ex_reg_write),   .ex_result(ex_result), 
        .ex_sData(ex_sData),           .mem_isValid(mem_isValid),     
        .mem_pc(mem_pc),               .mem_instr(mem_instr),
        .mem_rd(mem_rd),               .mem_mem_read(mem_mem_read),   
        .mem_mem_write(mem_mem_write), .mem_reg_write(mem_reg_write), 
        .mem_result(mem_result),       .mem_sData(mem_sData)
    );
    
    mem_stage_v mem_stage_uut(
        .clk(clk),
        .is_memRead(is_memRead),
        .is_memWrite(is_memWrite),
        .address(mem_pc),
        .S_data(S_data),
        .data_out(data_out)  
    );
    
    memwb_v memwb_uut(
        .clk(clk),                     .reset(reset), 
        .mem_isValid(mem_isValid),     .mem_pc(mem_pc), 
        .mem_instr(mem_instr),         .mem_rd(mem_rd),  
        .mem_mem_read(mem_mem_read),   .mem_mem_write(mem_mem_write), 
        .mem_reg_write(mem_reg_write), .mem_aluResult(mem_aluResult), 
        .mem_memResult(mem_memResult), .wb_rd(wb_rd),  
        .wb_mem_read(wb_mem_read),     .wb_mem_write(wb_mem_write), 
        .wb_reg_write(wb_reg_write),   .wb_aluResult(wb_aluResult),   
        .wb_memResult(wb_memResult)
    );
    
    WB_v WB_uut(
        .is_memRead(wb_mem_read), 
        .is_memWrite(wb_mem_write), 
        .mem_data(wb_memResult), 
        .alu_data(wb_aluResult), 
        .wb_data(wb_data) 
    );
    
    
endmodule
