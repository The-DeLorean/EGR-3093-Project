--Frequency divider for system clock signal
--Drives a 1kHz internal clock used by the seven segment display
--Rename file **clock_divider**

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clock_divider is
  port(
  clk : in STD_LOGIC; 
  rst : in STD_LOGIC; 
  clk_1k : out STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is

signal count : integer:=1;
signal clk_1k_i: STD_LOGIC := '0'; -- this will be the new clock

begin
process (clk, rst)
begin
   if(rst='1') then
      count <= 1;
      clk_1k_i <= '0';
   elsif(rising_edge(clk)) then -- Counting each rising edge until half way through period than switching to low
      count <= count+1;
      if(count = 50000) then -- at 50,000 making half the period so a full period is in 1 ms.
         clk_1k_i <= NOT (clk_1k_i);
         count <= 1;
      end if;
   end if;
   clk_1k <= clk_1k_i;--value of clock turning from high to low
end process;
end Behavioral;
