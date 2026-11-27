library ieee;
use ieee.std_logic_1164.all;

entity LU is
    port(
        A, B: in std_logic_vector(3 downto 0);
        S: in std_logic_vector(1 downto 0);
        R: out std_logic_vector(3 downto 0);
        CY: out std_logic
    );
end LU;

architecture arc_lu of LU is

component LSR
    port(
        A: in std_logic_vector (3 downto 0);
        O: out std_logic_vector (3 downto 0);
        CY: out std_logic
    );
end component;

component ASR
    port(
        A: in std_logic_vector (3 downto 0);
        O: out std_logic_vector (3 downto 0);
        CY: out std_logic
    );
end component;

component LSL
    port(
        A: in std_logic_vector (3 downto 0);
        SHIFT: in std_logic_vector (1 downto 0);
        O: out std_logic_vector (3 downto 0);
        CY: out std_logic
    );
end component;

component NANDL
    port(
        A, B: in std_logic_vector (3 downto 0);
        O: out std_logic_vector (3 downto 0)
    );
end component;

component ANDL
    port(
        A, B: in std_logic_vector (3 downto 0);
        O: out std_logic_vector (3 downto 0)
    );
end component;

component MUX
    port(
        A, B: in std_logic_vector (3 downto 0);
        S: in std_logic;
        Y: out std_logic_vector (3 downto 0)
    );
end component;

SIGNAL s_and, s_nand, s_lsl, s_lsr, s_asr, s_mux1, s_mux2: std_logic_vector(3 downto 0);
SIGNAL cy_lsl, cy_lsr, cy_asr: std_logic;

begin

    ANDL0: ANDL port map(
        A => A,
        B => B,
        O => s_and
    );

    NANDL0: NANDL port map(
        A => A,
        B => B,
        O => s_nand
    );

    LSL0: LSL port map(
        A => A,
        SHIFT => B(1 downto 0),
        O => s_lsl,
        CY => cy_lsl
    );

    LSR0: LSR port map(
        A => A,
        O => s_lsr,
        CY => cy_lsr
    );

    ASR0: ASR port map(
        A => A,
        O => s_asr,
        CY => cy_asr
    );


    UMUX0: MUX port map (
        A => s_and,
        B => s_nand,
        S => S(0),
        Y => s_mux1
    );

    UMUX1: MUX port map (
        A => s_lsl,
        B => s_asr,
        S => S(0),
        Y => s_mux2
    );

    UMUX2: MUX port map (
        A => s_mux1,
        B => s_mux2,
        S => S(1),
        Y => R
    );

    CY <= cy_lsl when (S(1) = '1' and S(0) = '0') else  -- LSL
          cy_asr when (S(1) = '1' and S(0) = '1') else  -- ASR
          '0';  

end;