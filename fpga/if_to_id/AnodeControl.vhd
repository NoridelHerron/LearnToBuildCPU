---------------------------------------------------------------------------------
-- Noridel Herron
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity AnodeControl is
  port ( clk	     : in  std_logic;  
  	     counter_out : out std_logic_vector (2 downto 0);
	     anode	     : out std_logic_vector (7 downto 0)
	   );
end AnodeControl;

architecture behav of AnodeControl is
    signal counter     : unsigned(2 downto 0)         := (others => '0');
    signal an_temp     : std_logic_vector(7 downto 0) := (others => '1'); -- active-low: all OFF

    constant MAX_COUNT : integer := 5000; 
    signal clk_div     : integer range 0 to 5000 := 0;
    signal slow_clk    : std_logic := '0';
begin

    -- Assign outputs
    anode       <= an_temp;
    counter_out <= std_logic_vector(counter);

    -- Clock divider to reduce display flicker
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_div = MAX_COUNT then
                clk_div  <= 0;
                slow_clk <= not slow_clk;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -- Update counter on slow clock (0-7)
    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if counter = 7 then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Anode control logic
    process(counter)
    begin
        case counter is
            when "000"  => an_temp <= "11111110"; -- Digit 0 (rightmost)
            when "001"  => an_temp <= "11111101"; -- Digit 1
            when "010"  => an_temp <= "11111011"; -- Digit 2
            when "011"  => an_temp <= "11110111"; -- Digit 3
            when "100"  => an_temp <= "11101111"; -- Digit 4
            when "101"  => an_temp <= "11011111"; -- Digit 5
            when "110"  => an_temp <= "10111111"; -- Digit 6
            when "111"  => an_temp <= "01111111"; -- Digit 7 (leftmost)
            when others => an_temp <= "11111111"; -- All off
        end case;
    end process;

end behav;
