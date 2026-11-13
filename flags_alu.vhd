library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flags_alu is
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
end flags_alu;

architecture Behavioral of flags_alu is
begin
    -- Z: Zero flag
    Z <= '1' when R = "0000" else '0';

    -- CBo: depende da operação
    -- OP[2]='0' -> Aritméticas (000-011): usa AU_CBo
    -- OP="110" -> LSL: usa Logic_CY (último bit deslocado)
    -- OP="111" -> ASR: bit deslocado para fora = X(0)
    -- OP="100"/"101" -> Lógicas: CBo = '0' (don't care)
    CBo <= AU_CBo     when OP(2) = '0' else
           Logic_CY   when OP = "110" else
           X(0)       when OP = "111" else
           '0';

    -- OV: só significativo em aritméticas (OP[2]='0')
    OV <= AU_OV when OP(2) = '0' else '0';

    process(X, Y, CBi)
        variable y_plus_cbi : integer;
        variable cbi_value : integer;
    begin
        if CBi = '1' then
            cbi_value := 1;
        else
            cbi_value := 0;
        end if;

        y_plus_cbi := to_integer(unsigned(Y));
        y_plus_cbi := y_plus_cbi + cbi_value;

        if to_integer(signed(X)) >= to_integer(signed(Y)) + cbi_value then
            GE <= '1';
        else
            GE <= '0';
        end if;

        if to_integer(unsigned(X)) <= y_plus_cbi then
            BE <= '1';
        else
            BE <= '0';
        end if;
    end process;
end Behavioral;