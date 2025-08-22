`timescale 1ns / 1ps

module decoder_v(
        input      [31:0] ID,
        output reg [6:0]  op,
        output reg [4:0]  rd,
        output reg [2:0]  funct3,
        output reg [4:0]  rs1,
        output reg [4:0]  rs2,
        output reg [6:0]  funct7,
        output reg [11:0] imm12,
        output reg [19:0] imm20
    );
    
    localparam [6:0] R_TYPE  = 7'b0110011;
    localparam [6:0] S_TYPE  = 7'b0100011;
    localparam [6:0] B_TYPE  = 7'b1100011;
    localparam [6:0] JAL     = 7'b1101111;
    localparam [6:0] IMM     = 7'b0010011;
    localparam [6:0] LOAD    = 7'b0000011;
    localparam [6:0] ECALL   = 7'b1110111;
    localparam [6:0] JALR    = 7'b1100111;
    localparam [6:0] U_LUI   = 7'b0110111;
    localparam [6:0] U_AUIPC = 7'b0010111;
    
    always @(*) begin
        case (ID[6:0])
            R_TYPE  : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = ID[24:20];
                funct7 = ID[31:25];
                imm12  = 12'b0;
                imm20  = 20'b0;
            end
            
            S_TYPE  : begin
                op     = ID[6:0];
                rd     = 5'b0;
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = ID[24:20];
                funct7 = 7'b0;
                imm12  = {ID[31:25], ID[11:7]};
                imm20  = 20'b0;
            end
            
            B_TYPE  : begin
                op     = ID[6:0];
                rd     = 5'b0;
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = ID[24:20];
                funct7 = 7'b0;
                imm12  = {ID[31], ID[7], ID[30:25], ID[11:8]};
                imm20  = 20'b0;
            end
            
            JAL     : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = 3'b0;
                rs1    = 5'b0;
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = 12'b0;
                imm20  = {ID[31], ID[19:12], ID[20], ID[30:21]};
            end
            
            IMM     : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = ID[31:20];
                imm20  = 20'b0;
            end
            
            LOAD    : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = ID[31:20];
                imm20  = 20'b0;
            end
            
            ECALL   : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = ID[31:20];
                imm20  = 20'b0;
            end
            
            JALR    : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = ID[14:12];
                rs1    = ID[19:15];
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = ID[31:20];
                imm20  = 20'b0;
            end
            
            U_LUI   : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = 3'b0;
                rs1    = 5'b0;
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = 12'b0;
                imm20  = ID[31:12];
            end
            
            U_AUIPC : begin
                op     = ID[6:0];
                rd     = ID[11:7];
                funct3 = 3'b0;
                rs1    = 5'b0;
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = 12'b0;
                imm20  = ID[31:12];
            end
            
            default : begin
                op     = 7'b0;
                rd     = 5'b0;
                funct3 = 3'b0;
                rs1    = 5'b0;
                rs2    = 5'b0;
                funct7 = 7'b0;
                imm12  = 12'b0;
                imm20  = 20'b0;
            end
            
        endcase
    end
endmodule
