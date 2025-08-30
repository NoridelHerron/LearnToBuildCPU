`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 08:44:00 AM
// Module Name: regFile_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module regFile_v(
        input         clk, isWrite,
        input  [4:0]  rs1, rs2, rd, 
        input  [31:0] writeData, 
        output [31:0] readData1, readData2 
    );
    
    reg [31:0] regs [31:0];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end
    
     always @(posedge clk) begin   
        if (isWrite && rd != 5'd0)
            regs[rd] <= writeData;
     end
     
     assign readData1 = (rs1 == 0) ? 32'b0 :  (isWrite && rd == rs1) ? writeData : regs[rs1];
     assign readData2 = (rs2 == 0) ? 32'b0 :  (isWrite && rd == rs2) ? writeData : regs[rs2];
    
endmodule
