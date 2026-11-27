library ieee;
use ieee.std_logic_1164.all;

entity LSL is
    port(
        A: in std_logic_vector (3 downto 0);
        SHIFT: in std_logic_vector (1 downto 0);
        O: out std_logic_vector (3 downto 0);
        CY: out std_logic
    );
end LSL;

architecture arc_lsl of LSL is

    signal s0, s1, s2, s3: std_logic_vector(3 downto 0);
    signal c0, c1, c2, c3: std_logic;

begin

    s0 <= A;
    c0 <= '0';

    s1(0) <= '0';
    s1(1) <= A(0);
    s1(2) <= A(1);
    s1(3) <= A(2);
    c1 <= A(3);

    s2(0) <= '0';
    s2(1) <= '0';
    s2(2) <= A(0);
    s2(3) <= A(1);
    c2 <= A(2);

    s3(0) <= '0';
    s3(1) <= '0';
    s3(2) <= '0';
    s3(3) <= A(0);
    c3 <= A(1);

    -- 4-to-1 MUX using boolean logic
    O(0) <= (not SHIFT(1) and not SHIFT(0) and s0(0)) or
            (not SHIFT(1) and SHIFT(0) and s1(0)) or
            (SHIFT(1) and not SHIFT(0) and s2(0)) or
            (SHIFT(1) and SHIFT(0) and s3(0));

    O(1) <= (not SHIFT(1) and not SHIFT(0) and s0(1)) or
            (not SHIFT(1) and SHIFT(0) and s1(1)) or
            (SHIFT(1) and not SHIFT(0) and s2(1)) or
            (SHIFT(1) and SHIFT(0) and s3(1));

    O(2) <= (not SHIFT(1) and not SHIFT(0) and s0(2)) or
            (not SHIFT(1) and SHIFT(0) and s1(2)) or
            (SHIFT(1) and not SHIFT(0) and s2(2)) or
            (SHIFT(1) and SHIFT(0) and s3(2));

    O(3) <= (not SHIFT(1) and not SHIFT(0) and s0(3)) or
            (not SHIFT(1) and SHIFT(0) and s1(3)) or
            (SHIFT(1) and not SHIFT(0) and s2(3)) or
            (SHIFT(1) and SHIFT(0) and s3(3));

    CY <= (not SHIFT(1) and not SHIFT(0) and c0) or
          (not SHIFT(1) and SHIFT(0) and c1) or
          (SHIFT(1) and not SHIFT(0) and c2) or
          (SHIFT(1) and SHIFT(0) and c3);

end arc_lsl;