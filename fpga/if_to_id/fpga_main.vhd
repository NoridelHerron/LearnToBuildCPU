----------------------------------------------
-- Noridel Herron
---------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- CUSTOMIZED PACKAGE
library work;
use work.record_pkg.all;

entity fpga_main is
    Port ( 
            clk, reset : in  std_logic;
            AN         : out std_logic_vector(7 downto 0);
            led        : out std_logic_vector(15 downto 0);
            segment_a, segment_b, segment_c, segment_d, segment_e, segment_f, segment_g, segment_dp : out std_logic
         );
end fpga_main;

architecture Behavioral of fpga_main is

-- OPCODE TYPE
constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
constant I_IMME : std_logic_vector(6 downto 0) := "0010011";
constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";
constant B_TYPE : std_logic_vector(6 downto 0) := "1100011";
constant J_TYPE : std_logic_vector(6 downto 0) := "1101111";

--SIGNALS
signal if_vpi      : VPI_TYPE  := EMPTY_VPI_TYPE;
signal id_vpi      : VPI_TYPE  := EMPTY_VPI_TYPE;
signal id_content  : ID_TYPE   := EMPTY_ID_TYPE;
signal ex_content  : EX_TYPE   := EMPTY_EX_TYPE;
signal mem_content : MEM_TYPE  := EMPTY_MEM_TYPE;
signal wb_content  : WB_TYPE   := EMPTY_WB_TYPE;

signal counter     : std_logic_vector (2 downto 0) := (others => '0'); 
signal anode       : std_logic_vector (7 downto 0) := (others => '0'); 
signal seg_temp    : std_logic_vector (6 downto 0) := (others => '0');

signal clk_div     : std_logic_vector(23 downto 0) := (others => '0');
signal slow_clkLed : std_logic                     := '0';


begin
    process (clk)
    begin
        if rising_edge(clk) then
            clk_div     <= std_logic_vector(unsigned(clk_div) + 1);
            slow_clkLed <= clk_div(23);  -- Pick the MSB for very slow toggling
        end if;
    end process;
    
    u_main_wrapper : entity work.main_wrapper 
            port map (
                        clk         => clk,
                        reset       => reset,
                        if_vpi      => if_vpi,
                        id_vpi      => id_vpi,
                        id_content  => id_content,
                        ex_content  => ex_content,
                        mem_content => mem_content,
                        wb_content  => wb_content
                    );
    
    ANDisplay: entity work.AnodeControl 
        port map (  
                     clk	     => clk, 
                     counter_out => counter, 
                     anode	     => anode
                 );
        
    LEDDisplay0: entity work.LEDDisplay 
        port map (
                    clk	        => clk, 
                    reset       => reset, 
                    counter     => counter,
                    segment     => seg_temp
                    );
                    
    process(slow_clkLed)
    begin
        if rising_edge(slow_clkLed) then
            -- Clear all LEDs first
            led <= (others => '0');
            
            -- Instruction type
            case id_content.op is 
                when R_TYPE => led(0) <= '1';
                when S_TYPE => led(1) <= '1';
                when B_TYPE => led(2) <= '1';
                when J_TYPE => led(3) <= '1';
                when LOAD   => led(4) <= '1';
                when others => led(5) <= '1'; -- I-type
            end case;
    
            -- Control signals
            if id_content.memRead  = '1' then led(6)  <= '1'; end if;
            if id_content.memWrite = '1' then led(7)  <= '1'; end if;
            if id_content.regWrite = '1' then led(8)  <= '1'; end if;
            if id_content.jump     = '1' then led(9)  <= '1'; end if;
            if id_content.branch   = '1' then led(10) <= '1'; end if;
    
            -- Forwarding
            case id_content.forwA is
                when "01" => led(11) <= '1'; -- EX_MEM
                when "10" => led(13) <= '1'; -- MEM_WB
                when others =>
                    led(11) <= '0';
                    led(13) <= '0';
            end case;
    
            case id_content.forwB is
                when "01" => led(12) <= '1'; -- EX_MEM
                when "10" => led(14) <= '1'; -- MEM_WB
                when others =>
                    led(12) <= '0';
                    led(14) <= '0';
            end case;
    
            -- Stalling
            if id_content.stall = '1' then
                led(15) <= '1';
            end if;
        end if;
    end process;
    
    
    AN        <= anode;
    segment_a <= seg_temp(6);
    segment_b <= seg_temp(5);
    segment_c <= seg_temp(4);
    segment_d <= seg_temp(3);
    segment_e <= seg_temp(2);
    segment_f <= seg_temp(1);
    segment_g <= seg_temp(0);
    segment_dp <= '1'; -- turn OFF decimal point (active-low display)
    
end Behavioral;
 