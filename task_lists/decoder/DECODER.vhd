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
    variable imm12  : std_logic_vector(IMM12_WIDTH-1 downto 0) := ZERO_12bits;
    variable imm20  : std_logic_vector(IMM20_WIDTH-1 downto 0) := ZERO_20bits;
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
            
            when S_TYPE => 
                temp.imm12  := ID(31 downto 25) & ID(11 downto 7);        
                
            when B_TYPE => 
                imm12       := ID(31 downto 25) & ID(11 downto 7); -- or temp.funct7 & temp.rd
                temp.imm12  := imm12(11) & imm12(0) & imm12(10 downto 5) & imm12(4 downto 1);   
                
            when U_LUI | U_AUIPC =>  
                temp.imm20  := ID(31 downto 12); 
            
            when JAL =>  
                imm20       := ID(31 downto 12);
                temp.imm20  := imm20(19) & imm20(7 downto 0) & imm20(8) & imm20(18 downto 9);    
                    
            when others => temp := EMPTY_DECODER;
        end case;

        ID_content <= temp;
    end process;

end behavior;