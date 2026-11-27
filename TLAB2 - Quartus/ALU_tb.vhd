library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end ALU_tb;

architecture tb of ALU_tb is

    component ALU is
        port (
            CBi: in std_logic;
            X: in std_logic_vector(3 downto 0);
            Y: in std_logic_vector(3 downto 0);
            OP: in std_logic_vector(2 downto 0);
            R: out std_logic_vector(3 downto 0);
            CBo: out std_logic;
            OV: out std_logic;
            P: out std_logic;
            Z: out std_logic;
            GE: out std_logic;
            BE: out std_logic
        );
    end component;

    signal CBi: std_logic := '0';
    signal X: std_logic_vector(3 downto 0) := "0000";
    signal Y: std_logic_vector(3 downto 0) := "0000";
    signal OP: std_logic_vector(2 downto 0) := "000";
    signal R: std_logic_vector(3 downto 0);
    signal CBo: std_logic;
    signal OV: std_logic;
    signal P: std_logic;
    signal Z: std_logic;
    signal GE: std_logic;
    signal BE: std_logic;

begin

    UUT: ALU port map (
        CBi => CBi,
        X => X,
        Y => Y,
        OP => OP,
        R => R,
        CBo => CBo,
        OV => OV,
        P => P,
        Z => Z,
        GE => GE,
        BE => BE
    );

    stim_proc: process
    begin
        -- Test 1: OP=000 (ADD), CBi=0, X=0, Y=15(-1) -> R=15(-1), CBo=0, OV=0, Z=0
        -- GE = not(R(3) xor OV) = not(1 xor 0) = 0; BE = CBo = 0
        CBi <= '0'; X <= "0000"; Y <= "1111"; OP <= "000";
        wait for 10 ns;
        assert R = "1111" report "Test 1 failed: R" severity error;
        assert CBo = '0' report "Test 1 failed: CBo" severity error;
        assert OV = '0' report "Test 1 failed: OV" severity error;
        assert Z = '0' report "Test 1 failed: Z" severity error;
        assert GE = '0' report "Test 1 failed: GE" severity error;
        assert BE = '0' report "Test 1 failed: BE" severity error;

        -- Test 2: OP=000 (ADD), CBi=1, X=0, Y=15(-1) -> R=0, CBo=1, OV=0, Z=1
        -- GE = not(0 xor 0) = 1; BE = CBo = 1
        CBi <= '1'; X <= "0000"; Y <= "1111"; OP <= "000";
        wait for 10 ns;
        assert R = "0000" report "Test 2 failed: R" severity error;
        assert CBo = '1' report "Test 2 failed: CBo" severity error;
        assert OV = '0' report "Test 2 failed: OV" severity error;
        assert Z = '1' report "Test 2 failed: Z" severity error;
        assert GE = '1' report "Test 2 failed: GE" severity error;
        assert BE = '1' report "Test 2 failed: BE" severity error;

        -- Test 3: OP=000 (ADD), CBi=1, X=5, Y=-8(8) -> R=-2(14), CBo=0, OV=0, Z=0
        -- 5 + (-8) + 1 = -2 = 1110
        CBi <= '1'; X <= "0101"; Y <= "1000"; OP <= "000";
        wait for 10 ns;
        assert R = "1110" report "Test 3 failed: R" severity error;
        assert CBo = '0' report "Test 3 failed: CBo" severity error;
        assert OV = '0' report "Test 3 failed: OV" severity error;
        assert Z = '0' report "Test 3 failed: Z" severity error;

        -- Test 4: OP=000 (ADD), CBi=1, X=-1(15), Y=-6(10) -> R=-6(10), CBo=1, OV=0, Z=0
        -- -1 + (-6) + 1 = -6 = 1010
        CBi <= '1'; X <= "1111"; Y <= "1010"; OP <= "000";
        wait for 10 ns;
        assert R = "1010" report "Test 4 failed: R" severity error;
        assert CBo = '1' report "Test 4 failed: CBo" severity error;
        assert OV = '0' report "Test 4 failed: OV" severity error;
        assert Z = '0' report "Test 4 failed: Z" severity error;

        -- Test 5: OP=001 (SUB), CBi=1, X=0, Y=15(-1) -> R=0 - (-1) - 1 = 0, CBo=1, OV=0, Z=1
        -- GE = not(0 xor 0) = 1; BE = CBo = 1
        CBi <= '1'; X <= "0000"; Y <= "1111"; OP <= "001";
        wait for 10 ns;
        assert R = "0000" report "Test 5 failed: R" severity error;
        assert CBo = '1' report "Test 5 failed: CBo" severity error;
        assert OV = '0' report "Test 5 failed: OV" severity error;
        assert Z = '1' report "Test 5 failed: Z" severity error;
        assert GE = '1' report "Test 5 failed: GE" severity error;
        assert BE = '1' report "Test 5 failed: BE" severity error;

        -- Test 6: OP=001 (SUB), CBi=1, X=1, Y=5 -> R=1-5-1=-5=11(1011), CBo=1 (borrow), OV=0, Z=0
        -- 1 < 5+1=6, so borrow=1. GE = not(1 xor 0) = 0; BE = CBo = 1
        CBi <= '1'; X <= "0001"; Y <= "0101"; OP <= "001";
        wait for 10 ns;
        assert R = "1011" report "Test 6 failed: R" severity error;
        assert CBo = '1' report "Test 6 failed: CBo" severity error;
        assert OV = '0' report "Test 6 failed: OV" severity error;
        assert Z = '0' report "Test 6 failed: Z" severity error;
        assert GE = '0' report "Test 6 failed: GE" severity error;
        assert BE = '1' report "Test 6 failed: BE" severity error;

        -- Test 7: OP=001 (SUB), CBi=1, X=-6(10), Y=7 -> R=-6-7-1=-14=2(0010), CBo=0, OV=1, Z=0
        -- -6 - 7 - 1 = -14, overflow in 4-bit signed
        CBi <= '1'; X <= "1010"; Y <= "0111"; OP <= "001";
        wait for 10 ns;
        assert R = "0010" report "Test 7 failed: R" severity error;
        assert CBo = '0' report "Test 7 failed: CBo" severity error;
        assert OV = '1' report "Test 7 failed: OV" severity error;
        assert Z = '0' report "Test 7 failed: Z" severity error;

        -- Test 8: OP=010 (Y+CBi), CBi=0, X=X, Y=1 -> R=1, CBo=0, OV=0, Z=0
        CBi <= '0'; X <= "0000"; Y <= "0001"; OP <= "010";
        wait for 10 ns;
        assert R = "0001" report "Test 8 failed: R" severity error;
        assert CBo = '0' report "Test 8 failed: CBo" severity error;
        assert OV = '0' report "Test 8 failed: OV" severity error;
        assert Z = '0' report "Test 8 failed: Z" severity error;

        -- Test 9: OP=010 (Y+CBi), CBi=1, X=X, Y=1 -> R=2, CBo=0, OV=0, Z=0
        CBi <= '1'; X <= "0000"; Y <= "0001"; OP <= "010";
        wait for 10 ns;
        assert R = "0010" report "Test 9 failed: R" severity error;
        assert CBo = '0' report "Test 9 failed: CBo" severity error;
        assert OV = '0' report "Test 9 failed: OV" severity error;
        assert Z = '0' report "Test 9 failed: Z" severity error;

        -- Test 10: OP=010 (Y+CBi), CBi=1, X=X, Y=7 -> R=8, CBo=0, OV=1, Z=0
        -- 7+1=8, signed overflow (7 is max positive)
        CBi <= '1'; X <= "0000"; Y <= "0111"; OP <= "010";
        wait for 10 ns;
        assert R = "1000" report "Test 10 failed: R" severity error;
        assert CBo = '0' report "Test 10 failed: CBo" severity error;
        assert OV = '1' report "Test 10 failed: OV" severity error;
        assert Z = '0' report "Test 10 failed: Z" severity error;

        -- Test 11: OP=010 (Y+CBi), CBi=1, X=X, Y=15 -> R=0, CBo=1, OV=0, Z=1
        -- 15+1=16=0 with carry
        CBi <= '1'; X <= "0000"; Y <= "1111"; OP <= "010";
        wait for 10 ns;
        assert R = "0000" report "Test 11 failed: R" severity error;
        assert CBo = '1' report "Test 11 failed: CBo" severity error;
        assert OV = '0' report "Test 11 failed: OV" severity error;
        assert Z = '1' report "Test 11 failed: Z" severity error;

        -- Test 12: OP=011 (-(Y+CBi)), CBi=0, X=X, Y=0 -> R=0, CBo=0, OV=0, Z=1
        -- -(0+0) = 0
        CBi <= '0'; X <= "0000"; Y <= "0000"; OP <= "011";
        wait for 10 ns;
        assert R = "0000" report "Test 12 failed: R" severity error;
        assert CBo = '0' report "Test 12 failed: CBo" severity error;
        assert OV = '0' report "Test 12 failed: OV" severity error;
        assert Z = '1' report "Test 12 failed: Z" severity error;

        -- Test 13: OP=011 (-(Y+CBi)), CBi=0, X=X, Y=-8(8) -> R=-8(8), CBo=1, OV=1, Z=0
        -- -(-8+0) = 8 -> overflow to -8 = 1000. Unsigned: 0-8 borrow=1. Signed: overflow.
        CBi <= '0'; X <= "0000"; Y <= "1000"; OP <= "011";
        wait for 10 ns;
        assert R = "1000" report "Test 13 failed: R" severity error;
        assert CBo = '1' report "Test 13 failed: CBo" severity error;
        assert OV = '1' report "Test 13 failed: OV" severity error;
        assert Z = '0' report "Test 13 failed: Z" severity error;

        -- Test 14: OP=011 (-(Y+CBi)), CBi=1, X=X, Y=6 -> R=-7(9), CBo=1, OV=0, Z=0
        -- -(6+1) = -7 = 1001. Unsigned: 0-7 borrow=1.
        CBi <= '1'; X <= "0000"; Y <= "0110"; OP <= "011";
        wait for 10 ns;
        assert R = "1001" report "Test 14 failed: R" severity error;
        assert CBo = '1' report "Test 14 failed: CBo" severity error;
        assert OV = '0' report "Test 14 failed: OV" severity error;
        assert Z = '0' report "Test 14 failed: Z" severity error;

        -- Test 15: OP=011 (-(Y+CBi)), CBi=1, X=X, Y=-8(8) -> R=7(0111), CBo=1, OV=0, Z=0
        -- Y=-8(1000), CBi=1, Y+CBi = -7(1001), negation = 7(0111).
        -- Unsigned: 0 - 8 - 1 = borrow=1. Signed: 7 in range, no overflow.
        CBi <= '1'; X <= "0000"; Y <= "1000"; OP <= "011";
        wait for 10 ns;
        assert R = "0111" report "Test 15 failed: R" severity error;
        assert CBo = '1' report "Test 15 failed: CBo" severity error;
        assert OV = '0' report "Test 15 failed: OV" severity error;
        assert Z = '0' report "Test 15 failed: Z" severity error;

        -- Test 16: OP=100 (AND), X=1, Y=12 -> R=0, Z=1
        CBi <= '1'; X <= "0001"; Y <= "1100"; OP <= "100";
        wait for 10 ns;
        assert R = "0000" report "Test 16 failed: R" severity error;
        assert Z = '1' report "Test 16 failed: Z" severity error;

        -- Test 17: OP=100 (AND), X=13, Y=9 -> R=9, Z=0
        CBi <= '0'; X <= "1101"; Y <= "1001"; OP <= "100";
        wait for 10 ns;
        assert R = "1001" report "Test 17 failed: R" severity error;
        assert Z = '0' report "Test 17 failed: Z" severity error;

        -- Test 18: OP=101 (NAND), X=10, Y=14 -> R=5, Z=0
        CBi <= '0'; X <= "1010"; Y <= "1110"; OP <= "101";
        wait for 10 ns;
        assert R = "0101" report "Test 18 failed: R" severity error;
        assert Z = '0' report "Test 18 failed: Z" severity error;

        -- Test 19: OP=110 (LSL), X=9, Y=6(Y[1:0]=2) -> X<<2 = 36 mod 16 = 4, CY=0
        CBi <= '0'; X <= "1001"; Y <= "0110"; OP <= "110";
        wait for 10 ns;
        assert R = "0100" report "Test 19 failed: R" severity error;

        -- Test 20: OP=111 (ASR), X=-1(15), Y=X -> X>>1 = -1(15), CY=1
        CBi <= '1'; X <= "1111"; Y <= "0000"; OP <= "111";
        wait for 10 ns;
        assert R = "1111" report "Test 20 failed: R" severity error;
        assert CBo = '1' report "Test 20 failed: CBo (CY)" severity error;

        -- Additional tests for Annex A lines 21-24
        -- Test 21: ADD - 7 + 8 + 0 = 15, CBo=0, OV=0
        CBi <= '0'; X <= "0111"; Y <= "1000"; OP <= "000";
        wait for 10 ns;
        assert R = "1111" report "Test 21 failed: R" severity error;

        -- Test 22: SUB - 5 - 3 - 0 = 2, CBo=0, OV=0
        CBi <= '0'; X <= "0101"; Y <= "0011"; OP <= "001";
        wait for 10 ns;
        assert R = "0010" report "Test 22 failed: R" severity error;

        -- Test 23: LSL - X=3, Y=1 (shift by 1) -> 6
        CBi <= '0'; X <= "0011"; Y <= "0001"; OP <= "110";
        wait for 10 ns;
        assert R = "0110" report "Test 23 failed: R" severity error;

        -- Test 24: ASR - X=-4(12), shift by 1 -> -2(14), CY=0
        CBi <= '0'; X <= "1100"; Y <= "0000"; OP <= "111";
        wait for 10 ns;
        assert R = "1110" report "Test 24 failed: R" severity error;
        assert CBo = '0' report "Test 24 failed: CBo" severity error;

        report "All tests completed!";
        wait;
    end process;

end tb;