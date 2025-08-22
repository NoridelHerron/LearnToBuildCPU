#ifndef GEN_INSTR_H
#define GEN_INSTR_H

// OPCODE TYPE
#define R_TYPE  0x33
#define I_IMM   0x13
#define I_LOAD  0x03
#define S_TYPE  0x23
#define B_TYPE  0x63
#define J_JAL   0x6f

// R_TYPE funct3
#define F3_ADD_SUB   0x0
#define F3_XOR       0x4
#define F3_OR        0x6
#define F3_AND       0x7
#define F3_SLL       0x1
#define F3_SRL_SRA   0x5
#define F3_SLT       0x2
#define F3_SLTU      0x3

// R_TYPE funct7
#define F7_ADD       0x00
#define F7_SUB       0x20
#define F7_SRL       0x00
#define F7_SRA       0x20

// I_IMM funct3
#define F3_ADDI      0x0
#define F3_XORI      0x4
#define F3_ORI       0x6
#define F3_ANDI      0x7
#define F3_SLLI      0x1
#define F3_SRLI_SRAI 0x5
#define F3_SLTI      0x2
#define F3_SLTIU     0x3

// I_IMM funct7
#define F7_SRLI      0x00
#define F7_SRAI      0x20

// I_LOAD funct3
#define F3_LW        0x2

// S_TYPE funct3
#define F3_SW        0x2

// B_TYPE funct3
#define F3_BEQ       0x0
#define F3_BNE       0x1
#define F3_BLT       0x4
#define F3_BGE       0x5
#define F3_BLTU      0x6
#define F3_BGEU      0x7

#endif