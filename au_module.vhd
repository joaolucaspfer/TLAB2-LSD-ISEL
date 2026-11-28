library ieee;
use ieee.std_logic_1164.all;

entity AU is
    port (
        A    : in  std_logic_vector(3 downto 0);
        B    : in  std_logic_vector(3 downto 0);
        CBi  : in  std_logic;
        OP   : in  std_logic;
        R    : out std_logic_vector(3 downto 0);
        CBo  : out std_logic;
        OV   : out std_logic
    );
end AU;

architecture structural of AU is
    component adder4bit
        port (A, B: in std_logic_vector(3 downto 0); Ci: in std_logic; S: out std_logic_vector(3 downto 0); Co: out std_logic);
    end component;

    signal Bx     : std_logic_vector(3 downto 0);
    signal Ci_aux : std_logic;
    signal Co_aux : std_logic;
    signal res    : std_logic_vector(3 downto 0);

begin
    Bx(0) <= B(0) xor OP;
    Bx(1) <= B(1) xor OP;
    Bx(2) <= B(2) xor OP;
    Bx(3) <= B(3) xor OP;

    Ci_aux <= CBi xor OP;

    ADD0: adder4bit port map (A => A, B => Bx, Ci => Ci_aux, S => res, Co => Co_aux);

    R   <= res;
    CBo <= Co_aux xor OP;
    OV  <= (not (A(3) xor Bx(3))) and (res(3) xor A(3));
end structural;