`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/23/2025 07:12:58 AM
// Module Name: idex_v
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module idex_v(
        input             clk, reset,
        input             id_isValid,     
        input      [31:0] id_pc, id_instr,
        input      [6:0]  id_op, 
        input      [4:0]  id_rd, id_rs1, id_rs2, 
        input             id_mem_read,     
        input             id_mem_write,   
        input             id_reg_write,   
        input             id_jump,       
        input             id_branch,       
        input      [3:0]  id_alu_op,
        input             id_stall,       
        input      [31:0] id_operand1,  id_operand2,  id_s_data,
        output reg        ex_isValid,     
        output reg [31:0] ex_pc, ex_instr,
        output reg [6:0]  ex_op, 
        output reg [4:0]  ex_rd, ex_rs1, ex_rs2,  
        output reg        ex_mem_read,   
        output reg        ex_mem_write, 
        output reg        ex_reg_write,   
        output reg        ex_jump,       
        output reg        ex_branch,    
        output reg [3:0]  ex_alu_op,
        output reg [31:0] ex_operand1,  ex_operand2,  ex_s_data
    );
    
    always @(posedge clk) begin
        if (reset) begin
            ex_isValid    <= 1'd0;
            ex_pc         <= 32'd0;  
            ex_instr      <= 32'd0;  
            ex_op         <= 7'd0;
            ex_rd         <= 5'd0; 
            ex_rs1        <= 5'd0; 
            ex_rs2        <= 5'd0; 
            ex_mem_read   <= 1'd0;  
            ex_mem_write  <= 1'd0; 
            ex_reg_write  <= 1'd0;   
            ex_jump       <= 1'd0;       
            ex_branch     <= 1'd0;    
            ex_alu_op     <= 4'd0; 
            ex_operand1   <= 32'd0;  
            ex_operand2   <= 32'd0;  
            ex_s_data     <= 32'd0;
    
        // Normal flow
        end else if (id_isValid) begin
            ex_isValid    <= id_isValid;
            ex_pc         <= id_pc;  
            ex_instr      <= id_instr;  
            ex_op         <= id_op;
            ex_rd         <= id_rd; 
            ex_rs1        <= id_rs1; 
            ex_rs2        <= id_rs2; 
            ex_mem_read   <= id_mem_read;  
            ex_mem_write  <= id_mem_write; 
            ex_reg_write  <= id_reg_write;   
            ex_jump       <= id_jump;       
            ex_branch     <= id_branch;    
            ex_alu_op     <= id_alu_op; 
            ex_operand1   <= id_operand1;  
            ex_operand2   <= id_operand2;  
            ex_s_data     <= id_s_data;
        end
    end
    
    
endmodule
