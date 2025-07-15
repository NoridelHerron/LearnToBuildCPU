----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_STA is 
    Port (   
            clk         : in  std_logic; 
            is_memRead  : in  std_logic;  
            is_memWrite : in  std_logic;  
            address     : in  std_logic_vector(31 downto 0); 
            S_data      : in  std_logic_vector(31 downto 0); 
            -- Outputs to MEM/WB pipeline register
            data_out    : out std_logic_vector(31 downto 0)
          );
end MEM_STA;

architecture Behavioral of MEM_STA is

begin

    -- Memory instance
    memory_block : entity work.DATA_MEM
        port map (
                    clk         => clk,
                    mem_read    => is_memRead,
                    mem_write   => is_memWrite,
                    address     => address(11 downto 2),  -- directly extract the value
                    write_data  => S_data,
                    read_data   => data_out
                );
   
end Behavioral;
