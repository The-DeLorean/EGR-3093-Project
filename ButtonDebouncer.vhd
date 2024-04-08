----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/12/2024 02:49:23 PM
-- Design Name: 
-- Module Name: ButtonDebouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ButtonDebouncer is
    Port ( Button : in STD_LOGIC;
           clk : in STD_LOGIC;
           DebouncedButton : out STD_LOGIC);
end ButtonDebouncer;

architecture Behavioral of ButtonDebouncer is
signal count : integer:=1;
signal debounced: std_logic := '1';

begin
--Changing the output to debounced output
DebouncedButton<= debounced; 

process(clk)
begin 
if(rising_edge(clk)) then
    if(count < 1000000 ) then 
        count <= count+1;
    elsif(Button /= debounced) then
        debounced <=Button;
        count<=1;
    end if;
end if;

end process;

end Behavioral;
