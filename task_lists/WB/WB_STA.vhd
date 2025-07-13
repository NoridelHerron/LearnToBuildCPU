----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WB_STA is
    Port (
            is_regWrite  : in std_logic;
            is_memRead   : in std_logic;
            mem_data     : in  std_logic_vector(31 downto 0);  
            alu_data     : in  std_logic_vector(31 downto 0); 
            wb_data      : out std_logic_vector(31 downto 0)
         );
end WB_STA;

architecture Behavioral of WB_STA is

begin
    -- chooses which data to send based on the control signal
    process(is_regWrite, is_memRead, mem_data, alu_data)
    begin
        if is_regWrite = '1' and is_memRead = '1'then
            wb_data <= mem_data;       
        else
            wb_data <= alu_data;            
        end if;
    end process;
    
end Behavioral;