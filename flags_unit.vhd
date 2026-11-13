library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flags_unit is
    Port ( A : in  STD_LOGIC_VECTOR(3 downto 0);
           B : in  STD_LOGIC_VECTOR(3 downto 0);
           Cin : in  STD_LOGIC;
           AUOp : in  STD_LOGIC;  -- 0 = Add, 1 = Subtract
           S : in  STD_LOGIC_VECTOR(3 downto 0);
           Cout : in  STD_LOGIC;
           CBo : out STD_LOGIC;
           OV : out STD_LOGIC);
end flags_unit;

architecture Behavioral of flags_unit is
begin
    -- CBo: Carry out para adição, Borrow out para subtração
    -- Na subtração (A - B - Cin), borrow = NOT(Cout) do adder com B invertido
    CBo <= Cout when AUOp = '0' else not Cout;

    process(A, B, Cin, AUOp)
        variable arithmetic_result : integer;
        variable cin_value : integer;
    begin
        if Cin = '1' then
            cin_value := 1;
        else
            cin_value := 0;
        end if;

        if AUOp = '0' then
            arithmetic_result := to_integer(signed(A)) +
                                  to_integer(signed(B)) +
                                  cin_value;
        else
            arithmetic_result := to_integer(signed(A)) -
                                  to_integer(signed(B)) -
                                  cin_value;
        end if;

        if arithmetic_result < -8 or arithmetic_result > 7 then
            OV <= '1';
        else
            OV <= '0';
        end if;
    end process;
end Behavioral;