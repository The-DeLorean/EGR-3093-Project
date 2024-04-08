--This driver increments the score 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DigitCounterForScore is
    Port ( button : in STD_LOGIC;
           Value : out integer range 0 to 9;
           nextDigit: out STD_LOGIC);
end DigitCounterForScore;

architecture Behavioral of DigitCounterForScore is
signal tempV: integer range 0 to 9;
signal tempND: std_logic:='0';
begin
process
begin
    if (rising_edge(button)) then
        tempV <= tempV+1;
        tempND<='0';
        if(tempV = 9) then
            tempV<= 0;
            tempND<= '1';
        end if;
    end if;
end process;

Value <= tempV;
nextDigit<= tempND;

end Behavioral;
