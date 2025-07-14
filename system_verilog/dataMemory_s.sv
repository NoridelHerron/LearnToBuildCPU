`timescale 1ns / 1ps

module dataMemory_s(
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [9:0]  address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data  
    );
    
    // Declare memory: 1024 words of 32 bits
    logic [31:0] mem [0:1023];

    // Initialize memory
    initial begin
        foreach (mem[i])
            mem[i] = 32'b0;
    end

    // Synchronous write
    always_ff @(posedge clk) begin
        if (mem_write)
            mem[address] <= write_data;
    end

    // Combinational read (only when mem_write is 0)
    always_comb begin
        if (mem_read && !mem_write)
            read_data = mem[address];
        else
            read_data = 32'b0;
    end
    
endmodule
