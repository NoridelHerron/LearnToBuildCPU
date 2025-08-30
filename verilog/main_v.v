`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 09:11:55 AM
// Module Name: main_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module main_v #(parameter isForw_ON = 1)(
    input             clk, reset,
    output reg [64:0] if_stage_out,  
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
        
    output reg        ex_isValid_out,
    output reg [31:0] ex_pc_out,       ex_instr_out,
    output reg [6:0]  ex_op_out,
    output reg [4:0]  ex_rd_out,       ex_rs1_out,      ex_rs2_out,
    output reg        ex_regWrite_out, ex_memWrite_out, ex_memRead_out,
    output reg        ex_jump_out,     ex_branch_out, 
    output reg [3:0]  ex_aluOp_out,
    output reg [31:0] ex_operand1_out, ex_operand2_out, ex_sData_out,
    
    output reg        mem_isValid_out,
    output reg [31:0] mem_pc_out,       mem_instr_out,
    output reg [4:0]  mem_rd_out,
    output reg        mem_regWrite_out, mem_memWrite_out, mem_memRead_out,
    output reg [31:0] mem_aluRes_out,   mem_sData_out,
    
    output reg        wb_isValid_out,
    output reg [31:0] wb_pc_out,       wb_instr_out,
    output reg [4:0]  wb_rd_out,
    output reg        wb_regWrite_out, wb_memWrite_out, wb_memRead_out,
    output reg [31:0] wb_alu_out,       wb_mem_out,
    output     [31:0] wb_data_out 
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
    wire [31:0] alu_result;
    wire [31:0] mem_result;
    wire        mem_isValid;     
    wire [31:0] mem_pc, mem_instr;
    wire [4:0]  mem_rd;
    wire        mem_memRead;
    wire        mem_memWrite;
    wire        mem_regWrite;
    
    // WB STAGE SIGNALS
    wire        wb_isValid;     
    wire [31:0] wb_pc, wb_instr;
    wire [31:0] wb_alu, wb_mem;
    wire [4:0]  wb_rd;
    wire        wb_memRead;
    wire        wb_memWrite;
    wire        wb_regWrite;
    wire [31:0] wb_data;
    
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
    
    always @(*) begin
        id_op_out       = id_op;                                                
        id_rd_out       = id_rd;  
        id_rs1_out      = id_rs1;      
        id_rs2_out      = id_rs2;                                    
        id_memRead_out  = id_memWrite;
        id_regWrite_out = id_regWrite; 
        id_jump_out     = id_jump;     
        id_branch_out   = id_branch;
        id_aluOp_out    = id_aluOp;
        id_forwA_out    = id_forwA;   
        id_forwB_out    = id_forwB;
        id_stall_out    = id_stall; 
        id_operand1_out = id_operand1;
        id_operand2_out = id_operand2; 
        id_sData_out    = id_sData;
    end;
    
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
        .id_s_data(id_sData),        
        // Outputs
        .ex_isValid(ex_isValid),     
        .ex_pc(ex_pc),               .ex_instr(ex_instr),
        .ex_op(ex_op),               .ex_rd(ex_rd), 
        .ex_rs1(ex_rs1),             .ex_rs2(ex_rs2),  
        .ex_mem_read(ex_mem_read),   .ex_mem_write(ex_mem_write), 
        .ex_reg_write(ex_reg_write), .ex_jump(ex_jump),       
        .ex_branch(ex_branch),       .ex_alu_op(ex_alu_op),
        .ex_operand1(ex_operand1),   .ex_operand2(ex_operand2),  
        .ex_s_data(ex_s_data)
    );
    
    always @(*) begin
        ex_isValid_out   = ex_isValid;
        ex_pc_out        = ex_pc;       
        ex_instr_out     = ex_instr;
        ex_op_out        = ex_op;
        ex_rd_out        = ex_rd;
        ex_rs1_out       = ex_rs1; 
        ex_rs2_out       = ex_rs2;
        ex_regWrite_out  = ex_reg_write;
        ex_memWrite_out  = ex_mem_write; 
        ex_memRead_out   = ex_mem_read;
        ex_jump_out      = ex_jump;
        ex_branch_out    = ex_branch;
        ex_aluOp_out     = ex_alu_op;
        ex_operand1_out  = ex_operand1;
        ex_operand2_out  = ex_operand2; 
        ex_sData_out     = ex_s_data;
    end;
    
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
        // Inputs directly from the ID/EX reg
        .ex_isValid(ex_isValid),       .ex_pc(ex_pc), 
        .ex_instr(ex_instr),           .ex_rd(ex_rd),  
        .ex_mem_read(ex_mem_read),     .ex_mem_write(ex_mem_write), 
        .ex_reg_write(ex_reg_write),   
        // Inputs directly from the EX STAGE
        .ex_result(ex_result),         .ex_sData(ex_sData),           
        // Outputs
        .mem_isValid(mem_isValid),     
        .mem_pc(mem_pc),               .mem_instr(mem_instr),
        .mem_rd(mem_rd),               .mem_mem_read(mem_memRead),   
        .mem_mem_write(mem_memWrite),  .mem_reg_write(mem_regWrite), 
        .mem_result(alu_result),       .mem_sData(mem_sData)
    );
    
    always @(*) begin
        mem_isValid_out   = mem_isValid;
        mem_pc_out        = mem_pc;       
        mem_instr_out     = mem_instr;
        mem_rd_out        = mem_rd;
        mem_regWrite_out  = mem_regWrite;
        mem_memWrite_out  = mem_memWrite;
        mem_memRead_out   = mem_memRead;
        mem_aluRes_out    = alu_result;
        mem_sData_out     = mem_sData;
    end;
    
    mem_stage_v mem_stage_uut(
        .clk(clk),
        // // Inputs from EX/MEM reg
        .is_memRead(mem_memRead),
        .is_memWrite(mem_memWrite),
        .address(alu_result),
        .S_data(mem_sData),
        // Output
        .data_out(mem_result)  
    );
    
    memwb_v memwb_uut(
        // Inputs directly from the EX/MEM reg
        .clk(clk),                     .reset(reset), 
        .mem_isValid(mem_isValid),     .mem_pc(mem_pc), 
        .mem_instr(mem_instr),         .mem_rd(mem_rd),  
        .mem_mem_read(mem_memRead),    .mem_mem_write(mem_memWrite), 
        .mem_reg_write(mem_regWrite),  .mem_aluResult(alu_result), 
        // Input from MEM STAGE
        .mem_memResult(mem_result),    
        // Outputs
        .wb_isValid(wb_isValid),       .wb_pc(wb_pc), 
        .wb_instr(wb_instr),           .wb_rd(wb_rd),  
        .wb_mem_read(wb_memRead),     .wb_mem_write(wb_memWrite), 
        .wb_reg_write(wb_regWrite),   .wb_aluResult(wb_alu),   
        .wb_memResult(wb_mem)
    );
    
    always @(*) begin
        wb_isValid_out   = wb_isValid;
        wb_pc_out        = wb_pc;       
        wb_instr_out     = wb_instr;
        wb_rd_out        = wb_rd;
        wb_regWrite_out  = wb_regWrite;
        wb_memWrite_out  = wb_memWrite; 
        wb_memRead_out   = wb_memRead;
        wb_alu_out       = wb_alu;
        wb_mem_out       = wb_mem;
    end;
    
    WB_v WB_uut(
        // Inputs directly from the MEM/WB reg
        .is_memRead(wb_mem_read), 
        .is_memWrite(wb_mem_write), 
        .alu_data(wb_alu), 
        .mem_data(wb_mem),
        // Outputs
        .wb_data(wb_data) 
    );
    
    assign wb_data_out = wb_data;
    
endmodule
