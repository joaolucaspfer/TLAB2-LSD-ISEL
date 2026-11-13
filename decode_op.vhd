library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decode_op is
    Port ( OP : in  STD_LOGIC_VECTOR(2 downto 0);
           OPA : out STD_LOGIC;
           OPB : out STD_LOGIC;
           OPC : out STD_LOGIC;
           OPD : out STD_LOGIC;
           OPE : out STD_LOGIC;
           OPF : out STD_LOGIC);
end decode_op;

architecture Behavioral of decode_op is
begin
    -- OPA = '1' para operações com Y (010 = Y+CBi, 011 = Y-CBi)
    OPA <= '1' when (OP = "010" or OP = "011") else '0';

    -- OPB: não utilizado explicitamente no diagrama (mantido a '0')
    OPB <= '0';

    -- OPC = '1' para subtração (001 = X-Y-CBi, 011 = Y-CBi)
    OPC <= '1' when (OP = "001" or OP = "011") else '0';

    -- OPD = '1' para ASR (111)
    OPD <= '1' when (OP = "111") else '0';

    -- OPE = '1' para LSL (110)
    OPE <= '1' when (OP = "110") else '0';

    -- OPF = '1' para NAND (101)
    OPF <= '1' when (OP = "101") else '0';
end Behavioral;