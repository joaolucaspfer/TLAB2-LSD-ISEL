library ieee;
use ieee.std_logic_1164.all;

entity adder4bit is
    port (
        A  : in  std_logic_vector(3 downto 0);
        B  : in  std_logic_vector(3 downto 0);
        Ci : in  std_logic;
        S  : out std_logic_vector(3 downto 0);
        Co : out std_logic
    );
end adder4bit;

architecture structural of adder4bit is
    component FA
        port (A, B, Ci: in std_logic; S, Co: out std_logic);
    end component;

    signal carry : std_logic_vector(4 downto 0);

begin
    carry(0) <= Ci;
    FA0: FA port map (A => A(0), B => B(0), Ci => carry(0), S => S(0), Co => carry(1));
    FA1: FA port map (A => A(1), B => B(1), Ci => carry(1), S => S(1), Co => carry(2));
    FA2: FA port map (A => A(2), B => B(2), Ci => carry(2), S => S(2), Co => carry(3));
    FA3: FA port map (A => A(3), B => B(3), Ci => carry(3), S => S(3), Co => carry(4));
    Co <= carry(4);
end structural;