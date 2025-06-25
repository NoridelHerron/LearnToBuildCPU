----------------------------------------------------------------------------------
-- Noridel Herron
-- ALU 32-bit with Flags (for EX_STAGE)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CUSTOMIZED PACKAGE
library work;
use work.Pipeline_Types.all;
use work.const_Types.all;
use work.ENUM_T.all; 
use work.initialize_records.all;

entity ALU is
    Port ( 
            input    : in ALU_in;
            output   : out ALU_out
        );
end ALU;

architecture Behavioral of ALU is

begin
    
    process (input)
    variable res_temp : ALU_out := EMPTY_ALU_out;
    variable temp     : unsigned(DATA_WIDTH downto 0);
    begin
        -- C and V flags
        res_temp.C := NONE;
        res_temp.V := NONE;
        case input.f3 is
            when FUNC3_ADD_SUB =>  -- ADD/SUB
                case input.f7 is
                    when FUNC7_ADD =>    -- ADD
                        temp := resize(unsigned(input.A), DATA_WIDTH+1) + 
                                resize(unsigned(input.B), DATA_WIDTH+1);
                        res_temp.result     := std_logic_vector(temp(DATA_WIDTH-1 downto 0));
                        res_temp.operation  := ALU_ADD;
                        if temp(DATA_WIDTH) = '1' then 
                            res_temp.C := Cf; 
                        else 
                            res_temp.C := NONE; 
                        end if;                      
                        
                        if ((input.A(DATA_WIDTH - 1) = input.B(DATA_WIDTH - 1)) and 
                           (res_temp.result(DATA_WIDTH - 1) /= input.A(DATA_WIDTH - 1))) then
                            res_temp.V := V; 
                        else 
                            res_temp.V := NONE; 
                        end if;
  
                    when FUNC7_SUB =>   -- SUB (RISC-V uses 0b0100000 = 32 decimal)
                        temp := resize(unsigned(input.A), DATA_WIDTH+1) - 
                                resize(unsigned(input.B), DATA_WIDTH+1);
                        res_temp.result     := std_logic_vector(temp(DATA_WIDTH-1 downto 0));
                        res_temp.operation  := ALU_SUB;
 
                        if temp(DATA_WIDTH) = '0' then 
                            res_temp.C := Cf;  -- No borrow → C = 1
                        else 
                            res_temp.C := NONE;  -- Borrow → C = 0
                        end if;
                    
                        if ((input.A(DATA_WIDTH - 1) /= input.B(DATA_WIDTH - 1)) and 
                           (res_temp.result(DATA_WIDTH - 1) /= input.A(DATA_WIDTH - 1))) then
                            res_temp.V := V; 
                        else 
                            res_temp.V := NONE; 
                        end if;
  
                    when others =>
                        res_temp := EMPTY_ALU_out;  
                end case;

            when FUNC3_SLL =>  -- SLL
                res_temp.result := std_logic_vector(shift_left(unsigned(input.A), to_integer(unsigned(input.B(SHIFT_WIDTH - 1 downto 0)))));
                res_temp.operation := ALU_SLL;

            when FUNC3_SLT =>  -- SLT
                if signed(input.A) < signed(input.B) then
                    res_temp.result := (DATA_WIDTH - 1 downto 1 => '0') & '1';
                    res_temp.operation := ALU_SLT;
                else
                    res_temp := EMPTY_ALU_out;
                end if;

            when FUNC3_SLTU =>  -- SLTU
                if unsigned(input.A) < unsigned(input.B) then
                    res_temp.result := (DATA_WIDTH - 1 downto 1 => '0') & '1';
                    res_temp.operation := ALU_SLTU;
                else
                    res_temp := EMPTY_ALU_out;
                end if;

            when FUNC3_XOR =>  -- XOR
                res_temp.result := input.A xor input.B;
                res_temp.operation := ALU_XOR;

            when FUNC3_SRL_SRA =>  -- SRL/SRA
                case input.f7 is
                    when FUNC7_SRL =>    -- SRL
                        res_temp.result := std_logic_vector(shift_right(unsigned(input.A), to_integer(unsigned(input.B(SHIFT_WIDTH - 1 downto 0)))));
                        res_temp.operation := ALU_SRL;
                    when FUNC7_SRA =>   -- SRA
                        res_temp.result := std_logic_vector(shift_right(signed(input.A), to_integer(unsigned(input.B(SHIFT_WIDTH - 1 downto 0)))));
                        res_temp.operation := ALU_SRA;
                    when others =>
                        res_temp := EMPTY_ALU_out;
                end case;

            when FUNC3_OR =>  -- OR
                res_temp.result := input.A or input.B;
                res_temp.operation := ALU_OR;

            when FUNC3_AND =>  -- AND
                res_temp.result := input.A and input.B;
                res_temp.operation := ALU_AND;

            when others =>
                res_temp := EMPTY_ALU_out;
        end case;
        
        -- Z flag
        if res_temp.result = ZERO_32bits then res_temp.Z := Z; else res_temp.Z := NONE; end if;
        
        -- N flag
        if res_temp.result(DATA_WIDTH - 1) = ONE then res_temp.N := N; else res_temp.N := NONE; end if;
        
        output <= res_temp;

    end process;

end Behavioral;
