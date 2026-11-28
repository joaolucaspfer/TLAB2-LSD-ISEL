library ieee;
use ieee.std_logic_1164.all;

entity DecodeOP is
    port (
        OP  : in  std_logic_vector(2 downto 0);
        OPA : out std_logic;
        OPB : out std_logic;
        OPC : out std_logic;
        OPD : out std_logic;
        OPE : out std_logic;
        OPF : out std_logic
    );
end DecodeOP;

architecture structural of DecodeOP is
begin
    OPA <= OP(1);
    OPB <= OP(0);
    OPC <= OP(2);
    OPD <= OP(0);
    OPE <= OP(1);
    OPF <= OP(2);
end structural;