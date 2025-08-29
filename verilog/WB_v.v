`timescale 1ns / 1ps

module WB_v(
        input             is_memRead, 
        input             is_memWrite, 
        input  [31:0]     alu_data, 
        input  [31:0]     mem_data,  
        output reg [31:0] wb_data 
    );
    
    always @(*) begin
        if (is_memRead == 1'b1 || is_memWrite == 1'b1) 
            wb_data = mem_data;
        else
            wb_data = alu_data;   
    end
endmodule
