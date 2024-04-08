--This component takes the raw joystick inputs and debounces them.
--It drives a signal for a debounced output.
--rename file to **button_debounce**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_debounce is
    Port ( raw_button, clk : in STD_LOGIC;
           debounced_button : out STD_LOGIC);
end button_debounce;

architecture Behavioral of button_debounce is
signal count : integer:=1;
signal debounced_button_i: std_logic := '1';

begin
    --Drive external signals
    debounced_button <= debounced_button_i; 
    
    process(clk)
    begin 
        if(rising_edge(clk)) then
            if(count < 1000000 ) then 
                count <= count+1;
            elsif(raw_button /= debounced_button_i) then
                debounced_button_i <=raw_button;
                count<=1;
            end if;
        end if;
    end process;
end Behavioral;
