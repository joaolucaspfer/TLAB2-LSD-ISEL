library ieee;
use ieee.std_logic_1164.all;

entity ALU_TB is
end ALU_TB;

architecture tb of ALU_TB is
    component ALU
        port (X, Y: in std_logic_vector(3 downto 0); OP: in std_logic_vector(2 downto 0); CBi: in std_logic;
              R: out std_logic_vector(3 downto 0); CBo, OV, Z, GE, BE: out std_logic);
    end component;

    signal X, Y, R: std_logic_vector(3 downto 0);
    signal OP: std_logic_vector(2 downto 0);
    signal CBi, CBo, OV, Z, GE, BE: std_logic;

begin
    UUT: ALU port map (X => X, Y => Y, OP => OP, CBi => CBi, R => R, CBo => CBo, OV => OV, Z => Z, GE => GE, BE => BE);

    stim: process
    begin
        -- OP=000 ADD: 0 + 15 + 0 = 15
        X <= "0000"; Y <= "1111"; OP <= "000"; CBi <= '0'; wait for 10 ns;
        -- OP=000 ADD: 0 + 15 + 1 = 0 (carry)
        CBi <= '1'; wait for 10 ns;
        -- OP=001 SUB: 0 - 15 - 1 = 0
        X <= "0000"; Y <= "1111"; OP <= "001"; CBi <= '1'; wait for 10 ns;
        -- OP=001 SUB: 1 - 5 - 1 = -5
        X <= "0001"; Y <= "0101"; CBi <= '1'; wait for 10 ns;
        -- OP=010 Y+CBi: 1+0=1
        X <= "0000"; Y <= "0001"; OP <= "010"; CBi <= '0'; wait for 10 ns;
        -- OP=010 Y+CBi: 1+1=2
        CBi <= '1'; wait for 10 ns;
        -- OP=010 Y+CBi: 7+1=8 (overflow)
        Y <= "0111"; wait for 10 ns;
        -- OP=011 -Y-CBi: -0 = 0
        X <= "0000"; Y <= "0000"; OP <= "011"; CBi <= '0'; wait for 10 ns;
        -- OP=011 -Y-CBi: -8 = -8 (overflow)
        Y <= "1000"; wait for 10 ns;
        -- OP=100 AND: 1 & 12 = 0
        X <= "0001"; Y <= "1100"; OP <= "100"; CBi <= '0'; wait for 10 ns;
        -- OP=100 AND: 13 & 9 = 9
        X <= "1101"; Y <= "1001"; wait for 10 ns;
        -- OP=101 NAND: ~(10 & 14) = 5
        X <= "1010"; Y <= "1110"; OP <= "101"; wait for 10 ns;
        -- OP=110 LSL: 9 << 2 = 4
        X <= "1001"; Y <= "0110"; OP <= "110"; wait for 10 ns;
        -- OP=111 ASR: -1 >> 1 = -1
        X <= "1111"; Y <= "0000"; OP <= "111"; CBi <= '0'; wait for 10 ns;

        wait;
    end process;
end tb;