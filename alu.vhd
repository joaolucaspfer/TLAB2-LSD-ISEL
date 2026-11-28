library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port (
        X  : in  std_logic_vector(3 downto 0);
        Y  : in  std_logic_vector(3 downto 0);
        OP : in  std_logic_vector(2 downto 0);
        CBi: in  std_logic;
        R  : out std_logic_vector(3 downto 0);
        CBo: out std_logic;
        OV : out std_logic;
        Z  : out std_logic;
        GE : out std_logic;
        BE : out std_logic
    );
end ALU;

architecture structural of ALU is
    component Xor0
        port (X: in std_logic_vector(3 downto 0); OPA: in std_logic; A: out std_logic_vector(3 downto 0));
    end component;
    component AU
        port (A, B: in std_logic_vector(3 downto 0); CBi: in std_logic; OP: in std_logic;
              R: out std_logic_vector(3 downto 0); CBo: out std_logic; OV: out std_logic);
    end component;
    component Logic
        port (X, Y: in std_logic_vector(3 downto 0); S0, S1: in std_logic;
              R: out std_logic_vector(3 downto 0); CY: out std_logic);
    end component;
    component DecodeOP
        port (OP: in std_logic_vector(2 downto 0);
              OPA, OPB, OPC, OPD, OPE, OPF: out std_logic);
    end component;
    component MUX2_1
        port (A, B: in std_logic_vector(3 downto 0); Sel: in std_logic; S: out std_logic_vector(3 downto 0));
    end component;
    component Flags
        port (OP: in std_logic_vector(2 downto 0); R: in std_logic_vector(3 downto 0);
              AU_CBo, AU_OV, CY, OPF: in std_logic;
              CBo, OV, Z, GE, BE: out std_logic);
    end component;

    signal A_AU     : std_logic_vector(3 downto 0);
    signal R_AU     : std_logic_vector(3 downto 0);
    signal R_Logic  : std_logic_vector(3 downto 0);
    signal R_Final  : std_logic_vector(3 downto 0);
    signal AU_CBo   : std_logic;
    signal AU_OV    : std_logic;
    signal CY       : std_logic;
    signal OPA, OPB, OPC, OPD, OPE, OPF : std_logic;

begin
    D0: DecodeOP port map (OP => not OP(2) & OP(1) & OP(0), OPA => OPA, OPB => OPB, OPC => OPC,
                           OPD => OPD, OPE => OPE, OPF => OPF);
    X0: Xor0 port map (X => X, OPA => OPA, A => A_AU);
    U0: AU port map (A => A_AU, B => Y, CBi => not CBi, OP => OPB, R => R_AU, CBo => AU_CBo, OV => AU_OV);
    L0: Logic port map (X => X, Y => Y, S0 => OPD, S1 => OPE, R => R_Logic, CY => CY);
    M0: MUX2_1 port map (A => R_AU, B => R_Logic, Sel => OPC, S => R_Final);
    F0: Flags port map (OP => OP, R => R_Final, AU_CBo => AU_CBo, AU_OV => AU_OV, CY => CY, OPF => OPF,
                        CBo => CBo, OV => OV, Z => Z, GE => GE, BE => BE);
    R <= R_Final;
end structural;