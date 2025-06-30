------------------------------------------------------------------------------
-- Noridel Herron
-- 6/7/2025
-- Extracts opcode, registers, function codes, and immediate values from a 32-bit instruction. 
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.initialize_records.all;

entity DECODER is
    Port (  -- inputs 
            ID          : in  std_logic_vector(DATA_WIDTH-1 downto 0);       
            ID_content  : out Decoder_Type      
        );
end DECODER;

architecture behavior of DECODER is

begin             
             
    process (ID)
    variable temp   : Decoder_Type                             := EMPTY_DECODER;
    begin 
        temp.funct7   := ID(31 downto 25);
        temp.rs2      := ID(24 downto 20);
        temp.rs1      := ID(19 downto 15);
        temp.funct3   := ID(14 downto 12);
        temp.rd       := ID(11 downto 7);
        temp.op       := ID(6 downto 0);
        temp.imm12    := ZERO_12bits;
        temp.imm20    := ZERO_20bits;
        
        case temp.op is
            when R_TYPE => 
                temp := temp;
                
            when I_IMME | LOAD | JALR | ECALL => 
                temp.imm12  := ID(31 downto 20);     
                temp.funct7 := ZERO_7bits;
                temp.rs2    := ZERO_5bits;
                
            when S_TYPE => 
                temp.imm12  := ID(31 downto 25) & ID(11 downto 7); 
                temp.funct7 := ZERO_7bits;
                temp.rd     := ZERO_5bits;       
                
            when B_TYPE => 
                temp.imm12  := ID(31) & ID(7) & ID(30 downto 25) & ID(11 downto 8);  
                temp.funct7 := ZERO_7bits;
                temp.rd     := ZERO_5bits;     
                
            when U_LUI | U_AUIPC =>  
                temp.imm20  := ID(31 downto 12); 
            
            when JAL =>  
                temp        := EMPTY_DECODER;
                temp.rd     := ID(11 downto 7);
                temp.op     := ID(6 downto 0);
                temp.imm20  := ID(31) & ID(18 downto 12) & ID(19) & ID(30 downto 20); 
                     
            when others => temp := EMPTY_DECODER;
        end case;

        ID_content <= temp;
    end process;

end behavior;