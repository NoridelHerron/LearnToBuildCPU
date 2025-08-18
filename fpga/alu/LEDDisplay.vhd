----------------------------------------------
-- Noridel Herron
---------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LEDDisplay is
    PORT (  
            result      : in  std_logic_vector(31 downto 0);
            Z, N, V, C  : in  std_logic;
            counter     : in  std_logic_vector(5 downto 0); 
            clk         : in  std_logic;
            segment     : out std_logic_vector(6 downto 0)
         );
end LEDDisplay;

architecture Behav of LEDDisplay is

-- signals
signal seg_1, seg_2, seg_3, seg_4, seg_5, seg_6, seg_7, seg_temp, seg_sign : std_logic_VECTOR(6 DOWNTO 0);
signal hundreds, tens, ones, sign, Zf, Vf, Nf, Cf                          : std_logic_vector(3 downto 0);
signal value                                                               : integer range 0 to 999;

begin
    
-- convert the result to integer    
value      <= to_integer(abs(signed(result)));
hundreds   <= std_logic_vector(to_unsigned((value / 100) mod 10, 4));
tens       <= std_logic_vector(to_unsigned((value / 10) mod 10, 4));
ones       <= std_logic_vector(to_unsigned(value mod 10, 4));
    
sign <= "1111" when result(31) = '1' else "0000";
Zf   <= "000" & Z;
Vf   <= "000" & V;
Cf   <= "000" & C;
Nf   <= "000" & N;

    Place_sign     : entity work.dec_7seg 
        port map(
                    base_10 => sign, 
                    segment => seg_sign
                );
    
    Place_ones     : entity work.dec_7seg 
        port map(
                    base_10 => ones, 
                    segment => seg_1
                );
        
    Place_ten      : entity work.dec_7seg 
        port map(
                    base_10 => tens, 
                    segment => seg_2
                );
        
    Place_hundred  : entity work.dec_7seg 
        port map(
                    base_10 => hundreds, 
                    segment => seg_3
                );
                
    Place_Z : entity work.dec_7seg 
        port map(
                    base_10 => Zf, 
                    segment => seg_4
                );
                
    Place_V : entity work.dec_7seg 
        port map(
                    base_10 => Vf, 
                    segment => seg_5
                );
                
    Place_C : entity work.dec_7seg 
        port map(
                    base_10 => Cf, 
                    segment => seg_6
                );
                
    Place_N : entity work.dec_7seg 
        port map(
                    base_10 => Nf, 
                    segment => seg_7
                );
            
    process(clk)
    begin
        if rising_edge(clk) then
            case counter is
                -- Display ones value regardless the value
                when "000000" => seg_temp <= seg_1;
                
                -- Only display something if the value in tens is atleast one
                when "000011" => 
                    if tens > "0000" then 
                        seg_temp <= seg_2;
                    elsif sign = "1111" then
                        seg_temp <= seg_sign; 
                    else 
                        seg_temp <= "1111111"; 
                    end if;
                
                -- Only display something if the value in hundreds is atleast one
                when "000110" => 
                    if hundreds > "0000" then 
                        seg_temp <= seg_3;
                    elsif sign = "1111" and tens > "0000" then
                        seg_temp <= seg_sign; 
                    else 
                        seg_temp <= "1111111"; 
                    end if;
                
                -- display only the negative sign 
                when "001001" =>                    
                    if hundreds > "0000" and sign = "1111" then
                        seg_temp <= seg_sign; 
                    else
                        seg_temp <= "1111111";
                    end if;
                    
                when "001100" => seg_temp <= seg_4; -- Z
                when "001111" => seg_temp <= seg_5; -- V
                when "010010" => seg_temp <= seg_6; -- C   
                when "010101" => seg_temp <= seg_7; -- N
                
                when others => seg_temp <= "1111111";
            end case;
        end if;
    end process;

-- send the value out    
segment <= seg_temp;

end Behav;
