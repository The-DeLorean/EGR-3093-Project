----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 01:59:46 PM
-- Design Name: 
-- Module Name: sevSegConverter - Behavioral
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

entity sevSegConverter is
  Port (sevSegConv: in integer range -2 to 17;
  D0_SEG1 : out std_logic_vector (7 downto 0));
end sevSegConverter;

architecture Behavioral of sevSegConverter is

begin
process(sevSegConv)
begin
case sevSegConv is
when 0 => D0_SEG1 <= "11000000"; --0
when 1 => D0_SEG1 <= "11111001"; --1
when 2 => D0_SEG1 <= "10100100"; --2
when 3 => D0_SEG1 <= "10110000"; --3
when 4 => D0_SEG1 <= "10011001"; --4
when 5 => D0_SEG1 <= "10010010"; --5
when 6 => D0_SEG1 <= "10000010"; --6
when 7 => D0_SEG1 <= "11111000"; --7
when 8 => D0_SEG1 <= "10000000"; --8
when 9 => D0_SEG1 <= "10011000"; --9
when 10 => D0_SEG1 <= "10001000"; --A
when 11 => D0_SEG1 <= "10000011"; --B
when 12 => D0_SEG1 <= "11000110"; --C
when 13 => D0_SEG1 <= "10100001"; --D
when 14 => D0_SEG1 <= "10000110"; --E
when 15 => D0_SEG1 <= "10001110"; --F
when others => null; --Default value
end case;
end process;

end Behavioral;
