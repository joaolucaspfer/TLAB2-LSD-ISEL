library ieee;
use ieee.std_logic_1164.all;

entity XOR0 is
    port (
        X: in std_logic_vector (3 downto 0);
        OPa: in std_logic;
        A: out std_logic_vector (3 downto 0)
    );
end XOR0;

architecture arch_xor0 of XOR0 is

begin
    -- When OPA=0: pass X; When OPA=1: force 0
    A(0) <= X(0) and (not OPa);
    A(1) <= X(1) and (not OPa);
    A(2) <= X(2) and (not OPa);
    A(3) <= X(3) and (not OPa);

end arch_xor0;