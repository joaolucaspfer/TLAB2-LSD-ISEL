library ieee;
use ieee.std_logic_1164.all;

entity FA is
    port (
        A  : in  std_logic;
        B  : in  std_logic;
        Ci : in  std_logic;
        S  : out std_logic;
        Co : out std_logic
    );
end FA;

architecture structural of FA is
    component HA
        port (A, B: in std_logic; S, Co: out std_logic);
    end component;

    signal sum_ab : std_logic;
    signal carry  : std_logic_vector(1 downto 0);

begin
    HA1: HA port map (A => A, B => B, S => sum_ab, Co => carry(0));
    HA2: HA port map (A => sum_ab, B => Ci, S => S, Co => carry(1));
    Co <= carry(0) or carry(1);
end structural;