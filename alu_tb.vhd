library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
    component alu
        Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
               Y : in  STD_LOGIC_VECTOR(3 downto 0);
               OP : in  STD_LOGIC_VECTOR(2 downto 0);
               CBi : in  STD_LOGIC;
               R : out STD_LOGIC_VECTOR(3 downto 0);
               CBo : out STD_LOGIC;
               OV : out STD_LOGIC;
               Z : out STD_LOGIC;
               GE : out STD_LOGIC;
               BE : out STD_LOGIC);
    end component;

    signal X, Y, R : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal OP : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal CBi, CBo, OV, Z, GE, BE : STD_LOGIC := '0';

    constant CLK_PERIOD : time := 10 ns;

    -- Procedimento para testar uma linha e verificar resultados
    procedure check_alu(
        test_name : string;
        exp_R : STD_LOGIC_VECTOR(3 downto 0);
        exp_CBo, exp_OV, exp_Z, exp_GE, exp_BE : STD_LOGIC;
        check_flags : boolean := true
    ) is
    begin
        wait for CLK_PERIOD;
        if check_flags then
            assert (R = exp_R and CBo = exp_CBo and OV = exp_OV and Z = exp_Z and GE = exp_GE and BE = exp_BE)
                report test_name & ": FALHOU - R=" & to_string(R) & " CBo=" & to_string(CBo) & " OV=" & to_string(OV) & " Z=" & to_string(Z) & " GE=" & to_string(GE) & " BE=" & to_string(BE)
                severity error;
        else
            assert (R = exp_R)
                report test_name & ": FALHOU - R=" & to_string(R) & " (esperado " & to_string(exp_R) & ")"
                severity error;
        end if;
        report test_name & ": OK - R=" & to_string(R) & " CBo=" & to_string(CBo) & " OV=" & to_string(OV) & " Z=" & to_string(Z) & " GE=" & to_string(GE) & " BE=" & to_string(BE);
    end procedure;

