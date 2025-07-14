`timescale 1ns / 1ps

module alu_s(
        input  logic [31:0] A,
        input  logic [31:0] B,
        input  logic [2:0]  f3,
        input  logic [6:0]  f7,
        output logic [31:0] result,
        output logic        Z,   // Zero
        output logic        N,   // Negative
        output logic        C,   // Carry
        output logic        V    // Overflow
    );
    
    localparam logic [2:0] FUNC3_ADD_SUB = 3'b000;
    localparam logic [2:0] FUNC3_SLL     = 3'b001;
    localparam logic [2:0] FUNC3_SLT     = 3'b010;
    localparam logic [2:0] FUNC3_SLTU    = 3'b011;
    localparam logic [2:0] FUNC3_XOR     = 3'b100;
    localparam logic [2:0] FUNC3_SRL_SRA = 3'b101;
    localparam logic [2:0] FUNC3_OR      = 3'b110;
    localparam logic [2:0] FUNC3_AND     = 3'b111;
    
    localparam logic [6:0] FUNC7_ADD     = 7'b0000000;
    localparam logic [6:0] FUNC7_SUB     = 7'b0100000;
    localparam logic [6:0] FUNC7_SRL     = 7'b0000000;
    localparam logic [6:0] FUNC7_SRA     = 7'b0100000;
    
    logic [32:0] temp;
    
    always_comb begin
        // Default values
        result = 32'b0;
        Z = 0; N = 0; C = 0; V = 0;
        temp = 33'b0;

        case (f3)
            FUNC3_ADD_SUB: begin
                if (f7 == FUNC7_SUB) begin
                    temp = {1'b0, A} - {1'b0, B};
                    result = temp[31:0];
                    C = ~temp[32]; // Borrow = 0 → C = 1
                    V = (A[31] != B[31]) && (result[31] != A[31]);
                end else if (f7 == FUNC7_ADD) begin
                    temp = {1'b0, A} + {1'b0, B};
                    result = temp[31:0];
                    C = temp[32]; // Carry-out
                    V = (A[31] == B[31]) && (result[31] != A[31]);
                end else begin
                    result = 32'b0;
                    C = 1'b0;
                    V = 1'b0;
                end
            end

            FUNC3_SLL: begin
                result = A << B[4:0];
            end

            FUNC3_SLT: begin
                result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            end

            FUNC3_SLTU: begin
                result = (A < B) ? 32'b1 : 32'b0;
            end

            FUNC3_XOR: begin
                result = A ^ B;
            end

            FUNC3_SRL_SRA: begin
                if (f7 == FUNC7_SRA) begin
                    result = $signed(A) >>> B[4:0];
                end else if (f7 == FUNC7_SRL) begin
                    result = A >> B[4:0];
                end else begin
                    result = 32'b0;
                end 
            end

            FUNC3_OR: begin
                result = A | B;
            end

            FUNC3_AND: begin
                result = A & B;
            end

            default: begin
                result = 32'b0;
            end
        endcase

        // Zero flag
        Z = (result == 32'b0);

        // Negative flag (sign bit)
        N = result[31];
    end

endmodule
