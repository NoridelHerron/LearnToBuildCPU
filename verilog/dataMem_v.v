`timescale 1ns / 1ps

module dataMem_v (
    input             clk,
    input             mem_read,
    input             mem_write,
    input      [9:0]  address,
    input      [31:0] write_data,
    output reg [31:0] read_data  
);
    
    // Declare memory: 1024 words of 32 bits
    reg [31:0] mem [0:1023];
    
    initial begin 
        for (integer i = 0; i < 1024; i = i + 1) begin
            mem[i] = 32'b0;  // or any default value
        end     
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write)
            mem[address] <= write_data;
    end

    // Combinational read with condition
    always @(*) begin
        if (mem_read && !mem_write)
            read_data = mem[address];
        else
            read_data = 32'b0;
    end

endmodule
