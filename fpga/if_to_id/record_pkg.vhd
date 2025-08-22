----------------------------------------------------------------------------------
-- Create Date: 08/22/2025 09:21:27 AM
-- Module Name: record_pkg 
-- Name: Noridel Herron
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package record_pkg is
    type VPI_TYPE is record
        isValid   : std_logic;     
        pc, instr : std_logic_vector(31 downto 0);     
    end record;
    
    type ID_TYPE is record
        op           : std_logic_vector(6 downto 0);     
        rd, rs1, rs2 : std_logic_vector(4 downto 0); 
        memRead      : std_logic;
        memWrite     : std_logic;
        regWrite     : std_logic;
        jump         : std_logic;
        branch       : std_logic;    
        aluOp        : std_logic_vector(3 downto 0);   
        forwA, forwB : std_logic_vector(1 downto 0);  
        stall        : std_logic;  
        operandA     : std_logic_vector(31 downto 0);   
        operandB     : std_logic_vector(31 downto 0);   
        sData        : std_logic_vector(31 downto 0);      
    end record;
    
    type EX_TYPE is record
        rd, rs1, rs2 : std_logic_vector(4 downto 0); 
        regWrite     : std_logic;  
    end record;
    
    type MEM_TYPE is record
        rd           : std_logic_vector(4 downto 0); 
        regWrite     : std_logic;  
    end record;
    
    type WB_TYPE is record
        rd           : std_logic_vector(4 downto 0); 
        regWrite     : std_logic; 
        data         : std_logic_vector(31 downto 0);   
    end record;
    
    constant EMPTY_VPI_TYPE : VPI_TYPE := (
        isValid => '0',
        pc      => (others => '0'),
        instr   =>(others => '0')
    );
    
    constant EMPTY_ID_TYPE : ID_TYPE := (
        op       => (others => '0'),   
        rd       => (others => '0'),
        rs1      => (others => '0'),
        rs2      => (others => '0'),
        memRead  => '0',
        memWrite => '0',
        regWrite => '0',
        jump     => '0',
        branch   => '0',
        aluOp    => (others => '0'),  
        forwA    => (others => '0'),
        forwB    => (others => '0'),
        stall    => '0',
        operandA => (others => '0'),  
        operandB => (others => '0'),
        sData    => (others => '0') 
    );
    
    constant EMPTY_EX_TYPE : EX_TYPE := (
        rd       => (others => '0'),
        rs1      => (others => '0'),
        rs2      => (others => '0'),
        regWrite => '0'
    );
    
    constant EMPTY_MEM_TYPE : MEM_TYPE := (
        rd       => (others => '0'),
        regWrite => '0'
    );
    constant EMPTY_WB_TYPE : WB_TYPE := (
        rd       => (others => '0'),
        regWrite => '0',
        data     => (others => '0')
    );
    
end package;