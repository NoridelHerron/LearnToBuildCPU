------------------------------------------------------------------------------
-- Noridel Herron
-- Extracts opcode, registers, function codes, and immediate values from a 32-bit instruction. 
-- Verified
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;

entity DECODER is
    Port (  -- inputs 
            ID      : in  std_logic_vector(31 downto 0);       
            op      : out std_logic_vector(6 downto 0);    -- opcode  
            rd      : out std_logic_vector(4 downto 0);  -- register destination
            funct3  : out std_logic_vector(2 downto 0);    -- type of operation
            rs1     : out std_logic_vector(4 downto 0);  -- register source 1
            rs2     : out std_logic_vector(4 downto 0);  -- register source 2
            funct7  : out std_logic_vector(6 downto 0);    -- type of operation under funct3 
            imm12   : out std_logic_vector(11 downto 0); 
            imm20   : out std_logic_vector(19 downto 0)   
        );
end DECODER;

architecture behavior of DECODER is

    -- OPCODE TYPE
    constant R_TYPE  : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMME  : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD    : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE  : std_logic_vector(6 downto 0) := "0100011";
    constant B_TYPE  : std_logic_vector(6 downto 0) := "1100011";
    constant JAL     : std_logic_vector(6 downto 0) := "1101111";
    constant JALR    : std_logic_vector(6 downto 0) := "1100111";  
    constant U_LUI   : std_logic_vector(6 downto 0) := "0110111";
    constant U_AUIPC : std_logic_vector(6 downto 0) := "0010111";
    constant ECALL   : std_logic_vector(6 downto 0) := "1110111";

begin             
             
    process (ID)
    -- Using variable only works inside a process
    -- we use variables instead of signals because we need to ensure that the decoded values are assigned correctly within the same simulation cycle. 
    variable temp_op      : std_logic_vector(6 downto 0)  := (others => '0');  
    begin 
        temp_op       := ID(6 downto 0);
  
        case temp_op is
        
            when R_TYPE => 
                op      <= temp_op;
                rd      <= ID(11 downto 7);
                funct3  <= ID(14 downto 12);
                rs1     <= ID(19 downto 15);
                rs2     <= ID(24 downto 20);
                funct7  <= ID(31 downto 25);
                imm12   <= (others => '0'); 
                imm20   <= (others => '0'); 
                
            when I_IMME | LOAD | JALR | ECALL =>
                op      <= temp_op;
                rd      <= ID(11 downto 7);
                funct3  <= ID(14 downto 12);
                rs1     <= ID(19 downto 15);
                rs2     <= (others => '0'); 
                funct7  <= (others => '0'); 
                imm12   <= ID(31 downto 20); 
                imm20   <= (others => '0');  
    
            when S_TYPE =>       
                op      <= temp_op;
                rd      <= (others => '0'); 
                funct3  <= ID(14 downto 12);
                rs1     <= ID(19 downto 15);
                rs2     <= ID(24 downto 20);
                funct7  <= (others => '0'); 
                imm12   <= ID(31 downto 25) & ID(11 downto 7); 
                imm20   <= (others => '0');     
                
            when B_TYPE => 
                op      <= temp_op;
                rd      <= (others => '0'); 
                funct3  <= ID(14 downto 12);
                rs1     <= ID(19 downto 15);
                rs2     <= ID(24 downto 20);
                funct7  <= (others => '0'); 
                imm12   <= ID(31) & ID(7) & ID(30 downto 25) & ID(11 downto 8);  
                imm20   <= (others => '0');            
                
            when U_LUI | U_AUIPC => 
                op      <= temp_op;
                rd      <= ID(11 downto 7);
                funct3  <= (others => '0'); 
                rs1     <= (others => '0'); 
                rs2     <= (others => '0'); 
                funct7  <= (others => '0'); 
                imm12   <= (others => '0'); 
                imm20   <= ID(31 downto 12);           
                
            when JAL =>
                op      <= temp_op;
                rd      <= ID(11 downto 7);
                funct3  <= (others => '0'); 
                rs1     <= (others => '0'); 
                rs2     <= (others => '0'); 
                funct7  <= (others => '0'); 
                imm12   <= (others => '0'); 
                imm20   <= ID(31) & ID(19 downto 12) & ID(20) & ID(30 downto 21); 
                
            when others => -- default
                op      <= (others => '0'); 
                rd      <= (others => '0'); 
                funct3  <= (others => '0'); 
                rs1     <= (others => '0'); 
                rs2     <= (others => '0'); 
                funct7  <= (others => '0'); 
                imm12   <= (others => '0'); 
                imm20   <= (others => '0'); 
                
        end case;

    end process;
end behavior;