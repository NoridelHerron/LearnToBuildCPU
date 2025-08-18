----------------------------------------------
-- Noridel Herron
---------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity AnodeControl is
  port (clk         : in std_logic;  
        counter_out : out std_logic_vector (5 downto 0);
        anode       : out std_logic_vector (7 downto 0));
end AnodeControl;

architecture behav of AnodeControl is

signal Anode_temp   : std_logic_vector (7 downto 0) := "11111111";
signal counter      : std_logic_vector (7 downto 0) := "00000000";
signal counter_temp : std_logic_vector (5 downto 0);
signal clk_div      : integer range 0 to 1000 := 0;
signal slow_clk     : std_logic := '0';

begin
    anode <= Anode_temp;
    counter_out <= counter(7) & counter(6) & counter(5) & counter(4) & counter(3) & counter(2);
    counter_temp <= counter(7) & counter(6) & counter(5) & counter(4) & counter(3) & counter(2);
   
   -- slow down the counter, to prevent the shadowing or flickering
    process(clk)
    begin
        if rising_edge(clk) then
          -- solution for a ghosting or flickering
          if clk_div = 1000 then
            clk_div <= 0;
            slow_clk <= not slow_clk;
          else
            clk_div <= clk_div + 1;
          end if;
        end if;
    end process;

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
          if counter = "11111111" then
            counter <= "00000000";
          else
            counter <= counter + 1;
          end if;
        end if;
    end process;

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
          case counter_temp is
            when "000000" => Anode_temp <= "11111110"; 
            when "000011" => Anode_temp <= "11111101"; 
            when "000110" => Anode_temp <= "11111011"; 
            when "001001" => Anode_temp <= "11110111"; 
            when "001100" => Anode_temp <= "11101111"; 
            when "001111" => Anode_temp <= "11011111"; 
            when "010010" => Anode_temp <= "10111111"; 
            when "010101" => Anode_temp <= "01111111"; 
            when others   => Anode_temp <= "11111111"; 
          end case;
        end if;
    end process;
  
end behav;
