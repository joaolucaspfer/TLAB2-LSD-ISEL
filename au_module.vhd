library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity au_module is
    Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
           B : in  STD_LOGIC_VECTOR(3 downto 0);
           CBi : in  STD_LOGIC;
           AUOp : in  STD_LOGIC;  -- 0 = Add, 1 = Subtract
           R : out STD_LOGIC_VECTOR(3 downto 0);
           CBo : out STD_LOGIC;
           OV : out STD_LOGIC);
end au_module;

architecture Structural of au_module is
    component adder_subtractor4
        Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
               B : in  STD_LOGIC_VECTOR(3 downto 0);
               Cin : in  STD_LOGIC;
               AUOp : in  STD_LOGIC;
               S : out STD_LOGIC_VECTOR(3 downto 0);
               Cout : out STD_LOGIC);
    end component;

    component flags_unit
        Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
               B : in  STD_LOGIC_VECTOR(3 downto 0);
               Cin : in  STD_LOGIC;
               AUOp : in  STD_LOGIC;
               S : in  STD_LOGIC_VECTOR(3 downto 0);
               Cout : in  STD_LOGIC;
               CBo : out STD_LOGIC;
               OV : out STD_LOGIC);
    end component;

    signal S_int : STD_LOGIC_VECTOR(3 downto 0);
    signal Cout_int : STD_LOGIC;
begin
    AU_ADD_SUB: adder_subtractor4 port map (A, B, CBi, AUOp, S_int, Cout_int);
    AU_FLAGS: flags_unit port map (A, B, CBi, AUOp, S_int, Cout_int, CBo, OV);
    R <= S_int;
end Structural;