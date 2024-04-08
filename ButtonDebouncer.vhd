--This component takes the raw joystick inputs and debounces them.
--It drives a signal for a debounced output.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ButtonDebouncer is
    Port ( raw_button, clk : in STD_LOGIC;
           button_debounced : out STD_LOGIC);
end ButtonDebouncer;

architecture Behavioral of ButtonDebouncer is
signal count : integer:=1;
signal button_debounced_i: std_logic := '1';

begin
--Changing the output to debounced output
button_debounced<= button_debounced_i; 

process(clk)
begin 
if(rising_edge(clk)) then
    if(count < 1000000 ) then 
        count <= count+1;
    elsif(raw_button /= button_debounced_i) then
        button_debounced_i <=raw_button;
        count<=1;
    end if;
end if;

end process;

end Behavioral;
