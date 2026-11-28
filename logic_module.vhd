library ieee;
use ieee.std_logic_1164.all;

entity Logic is
    port (
        X  : in  std_logic_vector(3 downto 0);
        Y  : in  std_logic_vector(3 downto 0);
        S0 : in  std_logic;
        S1 : in  std_logic;
        R  : out std_logic_vector(3 downto 0);
        CY : out std_logic
    );
end Logic;

architecture structural of Logic is
    component MUX2_1
        port (A, B: in std_logic_vector(3 downto 0); Sel: in std_logic; S: out std_logic_vector(3 downto 0));
    end component;

    signal and_not_y : std_logic_vector(3 downto 0);
    signal nand_res  : std_logic_vector(3 downto 0);
    signal lsl_res   : std_logic_vector(3 downto 0);
    signal asr_res   : std_logic_vector(3 downto 0);
    signal m0, m1    : std_logic_vector(3 downto 0);
    signal cl0, cl1, cl2 : std_logic_vector(3 downto 0);
    signal r0, r1    : std_logic_vector(3 downto 0);
    signal c0, c1, c2    : std_logic_vector(3 downto 0);
    signal carry_lsl : std_logic;
    signal carry_asr : std_logic;
    signal sel       : std_logic_vector(1 downto 0);

begin
    and_not_y(0) <= X(0) and not Y(0);
    and_not_y(1) <= X(1) and not Y(1);
    and_not_y(2) <= X(2) and not Y(2);
    and_not_y(3) <= X(3) and not Y(3);

    nand_res(0) <= not (X(0) and Y(0));
    nand_res(1) <= not (X(1) and Y(1));
    nand_res(2) <= not (X(2) and Y(2));
    nand_res(3) <= not (X(3) and Y(3));

    L_M0: MUX2_1 port map (A => X, B => X(2 downto 0) & '0', Sel => Y(0), S => m0);
    L_M1: MUX2_1 port map (A => X(1 downto 0) & "00", B => X(0) & "000", Sel => Y(0), S => m1);
    L_M2: MUX2_1 port map (A => m0, B => m1, Sel => Y(1), S => lsl_res);

    CL_M0: MUX2_1 port map (A => "0000", B => "000" & X(3), Sel => Y(0), S => cl0);
    CL_M1: MUX2_1 port map (A => "000" & X(2), B => "000" & X(1), Sel => Y(0), S => cl1);
    CL_M2: MUX2_1 port map (A => cl0, B => cl1, Sel => Y(1), S => cl2);
    carry_lsl <= cl2(0);

    asr_res(3) <= X(3);
    asr_res(2) <= X(3);
    asr_res(1) <= X(2);
    asr_res(0) <= X(1);
    carry_asr <= X(0);

    sel <= S1 & S0;

    R_M0: MUX2_1 port map (A => and_not_y, B => nand_res, Sel => S0, S => r0);
    R_M1: MUX2_1 port map (A => lsl_res, B => asr_res, Sel => S0, S => r1);
    R_M2: MUX2_1 port map (A => r0, B => r1, Sel => S1, S => R);

    CY_M0: MUX2_1 port map (A => "0000", B => "0000", Sel => S0, S => c0);
    CY_M1: MUX2_1 port map (A => "000" & carry_lsl, B => "000" & carry_asr, Sel => S0, S => c1);
    CY_M2: MUX2_1 port map (A => c0, B => c1, Sel => S1, S => c2);

    CY <= c2(0);
end structural;