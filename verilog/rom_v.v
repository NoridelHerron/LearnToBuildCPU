`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/16/2025 07:38:43 AM
// Module Name: rom
// Created by: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////
`include "constant_def.vh"

module rom_v ( 
       input  wire        clk,
       input  wire [9:0]  addr,    // PC >> 2 for word indexing
       output reg  [31:0] instr
    );
    reg [31:0] rom [0:1023];
    reg [14:0] temp_reg;
    
    function [14:0] generate_registers;
        input integer type_sel;
        input reg [4:0] rd;
        reg [14:0] rand_reg;
        
         begin
            case (type_sel) // rd = rand_reg[14:10], rs2= rand_reg[9:5], rs1 = rand_reg[4:0]
               // Case 0-2 will help generate hazard later
               0 : begin 
                    rand_reg[14:10] = $urandom_range(0, 31); 
                    rand_reg[9:5]   = rd; 
                    rand_reg[4:0]   = $urandom_range(0, 31);
               end 
               
               1 : begin 
                    rand_reg[14:10] = $urandom_range(0, 31); 
                    rand_reg[9:5]   =  $urandom_range(0, 31); 
                    rand_reg[4:0]   = rd; 
               end 
               
               2 : begin 
                    rand_reg[14:10] = $urandom_range(0, 31); 
                    rand_reg[9:5]   = rd; 
                    rand_reg[4:0]   = rd; 
               end 
               
               3 : begin 
                    rand_reg[14:10] = $urandom_range(0, 31); 
                    rand_reg[9:5]   =  $urandom_range(0, 31); 
                    rand_reg[4:0]   = $urandom_range(0, 31); 
               end 
               
               default : begin 
                    rand_reg[14:10] = $urandom_range(1, 31); 
                    rand_reg[9:5]   =  $urandom_range(1, 31); 
                    rand_reg[4:0]   = $urandom_range(1, 31); 
               end 
            endcase
        generate_registers = rand_reg;
        end
    endfunction
    
    function [31:0] generate_instruction;
        input integer type_sel;
        input [14:0] registers;
        reg [2:0]  funct3;
        reg [6:0]  funct7;
        reg [11:0] imm12;  // 12-bit immediate // divisible by 4
        reg [19:0] imm20;  // 20-bit immediate // divisible by 4
        reg [31:0] instr;

        begin
            funct3 = $urandom_range(0, 7);
            funct7 = $urandom_range(0, 127);

            case (type_sel)
            
                //==== R-type logic (e.g., add, sub, srl, sra) ====
                0: begin
                    if (funct3 == `F3_ADD_SUB || funct3 == `F3_SRL_SRA) begin
                        funct7 = $urandom_range(0, 1) ? 7'd0 : 7'd32;  // ADD/SRL or SUB/SRA
                    end else begin
                        funct7 = 7'd0; // other R-type
                    end
                    instr = {funct7, registers[9:5], registers[4:0], funct3, registers[14:0], `R_TYPE};
                end

                //==== I-type Immediate ====
                1: begin
                    imm12 = {funct7, registers[9:5]} * 4; 
                    instr = {imm12, registers[4:0], funct3, registers[14:0], `I_IMM};
                end

                // ==== Load (e.g., LW) ====
                2: begin
                    funct3 = `F3_LW; // Force LW
                    imm12 = {funct7, registers[9:5]} * 4; 
                    instr = {imm12, registers[4:0], funct3, registers[14:0], `I_LOAD};
                end
                
                // ===== S-type logic (e.g., store) ===
                3: begin
                    funct3 = `F3_SW; // Force LW
                    imm12 = {funct7, registers[9:5]} * 4; 
                    instr = {imm12[11:5], registers[9:5], registers[4:0], funct3, imm12[4:0], `S_TYPE};
                end
                
                //==== B-type logic (e.g., beq) ====
                4: begin
                    case (funct3)
                        0: funct3 = `BEQ;
                        1: funct3 = `BNE;
                        4: funct3 = `BLT;
                        5: funct3 = `BGE;
                        6: funct3 = `BLTU;
                        7: funct3 = `BGEU;
                        default: funct3 = $urandom_range(4, 7);
                    endcase
                    imm12 = {funct7, registers[9:5]} * 4; 
                    instr = {imm12[11], imm12[9:4], registers[9:5], registers[4:0], 
                             funct3, imm12[3:0], imm12[10], `B_TYPE};
                end

                // ==== JAL Logic ====
                5: begin
                    imm20 = {funct7, registers[9:5], registers[4:0], funct3}; // 20-bit signed immediate
                    instr = {
                                imm20[19],       // bit 31
                                imm20[9:0],      // bits 30:21
                                imm20[10],       // bit 20
                                imm20[18:11],    // bits 19:12
                                registers[14:0], // bits 11:7
                                `J_JAL     // bits 6:0
                            };
                end

                //==== Default (NOP) ====
                default: instr = 32'h00000013;

            endcase

            generate_instruction = instr;
        end
    endfunction
    
    integer i;
    
    initial begin
        /*
        for (i = 0; i < 1024; i = i + 1) begin
            temp_reg = generate_registers ($urandom_range(3, 5), 5'b0);
            rom[i] = generate_instruction($urandom_range(0, 5), temp_reg);
            $display("ROM[%0d] = %h", i, rom[i]);
        end 
        */
        rom[0] = 32'h00150393;  // addi x7, x10 1	1		1	
        rom[1] = 32'h00248413;  // addi x8, x9  2	2		2
        rom[2] = 32'h008385b3;  // add x11, x7 x8	0		3
        rom[3] = 32'h00b406b3;  // add x13, x8 x11	0		5
        rom[4] = 32'h00b687b3;  // add x15, x13 x11	0		8
        rom[5] = 32'h00338993;  // addi x19, x7 3	4		4
        rom[6] = 32'h00338a13;  // addi x20, x7 3	4		4
        
        for (i = 7; i < 1024; i = i + 1) begin
            rom[i] = 32'h00000013;
        end


    end
    
    // Assign output
    always @(posedge clk) begin
        instr <= rom[addr];
    end
    
endmodule
    