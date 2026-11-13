library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xor0 is
    Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
           OPA : in  STD_LOGIC;
           A : out STD_LOGIC_VECTOR(3 downto 0));
end xor0;

architecture Behavioral of xor0 is
begin
    A <= X when OPA = '0' else "0000";
end Behavioral;