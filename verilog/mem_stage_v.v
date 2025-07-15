`timescale 1ns / 1ps

module mem_stage_v(
        input         clk,
        input         is_memRead,
        input         is_memWrite,
        input  [31:0] address,
        input  [31:0] S_data,
        output [31:0] data_out  
    );
    
    // Wire for memory output
   // wire [31:0] data_out_internal;
    
    // Instantiate data memory
    dataMem_v memory_block (
        .clk(clk),
        .mem_read(is_memRead),
        .mem_write(is_memWrite),
        .address(address[11:2]),
        .write_data(S_data),
        // output
        .read_data(data_out)
    );
    
   // assign data_out = data_out_internal;
    
endmodule
