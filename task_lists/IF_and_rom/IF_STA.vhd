----------------------------------------------------------------------------------
-- Noridel Herron
-- Basic Instruction Fetch (IF) Stage
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_STA is
    Port ( 
           clk         : in  std_logic; 
           reset       : in  std_logic;
           is_flush    : in  std_logic;  
           is_stall    : in  std_logic;
           br_target   : in  std_logic_vector(31 downto 0);    
           is_valid    : out std_logic;
           pc          : out std_logic_vector(31 downto 0);  
           instruction : out std_logic_vector(31 downto 0)
         ); 

end IF_STA;

architecture behavior of IF_STA is
    
    signal pc_fetch         : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_current       : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_reg        : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_fetched    : std_logic_vector(31 downto 0) := (others => '0');
    signal temp_is_valid    : std_logic                     := '0';
    signal temp_pc          : std_logic_vector(31 downto 0) := (others => '0');
    signal temp_instruction : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    process(clk)
    begin
        if reset = '1' then
            pc_fetch         <= (others => '0');
            temp_is_valid    <= '0';
            temp_instruction <= (others => '0');
            
        elsif rising_edge(clk) then
            
            -- is flush is for branch or jal
            if is_flush = '1' then      
                pc_fetch         <= br_target;  
                temp_is_valid    <= '0';
                temp_pc          <= (others => '0');
                temp_instruction <= (others => '0');
                pc_current       <= pc_fetch; 
                instr_reg        <= x"00000013"; -- NOP
               
            elsif is_stall = '0' then   
                -- normal flow
                if pc_fetch = x"00000000" or pc_current = x"00000000" then
                    temp_is_valid  <= '0';      
                else  
                    temp_is_valid  <= '1';    
                end if; 
                
                instr_reg        <= instr_fetched;
                pc_fetch         <= std_logic_vector(unsigned(pc_fetch) + 4);
                pc_current       <= pc_fetch;
                temp_pc          <= pc_current;
                temp_instruction <= instr_reg; 
             end if;
        end if;
        temp_pc <= pc_fetch;
    end process;

    -- Instantiate instruction memory
    MEM : entity work.INST_MEM port map (
        clk   => clk,
        addr  => pc_fetch,
        instr => instr_fetched
    );

    -- Assign outputs
    is_valid    <= temp_is_valid;
    pc          <= temp_pc;
    instruction <= temp_instruction;
    
end behavior;