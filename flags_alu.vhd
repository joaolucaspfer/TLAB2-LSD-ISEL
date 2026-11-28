library ieee;
use ieee.std_logic_1164.all;

entity Flags is
    port (
        OP     : in  std_logic_vector(2 downto 0);
        R      : in  std_logic_vector(3 downto 0);
        AU_CBo : in  std_logic;
        AU_OV  : in  std_logic;
        CY     : in  std_logic;
        OPF    : in  std_logic;
        CBo    : out std_logic;
        OV     : out std_logic;
        Z      : out std_logic;
        GE     : out std_logic;
        BE     : out std_logic
    );
end Flags;

architecture structural of Flags is
    signal zero_res : std_logic;
    signal is_sub   : std_logic;
    signal ge_val   : std_logic;
    signal be_val   : std_logic;

begin
    zero_res <= not (R(3) or R(2) or R(1) or R(0));
    Z <= zero_res;

    is_sub <= (not OP(2)) and (not OP(1)) and OP(0);

    CBo <= (AU_CBo and not OPF) or (CY and OPF);
    OV  <= AU_OV and not OPF;

    ge_val <= not (R(3) xor AU_OV);
    be_val <= AU_CBo or zero_res;

    GE <= ge_val;
    BE <= be_val;
end structural;