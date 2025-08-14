`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/14/2025 07:16:55 AM
// Module Name: ALU
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////

module v_alu(
        input  [31:0] A,            // Operand A
        input  [31:0] B,            // Operand B
        input  [3:0]  alu_op,       // Alu operation
        output reg [31:0] result,   // 32-bits result
        output reg Z,               // Zero
        output reg N,               // Negative
        output reg C,               // Carry
        output reg V                // Overflow
    );
    
    // Alu operations
    localparam [3:0]
        ALU_ADD  = 4'h0,
        ALU_SUB  = 4'h1,
        ALU_XOR  = 4'h2,
        ALU_OR   = 4'h3,
        ALU_AND  = 4'h4,
        ALU_SLL  = 4'h5,
        ALU_SRL  = 4'h6,
        ALU_SRA  = 4'h7,
        ALU_SLT  = 4'h8,
        ALU_SLTU = 4'h9;
        
    reg [32:0] temp; // 33-bit to hold carry for add/sub
    
    always @(*) begin
        case (alu_op)
        
            ALU_ADD: begin
                temp   = {1'b0, A} + {1'b0, B};
                result = temp[31:0];
            end
            
            ALU_SUB: begin
                temp   = {1'b0, A} - {1'b0, B};
                result = temp[31:0];
            end
            
            ALU_XOR : result = A ^ B;
            ALU_OR  : result = A | B;
            ALU_AND : result = A & B;
            ALU_SLL : result = A << B[4:0];
            ALU_SRL : result = A >> B[4:0];
            ALU_SRA : result = $signed(A) >>> B[4:0];
            ALU_SLT : result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
            ALU_SLTU: result = (A < B) ? 32'b1 : 32'b0;
            default : result = 32'b0;
            
        endcase
        
        // Flags
        Z = (result == 32'b0);
        N = result[31];
        
        if (alu_op == ALU_ADD || alu_op == ALU_SUB) begin
            if (alu_op == ALU_ADD) begin
                // Carry-out
                C = temp[32];  
                // Overflow if operands have the same sign but the result's sign differs from A's sign
                V = (A[31] == B[31]) && (result[31] != A[31]); 
            end else begin
                // Borrow = 0 → C = 1
                C = ~temp[32]; 
                // opposite of add to detect overflow
                V = (A[31] != B[31]) && (result[31] != A[31]); 
            end
            
        end else begin
            C = 1'b0;
            V = 1'b0;
        end
    end
    
endmodule
