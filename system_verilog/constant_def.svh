
`ifndef CONSTANT_DEF
`define CONSTANT_DEFS
    // ALU OPERATIONS
    `define ALU_ADD  4'h0
    `define ALU_SUB  4'h1
    `define ALU_XOR  4'h2
    `define ALU_OR   4'h3
    `define ALU_AND  4'h4
    `define ALU_SLL  4'h5
    `define ALU_SRL  4'h6
    `define ALU_SRA  4'h7
    `define ALU_SLT  4'h8
    `define ALU_SLTU 4'h9
    
    // OPCODE TYPE
    `define R_TYPE   7'h33 
    `define I_IMM    7'h13
    `define I_LOAD   7'h03
    `define S_TYPE   7'h23 
    `define B_TYPE   7'h63 
    `define J_JAL    7'h6f
    `define I_JALR   7'h67
    `define U_LUI    7'h37
    `define U_AUIPC  7'h17
    `define I_ECALL  7'h73 
    `define I_EBREAK 7'h73
    
    // R_TYPE funct3  
    `define F3_ADD_SUB 3'h0
    `define F3_XOR     3'h4
    `define F3_OR      3'h6
    `define F3_AND     3'h7
    `define F3_SLL     3'h1
    `define F3_SRL_SRA 3'h5
    `define F3_SLT     3'h2
    `define F3_SLTU    3'h3
    
    // R_TYPE funct7
    `define F7_ADD 7'h0
    `define F7_SUB 7'h20
    `define F7_SRL 7'h0
    `define F7_SRA 7'h20
    
    // I_IMM funct3 
    `define F3_ADDi      3'h0
    `define F3_XORi      3'h4
    `define F3_ORi       3'h6
    `define F3_ANDi      3'h7
    `define F3_SLLi      3'h1
    `define F3_SRLi_SRAi 3'h5
    `define F3_SLTi      3'h2
    `define F3_SLTiU     3'h3

    // I_IMM funct7   
    `define F7_SRLi 7'h0
    `define F7_SRAi 7'h20

    // I_LOAD funct3 
    `define F3_LW 3'h2
    
    // S_TYPE funct3 
    `define F3_SW 3'h2
    
    // B_TYPE funct3 
    `define BEQ  3'h0
    `define BNE  3'h1
    `define BLT  3'h4
    `define BGE  3'h5
    `define BLTU 3'h6
    `define BGEU 3'h7
    
`endif
