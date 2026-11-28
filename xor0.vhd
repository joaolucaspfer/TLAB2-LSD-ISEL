library ieee;
use ieee.std_logic_1164.all;

entity Xor0 is
    port (
        X   : in  std_logic_vector(3 downto 0);
        OPA : in  std_logic;
        A   : out std_logic_vector(3 downto 0)
    );
end Xor0;

architecture structural of Xor0 is
begin
    A(0) <= X(0) and not OPA;
    A(1) <= X(1) and not OPA;
    A(2) <= X(2) and not OPA;
    A(3) <= X(3) and not OPA;
end structural;