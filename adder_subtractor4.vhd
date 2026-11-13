library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adder_subtractor4 is
    Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
           B : in  STD_LOGIC_VECTOR(3 downto 0);
           Cin : in  STD_LOGIC;
           AUOp : in  STD_LOGIC;  -- 0 = Add, 1 = Subtract
           S : out STD_LOGIC_VECTOR(3 downto 0);
           Cout : out STD_LOGIC);
end adder_subtractor4;

architecture Structural of adder_subtractor4 is
    component adder4
        Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
               B : in  STD_LOGIC_VECTOR(3 downto 0);
               Cin : in  STD_LOGIC;
               S : out STD_LOGIC_VECTOR(3 downto 0);
               Cout : out STD_LOGIC);
    end component;

    signal B_mod : STD_LOGIC_VECTOR(3 downto 0);
    signal Cin_mod : STD_LOGIC;
begin
    -- Para subtração: inverte B e soma 1 (via Cin)
    B_mod <= B when AUOp = '0' else not B;
    Cin_mod <= Cin when AUOp = '0' else not Cin;

    ADD_SUB: adder4 port map (A, B_mod, Cin_mod, S, Cout);
end Structural;