`timescale 1ns / 1ps

module mem_stage_s(
        input  logic        clk,
        input  logic        is_memRead,
        input  logic        is_memWrite,
        input  logic [31:0] address,
        input  logic [31:0] S_data,
        output logic [31:0] data_out  
    );
    
    // Instantiate data memory
    dataMemory_s memory_block (
        .clk(clk),
        .mem_read(is_memRead),
        .mem_write(is_memWrite),
        .address(address[11:2]),
        .write_data(S_data),
        // output
        .read_data(data_out)
    );
    
endmodule
