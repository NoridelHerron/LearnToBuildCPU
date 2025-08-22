----------------------------------------------
-- Noridel Herron
-------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

-- decimal to 7 Segment Decoder for LED Display

ENTITY dec_7seg IS
	PORT( 
	     base_10 : IN std_logic_VECTOR(3 DOWNTO 0); 
		 segment : OUT std_logic_VECTOR(6 DOWNTO 0));
END dec_7seg;

ARCHITECTURE structure of dec_7seg is

SIGNAL segment_data : std_logic_VECTOR(6 DOWNTO 0);

BEGIN

	PROCESS  (base_10)
		-- decimal to 7 Segment Decoder for LED Display	
	BEGIN
      CASE base_10 IS
         WHEN "0000" =>
             segment_data <= "1111110";
         WHEN "0001" =>
             segment_data <= "0110000";
         WHEN "0010" =>
             segment_data <= "1101101";
         WHEN "0011" =>
             segment_data <= "1111001";
         WHEN "0100" =>
             segment_data <= "0110011";
         WHEN "0101" =>
             segment_data <= "1011011";
         WHEN "0110" =>
             segment_data <= "1011111";
         WHEN "0111" =>
             segment_data <= "1110000";
         WHEN "1000" =>
             segment_data <= "1111111";
         WHEN "1001" =>
             segment_data <= "1111011"; 
         WHEN "1101" =>
             segment_data <= "0000101";
         WHEN "1110" =>
             segment_data <= "1001111";    
         WHEN "1111" =>
             segment_data <= "0000001";
         WHEN OTHERS =>
             segment_data <= "1001111";
      END CASE;
	END PROCESS;
	segment <= 	NOT segment_data;
	
END structure;

