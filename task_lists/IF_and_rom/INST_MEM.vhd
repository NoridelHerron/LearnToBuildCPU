----------------------------------------------------------------------------------
-- Noridel Herron
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.ALL;  -- uniform's library

entity INST_MEM is
    Port (
            clk    : in  std_logic;        
            addr   : in  std_logic_vector(31 downto 0);  -- byte address input
            instr  : out std_logic_vector(31 downto 0)   -- instruction output
        );
end INST_MEM;

architecture read_only of INST_MEM is

    -- OPCODE TYPE
    constant R_TYPE : std_logic_vector(6 downto 0) := "0110011";
    constant I_IMME : std_logic_vector(6 downto 0) := "0010011";
    constant LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant S_TYPE : std_logic_vector(6 downto 0) := "0100011";
    constant B_TYPE : std_logic_vector(6 downto 0) := "1100011";
    constant JAL    : std_logic_vector(6 downto 0) := "1101111";
    
    -- f3 for B_TYPE
    constant BEQ  : std_logic_vector(2 downto 0) := "000";
    constant BNE  : std_logic_vector(2 downto 0) := "001";
    constant BLT  : std_logic_vector(2 downto 0) := "100";
    constant BGE  : std_logic_vector(2 downto 0) := "101";
    constant BLTU : std_logic_vector(2 downto 0) := "110";
    constant BGEU : std_logic_vector(2 downto 0) := "111";
    
    type memory_array is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal rom : memory_array := (others => x"00000013");
    signal instr_reg : std_logic_vector(31 downto 0);

begin

    -- synchronous read process
    process(clk)
    begin
        if rising_edge(clk) then  
            instr_reg <= rom(to_integer(unsigned(addr(9 downto 2))));
        end if;
    end process;

    instr <= instr_reg;
    
    ----------------------------------------------------------------
    -- Initialization of ROM using randomized instructions
    ----------------------------------------------------------------
    
    init_rom: process
    variable seed1, seed2       : positive := 1;
    variable rand, rand1, rand2 : real;
    variable opcode             : std_logic_vector(6 downto 0)  := (others => '0');
    variable f3                 : std_logic_vector(2 downto 0)  := (others => '0');
    variable rd, rs1, rs2       : std_logic_vector(4 downto 0)  := (others => '0');
    variable f7                 : std_logic_vector(6 downto 0)  := (others => '0');
    begin
    
        for i in 0 to 18 loop
            -- Generate random value
            uniform(seed1, seed2, rand);
            uniform(seed1, seed2, rand1);
            uniform(seed1, seed2, rand2);
            
            -- Determine the instruction type
            if    rand < 0.1  then opcode := LOAD;
            elsif rand < 0.2  then opcode := S_TYPE;
            elsif rand < 0.3  then opcode := JAL;
            elsif rand < 0.4  then opcode := B_TYPE;
            elsif rand < 0.7  then opcode := I_IMME;
            else opcode := R_TYPE;
            end if;
            
            rd  := std_logic_vector(to_unsigned(integer(rand * 32.0), 5));
            rs1 := std_logic_vector(to_unsigned(integer(rand1 * 32.0), 5));
            rs2 := std_logic_vector(to_unsigned(integer(rand2 * 32.0), 5));
            f3  := std_logic_vector(to_unsigned(integer(rand * 8.0), 3));
            f7  := std_logic_vector(to_unsigned(integer(rand * 128.0), 7));
            
            case opcode is
                when R_TYPE => -- if f3 = 0 choose between add or sub or if f3 is 5 choose between srl or sra
                    if f3 = "000" or f3 = "101" then
                        if rand1 < 0.5 then
                            f7 := x"20"; -- sub | sra
                        else
                            f7 := (others => '0'); -- add | srl
                        end if;
                    end if;
                    
                when B_TYPE => 
                    if    rand2 < 0.1   then f3 := BGEU;
                    elsif rand2 < 0.25  then f3 := BLT;
                    elsif rand2 < 0.4   then f3 := BGE;
                    elsif rand2 < 0.65  then f3 := BLTU;
                    elsif rand2 < 0.8   then f3 := BNE;
                    else f3 := BEQ;
                    end if;
                    
                when S_TYPE => f3 := "010"; -- sw for 32 bits 
                
                when LOAD   => f3 := "010"; -- lw for 32 bits 
                
                when I_IMME => -- if f3 is 5 choose between srli or srai
                    if f3 = "101" then
                        if rand2 < 0.5 then
                            f7 := x"20"; -- srai
                        else
                            f7 := (others => '0'); -- srli
                        end if;
                    end if;
                    
                when others => -- 
            end case;
            rom(i) <= f7 & rs2 & rs1 & f3 & rd & opcode;
            
        end loop; 
        wait; -- process runs once at time 0
        
    end process;

end read_only;