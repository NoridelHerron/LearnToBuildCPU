----------------------------------------------
-- Noridel Herron
---------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main is
    Port (  A      : in std_logic_vector(5 downto 0);
            B      : in std_logic_vector(5 downto 0);
            alu_op : in std_logic_vector(3 downto 0);
            Clk    : in std_logic;
            AN     : out std_logic_vector(7 downto 0);
            segment_a, segment_b, segment_c, segment_d, segment_e, segment_f, segment_g, segment_dp : out std_logic);
end main;

architecture Behavioral of main is

--SIGNALS
signal Z, V, N, C : std_logic := '0';

signal anode   : std_logic_vector(7 downto 0);
signal result  : std_logic_vector(31 downto 0);
signal vA, vB  : std_logic_vector(31 downto 0);
signal counter : std_logic_vector (5 downto 0); 
signal segment : std_logic_vector (6 downto 0); 

begin

process (A, B, alu_op)
variable temp_A, temp_B : std_logic_vector(31 downto 0) := (others => '0');
begin
    temp_A := (25 downto 0 => '0') & A;
    temp_B := (25 downto 0 => '0') & B;
    case alu_op is
        when "0111" =>  -- SRA
            if A(5) = '1' then
                temp_A := (25 downto 0 => '1') & temp_A(5 downto 0);
            end if;
        when "1000" =>  -- SLT
            if A(5) = '1' then
                temp_A := (25 downto 0 => '1') & temp_A(5 downto 0);
            end if;
            if B(5) = '1' then
                temp_B := (25 downto 0 => '1') & temp_B(5 downto 0);
            end if;
        when others => -- default
    end case;
    vA <= temp_A;
    vB <= temp_B;
end process;


u_alu_wrapper : entity work.alu_wrapper 
        port map (
                    A      => vA,
                    B      => vB,
                    alu_op => alu_op,
                    result => result,
                    Z      => Z,
                    N      => N,
                    C      => C,
                    V      => V
                );

ANDisplay: entity work.AnodeControl 
    port map (  clk         => Clk, 
                counter_out => counter,  
                anode       => anode);
    
    
LEDDisplay0: entity work.LEDDisplay 
    port map (
                result  => result,
                Z       => Z, 
                N       => N, 
                V       => V, 
                C       => C,
                counter => counter,
                clk     => Clk,
                segment => segment
                );

AN <= anode;
segment_a <= segment(6);
segment_b <= segment(5);
segment_c <= segment(4);
segment_d <= segment(3);
segment_e <= segment(2);
segment_f <= segment(1);
segment_g <= segment(0);
segment_dp <= '1'; 

end Behavioral;
 