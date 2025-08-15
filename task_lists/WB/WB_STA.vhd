----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WB_STA is
    Port (
            is_memRead   : in std_logic;
            is_memWrite  : in std_logic;
            mem_data     : in  std_logic_vector(31 downto 0);  
            alu_data     : in  std_logic_vector(31 downto 0); 
            wb_data      : out std_logic_vector(31 downto 0)
         );
end WB_STA;

architecture Behavioral of WB_STA is

begin
    -- chooses which data to send based on the control signal
    wb_data <= mem_data when is_memRead = '1' or is_memWrite = '1' else alu_data;      

end Behavioral;