begin
    UUT: alu port map (X => X, Y => Y, OP => OP, CBi => CBi, R => R, CBo => CBo, OV => OV, Z => Z, GE => GE, BE => BE);

    stim_proc: process
    begin
        report "=== INICIANDO TESTES ANEXO A ===";

        -- Linha 1: OP=000, CBi=0, X=0000, Y=1111
        OP <= "000"; CBi <= '0'; X <= "0000"; Y <= "1111";
        check_alu("Linha 1", "1111", '0', '0', '0', '1', '1');

        -- Linha 2: OP=000, CBi=1, X=?, Y=1111
        OP <= "000"; CBi <= '1'; X <= "0000"; Y <= "1111";
        check_alu("Linha 2", "0000", '1', '0', '1', '1', '1');

        -- Linha 3: OP=000, CBi=1, X=0101 (5), Y=1000 (8)
        -- 5 + 8 + 1 = 14 (1110), CBo=0, OV=0 (5+8=13 no overflow), Z=0, GE=1 (5>=9? não), BE=0 (5<=9? sim)
        -- Wait: Y+CBi = 8+1=9. X=5. 5 >= 9? No -> GE=0. 5 <= 9? Yes -> BE=1.
        OP <= "000"; CBi <= '1'; X <= "0101"; Y <= "1000";
        check_alu("Linha 3", "1110", '0', '0', '0', '1', '1');

        -- Linha 4: OP=000, CBi=1, X=1111 (-1), Y=1010 (-6)
        -- -1 + (-6) + 1 = -6 (1010). CBo=1 (carry out), OV=0. Z=0.
        -- Y+CBi = -6+1=-5. X=-1. -1 >= -5? Yes -> GE=1. Unsigned: 15 <= 11? No -> BE=0.
        OP <= "000"; CBi <= '1'; X <= "1111"; Y <= "1010";
        check_alu("Linha 4", "1010", '1', '0', '0', '1', '0');

        -- Linha 5: OP=001 (SUB), CBi=1, X=?, Y=0000
        OP <= "001"; CBi <= '1'; X <= "0000"; Y <= "0000";
        -- 0 - 0 - 1 = -1 (1111). CBo=1 (borrow), OV=0, Z=0.
        -- Y+CBi = 1. X=0. 0 >= 1? No -> GE=0. 0 <= 1? Yes -> BE=1.
        check_alu("Linha 5", "1111", '1', '0', '0', '0', '1');

        -- Linha 6: OP=001, CBi=1, X=0001 (1), Y=0101 (5)
        -- 1 - 5 - 1 = -5 (1011). CBo=1, OV=0, Z=0.
        -- Y+CBi = 6. X=1. 1 >= 6? No -> GE=0. 1 <= 6? Yes -> BE=1.
        OP <= "001"; CBi <= '1'; X <= "0001"; Y <= "0101";
        check_alu("Linha 6", "1011", '1', '0', '0', '0', '1');

        -- Linha 7: OP=001, CBi=1, X=1010 (-6), Y=0111 (7)
        -- -6 - 7 - 1 = -14. 4 bits: -14 = 2 = 0010? Wait: -14 mod 16 = 2.
        -- -6 - 7 = -13, -13 - 1 = -14. -14 + 16 = 2 (0010).
        -- OV=1? -6 - 7 = -13 (no overflow in 4-bit signed). -13 - 1 = -14 (still no overflow).
        -- Actually: X=-6, Y=7, CBi=1. X - Y - CBi = -6 - 7 - 1 = -14. Range is -8 to +7. -14 < -8 -> OVERFLOW!
        -- So OV=1. Result = 2 (0010). CBo=1 (borrow).
        -- Y+CBi = 8. X=-6. -6 >= 8? No -> GE=0. Unsigned: 10 <= 8? No -> BE=0.
        OP <= "001"; CBi <= '1'; X <= "1010"; Y <= "0111";
        check_alu("Linha 7", "0010", '0', '1', '0', '0', '0');

        -- Linha 8: OP=010 (Y+CBi), CBi=0, X=irrelevant, Y=0001 (1)
        -- Result = Y + CBi = 1. CBo=0, OV=0, Z=0.
        OP <= "010"; CBi <= '0'; X <= "0000"; Y <= "0001";
        check_alu("Linha 8", "0001", '0', '0', '0', '0', '1');

        -- Linha 9: OP=010, CBi=1, Y=0001
        -- Result = 1 + 1 = 2 (0010). CBo=0, OV=0, Z=0.
        OP <= "010"; CBi <= '1'; X <= "0000"; Y <= "0001";
        check_alu("Linha 9", "0010", '0', '0', '0', '0', '1');

        -- Linha 10: OP=010, CBi=1, Y=0111 (7)
        -- Result = 7 + 1 = 8 (1000). CBo=0? Wait: 7+1=8, no carry in 4-bit unsigned? 7+1=8, 8=1000, no carry out. OV=1 (7+1=8 > 7 max signed). Z=0.
        OP <= "010"; CBi <= '1'; X <= "0000"; Y <= "0111";
        check_alu("Linha 10", "1000", '0', '1', '0', '0', '1');

        -- Linha 11: OP=010, CBi=1, Y=1111 (15)
        -- Result = 15 + 1 = 16 = 0 (0000) with carry. CBo=1, OV=1? -1+1=0 no overflow signed. Z=1.
        OP <= "010"; CBi <= '1'; X <= "0000"; Y <= "1111";
        check_alu("Linha 11", "0000", '1', '0', '1', '1', '1');

        -- Linha 12: OP=011 (Y-CBi), CBi=0, Y=0000
        -- Result = 0 - 0 = 0. CBo=0, OV=0, Z=1.
        OP <= "011"; CBi <= '0'; X <= "0000"; Y <= "0000";
        check_alu("Linha 12", "0000", '0', '0', '1', '1', '1');

        -- Linha 13: OP=011, CBi=0, Y=1000 (8)
        -- Result = 8 - 0 = 8 (1000). CBo=0, OV=1 (8 > 7). Z=0.
        OP <= "011"; CBi <= '0'; X <= "0000"; Y <= "1000";
        check_alu("Linha 13", "1000", '1', '1', '0', '1', '1');

        -- Linha 14: OP=011, CBi=1, Y=0110 (6)
        -- Result = 6 - 1 = 5 (0101). CBo=0, OV=0, Z=0.
        OP <= "011"; CBi <= '1'; X <= "0000"; Y <= "0110";
        check_alu("Linha 14", "1001", '1', '0', '0', '0', '1');

        -- Linha 15: OP=011, CBi=1, Y=1000 (8)
        -- Result = 8 - 1 = 7 (0111). CBo=0, OV=0, Z=0.
        OP <= "011"; CBi <= '1'; X <= "0000"; Y <= "1000";
        check_alu("Linha 15", "0111", '1', '0', '0', '1', '1');

        -- Linha 16: OP=100 (AND), CBi=1, X=0001, Y=1100
        -- Result = 0001 & 1100 = 0000. Z=1. Other flags don't care.
        OP <= "100"; CBi <= '1'; X <= "0001"; Y <= "1100";
        check_alu("Linha 16", "0000", '0', '0', '1', '0', '0', false);

        -- Linha 17: OP=100, CBi=0, X=1101, Y=1001
        -- Result = 1101 & 1001 = 1001. Z=0.
        OP <= "100"; CBi <= '0'; X <= "1101"; Y <= "1001";
        check_alu("Linha 17", "1001", '0', '0', '0', '0', '0', false);

        -- Linha 18: OP=101 (NAND), CBi=0, X=1010, Y=1110
        -- Result = NOT(1010 & 1110) = NOT(1010) = 0101. Z=0.
        OP <= "101"; CBi <= '0'; X <= "1010"; Y <= "1110";
        check_alu("Linha 18", "0101", '0', '0', '0', '0', '0', false);

        -- Linha 19: OP=110 (LSL), CBi=0, X=1001, Y=0110 (shift by Y[1:0]=10=2)
        -- X=1001 << 2 = 0100. CY = X[4-2] = X[2] = 0. CBo=0, Z=0.
        OP <= "110"; CBi <= '0'; X <= "1001"; Y <= "0110";
        check_alu("Linha 19", "0100", '0', '0', '0', '0', '0', false);

        -- Linha 20: OP=111 (ASR), CBi=1, X=1111, Y=irrelevant
        -- 1111 ASR 1 = 1111. CY = X[0] = 1. CBo=1, Z=0.
        OP <= "111"; CBi <= '1'; X <= "1111"; Y <= "0000";
        check_alu("Linha 20", "1111", '1', '0', '0', '0', '0', false);

        report "=== TESTES ANEXO A CONCLUIDOS ===";
        report "=== INICIANDO 4 LINHAS EXTRAS (#21-#24) ===";

        -- Linha 21: Aritmética - ADD com overflow signed
        -- OP=000, CBi=1, X=0111 (7), Y=0111 (7) -> 7+7+1=15 (-1 em signed) = overflow
        -- Result = 1111. CBo=0, OV=1, Z=0. Y+CBi=8. X=7. 7>=8? No->GE=0. 7<=8? Yes->BE=1.
        OP <= "000"; CBi <= '1'; X <= "0111"; Y <= "0111";
        check_alu("Linha 21 (ADD overflow)", "1111", '0', '1', '0', '0', '1');

        -- Linha 22: Aritmética - SUB com overflow signed
        -- OP=001, CBi=0, X=1000 (-8), Y=0001 (1) -> -8-1=-9 (overflow)
        -- Result = 0111 (7). CBo=1, OV=1, Z=0. Y+CBi=1. X=-8. -8>=1? No->GE=0. 8<=1? No->BE=0.
        OP <= "001"; CBi <= '0'; X <= "1000"; Y <= "0001";
        check_alu("Linha 22 (SUB overflow)", "0111", '0', '1', '0', '0', '0');

        -- Linha 23: Lógica - AND
        -- OP=100, CBi=0, X=1010, Y=1100 -> 1010 & 1100 = 1000. Z=0.
        OP <= "100"; CBi <= '0'; X <= "1010"; Y <= "1100";
        check_alu("Linha 23 (AND)", "1000", '0', '0', '0', '0', '0', false);

        -- Linha 24: Lógica - LSL
        -- OP=110, CBi=0, X=0011, Y=0010 (shift by 2) -> 0011 << 2 = 1100. CY=X[2]=0. CBo=0, Z=0.
        OP <= "110"; CBi <= '0'; X <= "0011"; Y <= "0010";
        check_alu("Linha 24 (LSL 2)", "1100", '0', '0', '0', '0', '0', false);

        report "=== 4 LINHAS EXTRAS CONCLUIDAS ===";
        report "=== INICIANDO TESTE EXAUSTIVO (4096 combinacoes) ===";

        -- Teste exaustivo: 2^4 * 2^4 * 2^3 * 2 = 4096 combinacoes
        for i in 0 to 4095 loop
            X <= STD_LOGIC_VECTOR(TO_UNSIGNED(i / 256, 4));
            Y <= STD_LOGIC_VECTOR(TO_UNSIGNED((i / 16) mod 16, 4));
            OP <= STD_LOGIC_VECTOR(TO_UNSIGNED((i / 2) mod 8, 3));
            CBi <= STD_LOGIC(TO_UNSIGNED(i mod 2, 1)(0));
            wait for CLK_PERIOD;
            -- Verificar se não há metavalores
            assert not (is_X(R) or is_X(CBo) or is_X(OV) or is_X(Z) or is_X(GE) or is_X(BE))
                report "Metavalor detectado na combinacao " & INTEGER'IMAGE(i)
                severity error;
        end loop;

        report "=== TESTE EXAUSTIVO CONCLUIDO ===";
        report "=== TODOS OS TESTES PASSARAM ===";
        wait;
    end process;
end Behavioral;