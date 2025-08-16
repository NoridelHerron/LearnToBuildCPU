
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_wrapper is
    Port ( 
            A, B       : in  std_logic_vector(31 downto 0);
            alu_op     : in  std_logic_vector(3 downto 0);
            result     : out std_logic_vector(31 downto 0);
            Z, N, C, V : out std_logic 
    );
end alu_wrapper;

architecture Behavioral of alu_wrapper is

    component alu
        port (
                A, B       : in  std_logic_vector(31 downto 0);
                alu_op     : in  std_logic_vector(3 downto 0);
                result     : out std_logic_vector(31 downto 0);
                Z, N, C, V : out std_logic 
            );
    end component;

begin

    u_alu : alu port map (
            A      => A,
            B      => B,
            alu_op => alu_op,
            result => result,
            Z      => Z,
            N      => N,
            C      => C,
            V      => V
        );

end Behavioral;
