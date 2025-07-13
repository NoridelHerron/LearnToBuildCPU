----------------------------------------------------------------------------------
-- Noridel Herron
-- Verified
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;

entity ALU is
    Port ( A, B       : in  std_logic_vector(31 downto 0); 
           f3         : in  std_logic_vector(2 downto 0); 
           f7         : in  std_logic_vector(6 downto 0); 
           result     : out std_logic_vector(31 downto 0); 
           Z, N, C, V : out std_logic 
        );
end ALU;

architecture Behavioral of ALU is

-- function 3
constant FUNC3_ADD_SUB : std_logic_vector(2 downto 0) := "000"; 
constant FUNC3_SLL     : std_logic_vector(2 downto 0) := "001";
constant FUNC3_SLT     : std_logic_vector(2 downto 0) := "010";  
constant FUNC3_SLTU    : std_logic_vector(2 downto 0) := "011"; 
constant FUNC3_XOR     : std_logic_vector(2 downto 0) := "100";
constant FUNC3_SRL_SRA : std_logic_vector(2 downto 0) := "101"; 
constant FUNC3_OR      : std_logic_vector(2 downto 0) := "110"; 
constant FUNC3_AND     : std_logic_vector(2 downto 0) := "111";   

-- function 7
constant FUNC7_ADD     : std_logic_vector(6 downto 0) := "0000000"; 
constant FUNC7_SUB     : std_logic_vector(6 downto 0) := "0100000"; 
constant FUNC7_SRL     : std_logic_vector(6 downto 0) := "0000000"; 
constant FUNC7_SRA     : std_logic_vector(6 downto 0) := "0100000"; 

begin
    
    process (A, B, f3, f7)
    variable temp     : unsigned(32 downto 0)           := (others=>'0'); 
    variable temp_res : std_logic_vector(31 downto 0)   := (others=>'0'); 
    variable temp_C, temp_V, temp_N, temp_Z : std_logic := '0';
    begin
        temp_C := '0';
        temp_V := '0';
        case f3 is
            when FUNC3_ADD_SUB =>  -- ADD/SUB
                case f7 is
                    when FUNC7_ADD =>    -- ADD
                        temp     := resize(unsigned(A), 33) + resize(unsigned(B), 33);
                        temp_res := std_logic_vector(temp(31 downto 0));
                        
                        if temp(32) = '1' then 
                            temp_C := '1';  
                        else 
                            temp_C := '0';
                        end if;                      
                        
                        if ((A(31) = B(31)) and (temp_res(31) /= A(31))) then 
                            temp_V := '1'; 
                        else 
                            temp_V := '0';    
                        end if;
  
                    when FUNC7_SUB =>   -- SUB (RISC-V uses 0b0100000 = 32 decimal)
                        temp     := resize(unsigned(A), 33) - resize(unsigned(B), 33);
                        temp_res := std_logic_vector(temp(31 downto 0));
                 
                        if temp(32) = '0' then 
                            temp_C := '1';  -- No borrow → C = 1
                        else 
                            temp_C := '0';  -- Borrow → C = 0
                        end if;
                    
                        if ((A(31) /= B(31)) and (temp_res(31) /= A(31))) then
                            temp_V := '1'; 
                        else 
                            temp_V := '0'; 
                        end if;
  
                    when others => temp_res := (others => '0');
                end case;

            when FUNC3_SLL =>  
                temp_res := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));

            when FUNC3_SLT =>  -- SLT
                if signed(A) < signed(B) then
                    temp_res := (31 downto 1 => '0') & '1';
                else
                    temp_res := (others => '0');
                end if;

            when FUNC3_SLTU =>  -- SLTU
                if unsigned(A) < unsigned(B) then
                    temp_res := (31 downto 1 => '0') & '1';    
                else
                    temp_res := (others => '0');
                end if;

            when FUNC3_XOR => temp_res := A xor B;
               
            when FUNC3_SRL_SRA =>  
                case f7 is
                    when FUNC7_SRL =>    -- SRL
                        temp_res := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
                    when FUNC7_SRA =>   -- SRA
                        temp_res := std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
                    when others =>
                        temp_res := (others => '0');
                end case;

            when FUNC3_OR => temp_res := A or B;
            
            when FUNC3_AND => temp_res := A and B;
             
            when others => temp_res := (others => '0');
        end case;
        
        -- Z flag
        if temp_res = x"00000000" then temp_Z := '1'; else temp_Z := '0'; end if;
        -- N flag
        if temp_res(31) = '1' then temp_N := '1'; else temp_N := '0'; end if;
        
        result <= temp_res;
        Z      <= temp_Z;
        V      <= temp_V;
        C      <= temp_C;
        N      <= temp_N;

    end process;

end Behavioral;
