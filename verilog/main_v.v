`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 08/21/2025 09:11:55 AM
// Module Name: main_v
// Name: Noridel Herron
//////////////////////////////////////////////////////////////////////////////////


module main_v(
    input              clk, reset, isForw_ON,
    output reg [64:0]  if_stage_out,  
    output reg [196:0] id_stage_out, 
    output reg [259:0] ex_stage_out, 
    output reg [168:0] mem_stage_out, 
    output reg [168:0] wb_stage_out 
    );
    
    wire [64:0]  if_stage;  
    wire [196:0] id_stage; 
    wire [259:0] ex_stage; 
    wire [168:0] mem_stage; 
    wire [168:0] wb_stage;
    
    wire        is_flush;
    wire [31:0] br_target;
    
    // IF Stage
    if_stage_v if_uut(
        .clk(clk),                   
        .reset(reset), 
        .is_flush(is_flush),         
        .is_stall(id_stage[96]), 
        .branch_target(br_target),
        // outputs
        .is_valid(if_stage[64]),     
        .pc(if_stage[31:0]),          
        .instr(if_stage[63:32])
    );
    
    // IF/ID register
    ifid_v ifid_uut(
        .clk(clk),                   
        .reset(reset), 
        .is_flush(is_flush),         
        .is_stall(id_stage[96]),
        .is_valid_in(if_stage[64]),  
        .pc_in(if_stage[31:0]),    
        .instr_in(if_stage[63:32]),   
        // Outputs     
        .is_valid_out(id_stage[196]),  
        .pc_out(id_stage[163:132]),     
        .instr_out(id_stage[195:164])
    );
    
    id_v id_uut(
        .clk(clk),
        .instruction(id_stage[195:164]),         
        .idex_rs1(ex_stage[182:178]),               
        .idex_rs2(ex_stage[177:173]), 
        .idex_rd(ex_stage[187:183]),                 
        .idex_memRead(ex_stage[170]), 
        .exmem_regWrite(mem_stage[98]),   
        .exmem_rd(mem_stage[103:99]),
        .memwb_regWrite(wb_stage[103]),    
        .memwb_rd(wb_stage[100:96]),                  
        .wb_data(wb_stage[31:0]),
        // Outputs
        .op(id_stage[131:125]),          
        .rd(id_stage[124:120]),        
        .rs1(id_stage[119:115]),         
        .rs2(id_stage[114:110]), 
        .mem_read(id_stage[109]),           
        .mem_write(id_stage[108]),   
        .reg_write(id_stage[107]),       
        .jump(id_stage[106]),      
        .branch(id_stage[105]),            
        .alu_op(id_stage[104:101]),       
        .forwA(id_stage[100:99]),              
        .forwB(id_stage[98:97]),       
        .stall(id_stage[96]),              
        .operand1(id_stage[95:64]),  
        .operand2(id_stage[63:32]),        
        .s_data(id_stage[31:0])
    );
    
    idex_v idex_uut(
        .clk(clk),                   
        .reset(reset), 
        .id_isValid(id_stage[196]),     
        .id_pc(id_stage[163:132]),      
        .id_instr(id_stage[195:164]),         
        .id_op(id_stage[131:125]),              
        .id_rd(id_stage[124:120]),               
        .id_rs1(id_stage[119:115]), 
        .id_rs2(id_stage[114:110]),             
        .id_mem_read(id_stage[109]),     
        .id_mem_write(id_stage[108]),  
        .id_reg_write(id_stage[107]),   
        .id_jump(id_stage[106]),           
        .id_branch(id_stage[105]),       
        .id_alu_op(id_stage[104:101]),        
        .id_stall(id_stage[96]),       
        .id_operand1(id_stage[95:64]),   
        .id_operand2(id_stage[63:32]),   
        .id_s_data(id_stage[31:0]),        
        // Outputs
        .ex_isValid(ex_stage[259]),     
        .ex_pc(ex_stage[226:195]),               
        .ex_instr(ex_stage[258:227]),
        .ex_op(ex_stage[194:188]),               
        .ex_rd(ex_stage[187:183]), 
        .ex_rs1(ex_stage[182:178]),             
        .ex_rs2(ex_stage[177:173]),  
        .ex_mem_read(ex_stage[170]),   
        .ex_mem_write(ex_stage[172]), 
        .ex_reg_write(ex_stage[171]), 
        .ex_jump(ex_stage[170]),       
        .ex_branch(ex_stage[169]),       
        .ex_alu_op(ex_stage[167:164]),
        .ex_operand1(ex_stage[163:132]),   
        .ex_operand2(ex_stage[131:100]),  
        .ex_s_data(ex_stage[99:68])
    );
    
     ex_v ex_uut( 
        .alu_op(ex_stage[167:164]),          
        .isForw_ON(isForw_ON),
        .op(ex_stage[194:188]),                  
        .exmem_result(mem_stage[95:64]), 
        .memwb_result(wb_stage[31:0]), 
        .forwA(id_stage[100:99]), 
        .forwB(id_stage[98:97]),            
        .data1(ex_stage[163:132]), 
        .data2(ex_stage[131:100]),         
        .s_data(ex_stage[99:68]),
        // Outputs
        .result(ex_stage[67:36]),          
        .sData(ex_stage[35:4]),
        .Z(ex_stage[3]), .N(ex_stage[2]),          
        .C(ex_stage[1]), .V(ex_stage[0])
    );
    
    exmem_v exmem_uut(
        .clk(clk),                     
        .reset(reset), 
        // Inputs directly from the ID/EX reg
        .ex_isValid(ex_stage[259]),       
        .ex_pc(ex_stage[226:195]), 
        .ex_instr(ex_stage[258:227]),           
        .ex_rd(ex_stage[187:183]),  
        .ex_mem_read(ex_stage[170]),     
        .ex_mem_write(ex_stage[172]), 
        .ex_reg_write(ex_stage[171]),   
        // Inputs directly from the EX STAGE
        .ex_result(ex_stage[67:36]),         
        .ex_sData(ex_stage[35:4]),           
        // Outputs
        .mem_isValid(mem_stage[168]),     
        .mem_pc(mem_stage[135:104]),               
        .mem_instr(mem_stage[167:136]),
        .mem_rd(mem_stage[103:99]),               
        .mem_mem_read(mem_stage[96]),   
        .mem_mem_write(mem_stage[97]),  
        .mem_reg_write(mem_stage[98]), 
        .mem_result( mem_stage[95:64]),       
        .mem_sData(mem_stage[63:32])
    );
    
    
    
    mem_stage_v mem_stage_uut(
        .clk(clk),
        // // Inputs from EX/MEM reg
        .is_memRead(mem_stage[96]),
        .is_memWrite(mem_stage[97]),
        .address(mem_stage[95:64]),
        .S_data(mem_stage[63:32]),
        // Output
        .data_out(mem_stage[31:0])  
    );
    
    memwb_v memwb_uut(
        // Inputs directly from the EX/MEM reg
        .clk(clk),                     
        .reset(reset), 
        .mem_isValid(mem_stage[168]),     
        .mem_pc(mem_stage[135:104]), 
        .mem_instr(mem_stage[167:136]),         
        .mem_rd(mem_stage[103:99]),  
        .mem_mem_read(mem_stage[96]),    
        .mem_mem_write(mem_stage[97]), 
        .mem_reg_write(mem_stage[98]),  
        .mem_aluResult(mem_stage[95:64]), 
        // Input from MEM STAGE
        .mem_memResult(mem_stage[31:0]),    
        // Outputs
        .wb_isValid(wb_stage[168]),       
        .wb_pc(wb_stage[135:104]), 
        .wb_instr(wb_stage[167:136]),           
        .wb_rd(wb_stage[100:96]),  
        .wb_mem_read(wb_stage[101]),     
        .wb_mem_write(wb_stage[102]), 
        .wb_reg_write(wb_stage[103]),   
        .wb_aluResult(wb_stage[95:64]),   
        .wb_memResult(wb_stage[63:32])
    );
   
    WB_v WB_uut(
        // Inputs directly from the MEM/WB reg
        .is_memRead(wb_stage[101]), 
        .is_memWrite(wb_stage[102]), 
        .alu_data(wb_stage[95:64]), 
        .mem_data(wb_stage[63:32]),
        // Outputs
        .wb_data(wb_stage[31:0]) 
    );
    
    always @(*) begin
        if_stage_out  = if_stage;
        id_stage_out  = id_stage;
        ex_stage_out  = ex_stage;
        mem_stage_out = mem_stage;
        wb_stage_out  = wb_stage;
    end;
    
endmodule
