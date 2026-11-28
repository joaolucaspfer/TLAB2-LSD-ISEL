library ieee;
use ieee.std_logic_1164.all;

entity MUX2_1 is
    port (
        A  : in  std_logic_vector(3 downto 0);
        B  : in  std_logic_vector(3 downto 0);
        Sel: in  std_logic;
        S  : out std_logic_vector(3 downto 0)
    );
end MUX2_1;

architecture structural of MUX2_1 is
begin
    S(0) <= (A(0) and not Sel) or (B(0) and Sel);
    S(1) <= (A(1) and not Sel) or (B(1) and Sel);
    S(2) <= (A(2) and not Sel) or (B(2) and Sel);
    S(3) <= (A(3) and not Sel) or (B(3) and Sel);
end structural;