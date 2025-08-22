`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/17/2025 08:07:34 AM
// Module Name: Hazard detection Unit
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module hdu_v ( 
        input  wire [4:0] id_rs1, id_rs2,
        input  wire [4:0] idex_rs1, idex_rs2, idex_rd, exmem_rd, memwb_rd, 
        input  wire       idex_memRead, exmem_regWrite, memwb_regWrite,
        output reg  [1:0] forwA, forwB, 
        output reg        stall 
    );
    
    always @(*) begin
        if (exmem_regWrite && exmem_rd != 5'd0 && exmem_rd == idex_rs1) 
            forwA = 2'b01;
        else if (memwb_regWrite && memwb_rd != 5'd0 && memwb_rd == idex_rs1) 
            forwA = 2'b10;
        else
            forwA = 2'b00;
            
        if (exmem_regWrite && exmem_rd != 5'd0 && exmem_rd == idex_rs2) 
            forwB = 2'b01;
        else if (memwb_regWrite && memwb_rd != 5'd0 && memwb_rd == idex_rs2) 
            forwB = 2'b10;
        else
            forwB = 2'b00;
        
        if (idex_memRead && (idex_rd == id_rs1 || idex_rd == id_rs2) && idex_rd != 5'd0)
            stall = 1'b1;
        else
            stall = 1'b0;
    end
    
endmodule
