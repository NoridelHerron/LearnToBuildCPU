
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/16/2025 07:38:43 AM
// Module Name: rom
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
module tb_rom;

    reg  clk;
    reg  [9:0]   addr;
    wire [31:0] instr;

    // Instantiate the ROM
    rom_v uut (
        .clk(clk),
        .addr(addr),
        .instr(instr)
    );

    // Clock generator (10ns period)
    always #5 clk = ~clk;

    integer i;
    
    initial begin
	$display("----Starting ROM test---");
        clk    = 0;
        addr   = 0;
        
        // Wait a bit before starting
        @(posedge clk);

		//Read first 10 instruction pairs from ROM
        for (i = 0; i < 1024; i = i + 1) begin     //Here Set address on clock edge
            @(posedge clk);
            addr = i;
            @(posedge clk);
            $display("addr = %0d : instr = %h", addr, instr);
        end
		$display("----Test completed---");		
        $finish;
    end

endmodule