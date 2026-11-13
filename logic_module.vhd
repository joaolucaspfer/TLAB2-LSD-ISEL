library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity logic_module is
    Port ( X : in  STD_LOGIC_VECTOR(3 downto 0);
           Y : in  STD_LOGIC_VECTOR(3 downto 0);
           OPF : in  STD_LOGIC;  -- 1 para NAND
           OPE : in  STD_LOGIC;  -- 1 para LSL
           OPD : in  STD_LOGIC;  -- 1 para ASR
           R : out STD_LOGIC_VECTOR(3 downto 0);
           CY : out STD_LOGIC);  -- Carry do shift
end logic_module;

architecture Behavioral of logic_module is
    signal shift_amount : INTEGER range 0 to 3;
    signal lsl_result : STD_LOGIC_VECTOR(3 downto 0);
    signal lsl_cy : STD_LOGIC;
    signal asr_result : STD_LOGIC_VECTOR(3 downto 0);
    signal asr_cy : STD_LOGIC;
begin
    shift_amount <= TO_INTEGER(UNSIGNED(Y(1 downto 0)));

    -- LSL: X << Y[1:0]
    process(X, shift_amount)
        variable temp : STD_LOGIC_VECTOR(3 downto 0);
        variable cy_var : STD_LOGIC;
    begin
        temp := X;
        cy_var := '0';
        for i in 1 to shift_amount loop
            cy_var := temp(3);
            temp := temp(2 downto 0) & '0';
        end loop;
        lsl_result <= temp;
        lsl_cy <= cy_var;
    end process;

    -- ASR: X >> 1 (aritmético, mantém sinal)
    asr_result <= X(3) & X(3 downto 1);
    asr_cy <= X(0);

    -- Saída principal
    process(OPF, OPE, OPD, X, Y, lsl_result, lsl_cy, asr_result, asr_cy)
    begin
        if OPD = '1' then
            -- ASR
            R <= asr_result;
            CY <= asr_cy;
        elsif OPE = '1' then
            -- LSL
            R <= lsl_result;
            CY <= lsl_cy;
        elsif OPF = '1' then
            -- NAND
            R <= not (X and Y);
            CY <= '0';
        else
            -- AND
            R <= X and Y;
            CY <= '0';
        end if;
    end process;
end Behavioral;