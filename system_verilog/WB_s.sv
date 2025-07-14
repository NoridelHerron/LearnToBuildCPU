`timescale 1ns / 1ps

module WB_s(
        input  logic        is_memRead, 
        input  logic [31:0] mem_data, 
        input  logic [31:0] alu_data, 
        output logic [31:0] wb_data 
    );
    
    always_comb begin
        if (is_memRead)
            wb_data = mem_data;
        else
            wb_data = alu_data;
    end

endmodule
