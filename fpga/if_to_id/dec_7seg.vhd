----------------------------------------------
-- Noridel Herron
-------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

-- Hexadecimal to 7 Segment Decoder for LED Display

ENTITY dec_7seg IS
	PORT( 
	     base_16 : IN std_logic_VECTOR(3 DOWNTO 0); 
		 segment : OUT std_logic_VECTOR(6 DOWNTO 0));
END dec_7seg;

ARCHITECTURE structure of dec_7seg is

SIGNAL segment_data : std_logic_VECTOR(6 DOWNTO 0);

BEGIN

	PROCESS  (base_16)
	BEGIN
      CASE base_16 IS
         WHEN "0000" => segment_data <= "1100111"; --P
         WHEN "0001" => segment_data <= "0000110"; --I
         WHEN "0010" => segment_data <= "1001111"; --E
         WHEN "0100" => segment_data <= "0001110"; --L
         WHEN "0111" => segment_data <= "1110110"; --N
         WHEN OTHERS => segment_data <= "1111111"; 
      END CASE;
	END PROCESS;
	segment <= 	NOT segment_data;
	
END structure;