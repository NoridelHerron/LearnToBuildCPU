----------------------------------------------------------------------------------

-- Create Date: 08/22/2025 09:17:38 AM
-- Module Name: main_wrapper 
-- Name: Noridel Herron
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.record_pkg.all;

entity main_wrapper is
    Port ( 
            clk, reset  : in  std_logic;
            if_vpi      : out VPI_TYPE;
            id_vpi      : out VPI_TYPE;
            id_content  : out ID_TYPE;
            ex_content  : out EX_TYPE;
            mem_content : out MEM_TYPE;
            wb_content  : out WB_TYPE
    );
end main_wrapper;

architecture Behavioral of main_wrapper is

    component main_v
        port (
            clk, reset                        : in  std_logic;
            if_isValid_out                    : out std_logic;
            if_pc_out, if_instr_out           : out std_logic_vector(31 downto 0);
            id_isValid_out                    : out std_logic;
            id_pc_out, id_instr_out           : out std_logic_vector(31 downto 0);
            id_op_out                         : out std_logic_vector(6 downto 0);
            id_rd_out, id_rs1_out, id_rs2_out : out std_logic_vector(4 downto 0);
            id_memRead_out,  id_memWrite_out  : out std_logic;
            id_regWrite_out, id_jump_out      : out std_logic;    
            id_branch_out                     : out std_logic;
            id_aluOp_out                      : out std_logic_vector(3 downto 0);
            id_forwA_out, id_forwB_out        : out std_logic_vector(1 downto 0);
            id_stall_out                      : out std_logic;
            id_operand1_out, id_operand2_out  : out std_logic_vector(31 downto 0);
            id_sData_out                      : out std_logic_vector(31 downto 0);
            ex_rd_out, ex_rs1_out, ex_rs2_out : out std_logic_vector(4 downto 0);
            ex_regWrite_out                   : out std_logic;
            mem_rd_out                        : out std_logic_vector(4 downto 0);
            mem_regWrite_out                  : out std_logic; 
            wb_rd_out                         : out std_logic_vector(4 downto 0);
            wb_regWrite_out                   : out std_logic;
            wb_data_out                       : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    
    u_main_v : main_v port map (
        clk              => clk,
        reset            => reset,
        if_isValid_out   => if_vpi.isValid,
        if_pc_out        => if_vpi.pc,
        if_instr_out     => if_vpi.instr,
        id_isValid_out   => id_vpi.isValid,
        id_pc_out        => id_vpi.pc,
        id_instr_out     => id_vpi.instr,
        id_op_out        => id_content.op,
        id_rd_out        => id_content.rd,
        id_rs1_out       => id_content.rs1,
        id_rs2_out       => id_content.rs2,
        id_memRead_out   => id_content.memRead,
        id_memWrite_out  => id_content.memWrite,
        id_regWrite_out  => id_content.regWrite,
        id_jump_out      => id_content.jump,
        id_branch_out    => id_content.branch,
        id_aluOp_out     => id_content.aluOp,
        id_forwA_out     => id_content.forwA,
        id_forwB_out     => id_content.forwB,
        id_stall_out     => id_content.stall,
        id_operand1_out  => id_content.operandA,
        id_operand2_out  => id_content.operandB,
        id_sData_out     => id_content.sData,
        ex_rd_out        => ex_content.rd,
        ex_rs1_out       => ex_content.rs1,
        ex_rs2_out       => ex_content.rs2,
        ex_regWrite_out  => ex_content.regWrite,
        mem_rd_out       => mem_content.rd,
        mem_regWrite_out => mem_content.regWrite,
        wb_rd_out        => wb_content.rd,
        wb_regWrite_out  => wb_content.regWrite,
        wb_data_out      => wb_content.data
        );


end Behavioral;
