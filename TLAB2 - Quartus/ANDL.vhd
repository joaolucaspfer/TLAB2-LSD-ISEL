library ieee;
use ieee.std_logic_1164.all;

entity ANDL is
    port(
        A, B: in std_logic_vector (3 downto 0);
        O: out std_logic_vector (3 downto 0)
    );
end ANDL;

architecture arc_andl of ANDL is

begin

    O(0) <= A(0) and B(0);
    O(1) <= A(1) and B(1);
    O(2) <= A(2) and B(2);
    O(3) <= A(3) and B(3);

end arc_andl;