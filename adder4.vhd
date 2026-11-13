library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder4 is
    Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
           B : in  STD_LOGIC_VECTOR(3 downto 0);
           Cin : in  STD_LOGIC;
           S : out STD_LOGIC_VECTOR(3 downto 0);
           Cout : out STD_LOGIC);
end adder4;

architecture Structural of adder4 is
    component full_adder
        Port ( A : in  STD_LOGIC;
               B : in  STD_LOGIC;
               Cin : in  STD_LOGIC;
               S : out STD_LOGIC;
               Cout : out STD_LOGIC);
    end component;

    signal C : STD_LOGIC_VECTOR(4 downto 0);
begin
    C(0) <= Cin;

    FA0: full_adder port map (A(0), B(0), C(0), S(0), C(1));
    FA1: full_adder port map (A(1), B(1), C(1), S(1), C(2));
    FA2: full_adder port map (A(2), B(2), C(2), S(2), C(3));
    FA3: full_adder port map (A(3), B(3), C(3), S(3), C(4));

    Cout <= C(4);
end Structural;