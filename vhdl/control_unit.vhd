------------------------------------------------------------------------------
-- Noridel Herron
-- 6/7/2025
-- Generates control signals.
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port ( 
            opcode     : in std_logic_vector(6 downto 0); 
            c_memWrite : out std_logic;
            c_memRead  : out std_logic;
            c_regWrite : out std_logic;
            c_isJump   : out std_logic;
            c_isBranch : out std_logic
         );
end control_unit;

architecture Behavioral of control_unit is

-- OPCODE TYPE
    constant R_TYPE         : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMME         : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD           : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE         : std_logic_vector(6 downto 0) := "0100011";
    constant B_TYPE         : std_logic_vector(6 downto 0) := "1100011";
    constant JAL            : std_logic_vector(6 downto 0) := "1101111";
    constant JALR           : std_logic_vector(6 downto 0) := "1100111";  
    constant U_LUI          : std_logic_vector(6 downto 0) := "0110111";
    constant U_AUIPC        : std_logic_vector(6 downto 0) := "0010111";
    constant ECALL          : std_logic_vector(6 downto 0) := "1110111";

begin

    process (opcode)
    variable c_memWrite_v : std_logic := '0';
    variable c_memRead_v  : std_logic := '0';
    variable c_regWrite_v : std_logic := '0';
    variable c_isJump_v   : std_logic := '0';
    variable c_isBranch_v : std_logic := '0';
    begin   
        case opcode is
            when R_Type | I_IMME=>   
                c_regWrite_v := '1';
       
            when LOAD => 
                c_regWrite_v := '1';
                c_memRead_v  := '1';
                
            when U_LUI | U_AUIPC   =>
                c_regWrite_v := '1';
                
            when S_TYPE =>
                c_memWrite_v := '1';
                
            when B_TYPE =>
                c_isBranch_v := '1';
                
            when JAL |JALR =>
                c_regWrite_v := '1';
                c_isJump_v   := '1';
          
            when others =>
                
        end case;  
        
        c_memWrite <= c_memWrite_v;
        c_memRead  <= c_memRead_v;
        c_regWrite <= c_regWrite_v;
        c_isJump   <= c_isJump_v;
        c_isBranch <= c_isBranch_v;
    end process;
    
end Behavioral;
