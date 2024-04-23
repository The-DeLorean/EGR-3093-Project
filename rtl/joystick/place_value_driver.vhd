--This driver increments the score upon button press
--Rename file to **place_value_driver**

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity place_value_driver is
    Port ( score_in : in STD_LOGIC;
           value : out integer range 0 to 9; --place value (ones, tens, etc)
           next_digit: out STD_LOGIC); -- drives next most significant digit
end place_value_driver;

architecture Behavioral of place_value_driver is
--internal signals
signal value_i: integer range 0 to 9;
signal next_digit_i: std_logic:='0';
begin
    
    process --increments integer signal upon button press
    begin
        if (rising_edge(score_in)) then
            value_i <= value_i + 1;
            next_digit_i <= '0';
            if(value_i = 9) then
                value_i <= 0;
                next_digit_i <= '1';
            end if;
        end if;
    end process;
    
    --drive outputs with internal signals
    value <= value_i;
    next_digit<= next_digit_i;
    
end Behavioral;
