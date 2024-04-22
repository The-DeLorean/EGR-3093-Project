--Decoder for the seven segment display
--Receives a hex value for a single digit
--Drives the display circuitry depending on this value
--Renamed file **sev_seg_decoder**

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity sev_seg_decoder is
  port(
  hex_value : in integer range 0 to 16;
  control : in STD_LOGIC_VECTOR (1 downto 0);
  segments : out STD_LOGIC_VECTOR (7 downto 0);
  anodes : out STD_LOGIC_VECTOR (3 downto 0));
end sev_seg_decoder;

architecture Behavioral of sev_seg_decoder is

begin
process(hex_value)
begin
   case hex_value is
      when 0 => segments <= "11000000"; --0
      when 1 => segments <= "11111001"; --1
      when 2 => segments <= "10100100"; --2
      when 3 => segments <= "10110000"; --3
      when 4 => segments <= "10011001"; --4
      when 5 => segments <= "10010010"; --5
      when 6 => segments <= "10000010"; --6
      when 7 => segments <= "11111000"; --7
      when 8 => segments <= "10000000"; --8
      when 9 => segments <= "10011000"; --9
      when 10 => segments <= "10001000"; --A
      when 11 => segments <= "10000011"; --B
      when 12 => segments <= "11000110"; --C
      when 13 => segments <= "10100001"; --D
      when 14 => segments <= "10000110"; --E
      when 15 => segments <= "10001110"; --F
      when 16 => segments <= "11111111"; --off
      when others => null; --Default value
   end case;
end process;

process (control)
begin
   case control is
      when "00" => anodes <= "0111"; --first digit
      when "01" => anodes <= "1011"; --second digit
      when "10" => anodes <= "1101"; --third digit
      when "11" => anodes <= "1110"; --fourth digit 
      when others => null;
   end case;
end process;


end Behavioral;
