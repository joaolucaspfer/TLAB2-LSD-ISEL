library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1_4bit is
    Port ( AU_R : in  STD_LOGIC_VECTOR(3 downto 0);
           Logic_R : in  STD_LOGIC_VECTOR(3 downto 0);
           SEL : in  STD_LOGIC;
           R : out STD_LOGIC_VECTOR(3 downto 0));
end mux2to1_4bit;

architecture Behavioral of mux2to1_4bit is
begin
    R <= AU_R when SEL = '0' else Logic_R;
end Behavioral;