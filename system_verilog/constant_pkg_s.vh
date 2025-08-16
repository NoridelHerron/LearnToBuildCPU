// riscv_constants.vh
`define R_TYPE   7'h33
`define I_IMM    7'h13
`define I_LOAD   7'h03
`define S_TYPE   7'h23
`define B_TYPE   7'h63
`define J_JAL    7'h6f

`define F3_ADD_SUB 3'h0
`define F3_SLT     3'h2
`define F3_SLTU    3'h3
`define F3_SRL_SRA 3'h5
`define F3_LW      3'h2
`define F3_SW      3'h2
`define BEQ        3'h0
`define BNE        3'h1
`define BLT        3'h4
`define BGE        3'h5
`define BLTU       3'h6
`define BGEU       3'h7

`define F7_ADD     7'h00
`define F7_SUB     7'h20
`define F7_SRL     7'h00
`define F7_SRA     7'h20
