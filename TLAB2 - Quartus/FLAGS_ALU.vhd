library ieee;
use ieee.std_logic_1164.all;

entity FLAGS_ALU is
    port (
        iOV: in std_logic;
        iCB: in std_logic;
        OP: in std_logic;        
        R: in std_logic_vector(3 downto 0);
        CY: in std_logic;        
        BE: out std_logic;
        oGE: out std_logic;
        P: out std_logic;        
        Z: out std_logic;
        oOV: out std_logic;
        oCB: out std_logic
    );
end FLAGS_ALU;

architecture arch_flags of FLAGS_ALU is

begin
    oCB <= (iCB and OP) or (CY and (not OP));

    oOV <= iOV and OP;

    Z <= not (R(3) or R(2) or R(1) or R(0));

    oGE <= (not (R(3) xor iOV)) and OP;

    BE <= iCB and OP;

    P <= (R(0) xor R(1)) xor (R(2) xor R(3));

end arch_flags;