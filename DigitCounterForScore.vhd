----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/18/2024 02:53:23 PM
-- Design Name: 
-- Module Name: DigitCounterForScore - Behavioral
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
