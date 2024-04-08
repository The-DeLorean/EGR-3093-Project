library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity ClockDivider is
  port(
  clk : in STD_LOGIC; 
  rst : in STD_LOGIC; 
  clk_1k : out STD_LOGIC);
end ClockDivider;

architecture Behavioral of ClockDivider is

signal count : integer:=1;
signal tmp: STD_LOGIC := '0'; -- this will be the new clock

begin
process (clk, rst)
begin
   if(rst='1') then
      count<=1;
      tmp<='0';
   elsif(rising_edge(clk)) then -- Counting each rising edge until half way through period than switching to low
      count <= count+1;
      if(count = 50000) then -- at 50,000 making half the period so a full period is in 1 ms.
         tmp<= NOT(tmp);
         count<=1;
      end if;
   end if;
   clk_1k<=tmp;--value of clock turning from high to low
end process;
end Behavioral;
