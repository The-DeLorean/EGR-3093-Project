library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenSegmentDriver is
  port (
  data0 : in integer range 0 to 15;
  data1 : in integer range 0 to 15;
  data2 : in integer range 0 to 15;
  data3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  displayData : out STD_LOGIC_VECTOR(7 downto 0);
  displayDigit : out STD_LOGIC_VECTOR(3 downto 0));
end sevenSegmentDriver;


architecture Behavioral of sevenSegmentDriver is
   --signal for clk_1k
   signal hexValue : integer range 0 to 16:=0;
   signal control : STD_LOGIC_VECTOR (1 downto 0):="00";
   signal clk_1k : STD_LOGIC;

   --component of clockDivider
   component clockDivider is
   port (clk : in STD_LOGIC; 
     rst : in STD_LOGIC; 
     clk_1k : out STD_LOGIC);
   end component;
   
   --Decoder for seven segment component
   component seven_segment_decoder is
   port(hexValue : in integer range 0 to 16;
   control : in STD_LOGIC_VECTOR (1 downto 0);
   segments : out STD_LOGIC_VECTOR (7 downto 0);
   anodes : out STD_LOGIC_VECTOR (3 downto 0));   
   end component;
   
begin
c1: clockDivider port map(clk=> clk, rst=> rst, clk_1k=> clk_1k);
c2: seven_segment_decoder port map(hexValue, control, displayData, displayDigit);

process(data0, data1, data2, data3, clk_1k) 
begin
   if (rising_edge(clk_1k)) then 
      --advancing control each cycle and display correect data at that moment
      case control is
      when "00"=> control <= "01"; 
         hexValue <= data1;
      when "01"=> control <= "10"; 
         hexValue <= data2;
      when "10"=> control <= "11"; 
         hexValue <= data3;
      when "11"=> control <= "00";
         hexValue <= data0;
      end case;
  end if;
end process;
end Behavioral;
