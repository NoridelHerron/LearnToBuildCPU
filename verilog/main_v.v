`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 09:11:55 AM
// Module Name: main_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module main_v(
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
    reg [4:0]   ex_rd, ex_rs1, ex_rs2;
    reg         ex_memRead, ex_regWrite;
    
    // MEM STAGE signals
    reg [4:0]  mem_rd;
    reg        mem_regWrite;
    
    // MEM STAGE signals
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
    
    always @(*) begin
        id_op_out        = id_op;
        id_rd_out        = id_rd;       
        id_rs1_out       = id_rs1;      
        id_rs2_out       = id_rs2;
        id_memRead_out   = id_memRead;  
        id_memWrite_out  = id_memWrite;
        id_regWrite_out  = id_regWrite; 
        id_jump_out      = id_jump;     
        id_branch_out    = id_branch;
        id_aluOp_out     = id_aluOp;
        id_forwA_out     = id_forwA;    
        id_forwB_out     = id_forwB;
        id_stall_out     = id_stall;   
        id_operand1_out  = id_operand1; 
        id_operand2_out  = id_operand2; 
        id_sData_out     = id_sData;
    end;
    
    // temporary id/ex register
    always @(posedge clk) begin
        if (reset) begin
            ex_rd       <= 5'd0;
            ex_rs1      <= 5'd0; 
            ex_rs2      <= 5'd0;
            ex_memRead  <= 1'b0;
            ex_regWrite <= 1'b0;
            
        end else begin
            ex_rd       <= id_rd;
            ex_rs1      <= id_rs1; 
            ex_rs2      <= id_rs2;
            ex_memRead  <= id_memRead;
            ex_regWrite <= id_regWrite;
        end
    end
    
    always @(*) begin
        ex_rd_out        = ex_rd;       
        ex_rs1_out       = ex_rs1;      
        ex_rs2_out       = ex_rs2;
        ex_regWrite_out  = ex_regWrite;
    end;
    
    // temporary ex/mem register
    always @(posedge clk) begin
        if (reset) begin
            mem_rd       <= 5'd0;
            mem_regWrite <= 1'b0;
            
        end else begin
            mem_rd       <= ex_rd;
            mem_regWrite <= ex_regWrite;
        end
    end
    
    always @(*) begin
        mem_rd_out       = mem_rd;
        mem_regWrite_out = mem_regWrite;
    end;
    
    // temporary mem/wb register
    always @(posedge clk) begin
        if (reset) begin
            wb_rd       <= 5'd0;
            wb_regWrite <= 1'b0;
            
        end else begin
            wb_rd       <= mem_rd;
            wb_regWrite <= mem_regWrite;
        end
        wb_data <= 32'd0;
    end
    
    always @(*) begin
        wb_rd_out        = wb_rd;
        wb_regWrite_out  = wb_regWrite;
        wb_data_out      = wb_data; 
    end;
    
endmodule
