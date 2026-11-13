library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu is
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
end alu;

architecture Structural of alu is
    component xor0
        Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
               OPA : in  STD_LOGIC;
               A : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component au_module
        Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
               B : in  STD_LOGIC_VECTOR(3 downto 0);
               CBi : in  STD_LOGIC;
               AUOp : in  STD_LOGIC;
               R : out STD_LOGIC_VECTOR(3 downto 0);
               CBo : out STD_LOGIC;
               OV : out STD_LOGIC);
    end component;

    component logic_module
        Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
               Y : in  STD_LOGIC_VECTOR(3 downto 0);
               OPF : in  STD_LOGIC;
               OPE : in  STD_LOGIC;
               OPD : in  STD_LOGIC;
               R : out STD_LOGIC_VECTOR(3 downto 0);
               CY : out STD_LOGIC);
    end component;

    component decode_op
        Port ( OP : in  STD_LOGIC_VECTOR(2 downto 0);
               OPA : out STD_LOGIC;
               OPB : out STD_LOGIC;
               OPC : out STD_LOGIC;
               OPD : out STD_LOGIC;
               OPE : out STD_LOGIC;
               OPF : out STD_LOGIC);
    end component;

    component flags_alu
        Port ( AU_CBo : in  STD_LOGIC;
               AU_OV  : in  STD_LOGIC;
               R      : in  STD_LOGIC_VECTOR(3 downto 0);
               Logic_CY : in  STD_LOGIC;
               X      : in  STD_LOGIC_VECTOR(3 downto 0);
               Y      : in  STD_LOGIC_VECTOR(3 downto 0);
               CBi    : in  STD_LOGIC;
               OP     : in  STD_LOGIC_VECTOR(2 downto 0);
               CBo    : out STD_LOGIC;
               OV     : out STD_LOGIC;
               Z      : out STD_LOGIC;
               GE     : out STD_LOGIC;
               BE     : out STD_LOGIC);
    end component;

    component mux2to1_4bit
        Port ( AU_R : in  STD_LOGIC_VECTOR(3 downto 0);
               Logic_R : in  STD_LOGIC_VECTOR(3 downto 0);
               SEL : in  STD_LOGIC;
               R : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    -- Sinais internos
    signal A : STD_LOGIC_VECTOR(3 downto 0);
    signal AU_R : STD_LOGIC_VECTOR(3 downto 0);
    signal Logic_R : STD_LOGIC_VECTOR(3 downto 0);
    signal AU_CBo, AU_OV : STD_LOGIC;
    signal Logic_CY : STD_LOGIC;
    signal OPA, OPB, OPC, OPD, OPE, OPF : STD_LOGIC;
begin
    -- Instanciação dos componentes
    U_XOR0: xor0 port map (X => X, OPA => OPA, A => A);
    U_DECODE: decode_op port map (OP => OP, OPA => OPA, OPB => OPB, OPC => OPC, OPD => OPD, OPE => OPE, OPF => OPF);
    U_AU: au_module port map (A => A, B => Y, CBi => CBi, AUOp => OPC, R => AU_R, CBo => AU_CBo, OV => AU_OV);
    U_LOGIC: logic_module port map (X => X, Y => Y, OPF => OPF, OPE => OPE, OPD => OPD, R => Logic_R, CY => Logic_CY);
    U_MUX: mux2to1_4bit port map (AU_R => AU_R, Logic_R => Logic_R, SEL => OP(2), R => R);
    U_FLAGS: flags_alu port map (AU_CBo => AU_CBo, AU_OV => AU_OV, R => R, Logic_CY => Logic_CY,
                                  X => X, Y => Y, CBi => CBi, OP => OP,
                                  CBo => CBo, OV => OV, Z => Z, GE => GE, BE => BE);
end Structural;