----------------------------------------------
-- Noridel Herron
---------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LEDDisplay is
    PORT (  
            clk , reset  : in  std_logic;
            counter      : in  std_logic_vector(2 downto 0);
            segment      : out std_logic_vector(6 downto 0)
         );
end LEDDisplay;

architecture Behav of LEDDisplay is

-- signals
signal seg_temp, seg1, seg2, seg3, seg4 : std_logic_VECTOR(6 DOWNTO 0) := (others => '0');
signal seg5, seg6, seg7, seg8           : std_logic_VECTOR(6 DOWNTO 0) := (others => '0');

begin
    
    E  : entity work.dec_7seg 
        port map(
                    base_16 => "0010", 
                    segment => seg1
                );
    
    N  : entity work.dec_7seg 
        port map(
                    base_16 => "0111", 
                    segment => seg2
                );
 
    I : entity work.dec_7seg 
        port map(
                    base_16 => "0001", 
                    segment => seg3
                );
                
    L  : entity work.dec_7seg 
        port map(
                    base_16 => "0100", 
                    segment => seg4
                );
               
    -- ID stage PC   
    E2 : entity work.dec_7seg 
        port map(
                    base_16 => "0010", 
                    segment => seg5
                );
                
    P : entity work.dec_7seg 
        port map(
                    base_16 => "0000", 
                    segment => seg6
                );         
    
    I2 : entity work.dec_7seg 
        port map(
                    base_16 => "0001", 
                    segment => seg7
                );
                
   P2 : entity work.dec_7seg 
        port map(
                    base_16 => "0000", 
                    segment => seg8
                ); 
            
    process(clk)
    begin
        if reset = '1' then
            seg_Temp <= "1111111";
        
        elsif rising_edge(clk) then
        
            case counter is
                when "000"  => seg_Temp <= seg1;
                when "001"  => seg_Temp <= seg2;
                when "010"  => seg_Temp <= seg3;
                when "011"  => seg_Temp <= seg4;
                when "100"  => seg_Temp <= seg5;
                when "101"  => seg_Temp <= seg6;
                when "110"  => seg_Temp <= seg7;
                when "111"  => seg_Temp <= seg8;
                when others => seg_Temp <= "0000000";
            end case;
            
        end if;
    end process;

-- send the value out    
segment <= seg_Temp;

end Behav;