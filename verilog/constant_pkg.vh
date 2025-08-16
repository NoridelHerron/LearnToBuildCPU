// Opcode type
localparam [6:0]
    R_TYPE   = 7'h33, 
    I_IMM    = 7'h13,
    I_LOAD   = 7'h03,
    S_TYPE   = 7'h23, 
    B_TYPE   = 7'h63, 
    J_JAL    = 7'h6f,
    I_JALR   = 7'h67,  
    U_LUI    = 7'h37, 
    U_AUIPC  = 7'h17, 
    I_ECALL  = 7'h73, 
    I_EBREAK = 7'h73;

// R_TYPE funct3      
localparam [2:0]
    F3_ADD_SUB = 3'h0,
    F3_XOR     = 3'h4,
    F3_OR      = 3'h6,
    F3_AND     = 3'h7,
    F3_SLL     = 3'h1,
    F3_SRL_SRA = 3'h5,
    F3_SLT     = 3'h2,
    F3_SLTU    = 3'h3;
    
// R_TYPE funct7    
localparam [6:0]
    F7_ADD = 7'h0,
    F7_SUB = 7'h20,
    F7_SRL = 7'h0,
    F7_SRA = 7'h20;

// I_IMM funct3      
localparam [2:0]
    F3_ADDi      = 3'h0,
    F3_XORi      = 3'h4,
    F3_ORi       = 3'h6,
    F3_ANDi      = 3'h7,
    F3_SLLi      = 3'h1,
    F3_SRLi_SRAi = 3'h5,
    F3_SLTi      = 3'h2,
    F3_SLTiU     = 3'h3;
    
// I_IMM funct7    
localparam [6:0]
    F7_SRLi = 7'h0,
    F7_SRAi = 7'h20;
    
// I_LOAD funct3      
localparam [2:0]
    F3_LW = 3'h2;
    
// S_TYPE funct3      
localparam [2:0]
    F3_SW = 3'h2;
    
// B_TYPE funct3      
localparam [2:0]
    BEQ  = 3'h0,
    BNE  = 3'h1,
    BLT  = 3'h4,
    BGE  = 3'h5,
    BLTU = 3'h6,
    BGEU = 3'h7;

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
