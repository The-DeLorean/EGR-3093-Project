
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ButtonPresstoIncreaseScoreCOunt is
    Port ( score_button : in STD_LOGIC;
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            --Anodes of 7seg Display
            D1_AN : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            D1_SEG : out std_logic_vector (7 downto 0));
end ButtonPresstoIncreaseScoreCOunt;

architecture Behavioral of ButtonPresstoIncreaseScoreCOunt is
component DigitCounterForScore is
    Port ( button : in STD_LOGIC;
           Value : out integer range 0 to 9;
           nextDigit: out STD_LOGIC);
end component;

component sevenSegmentDriver is
  port (
  data0 : in integer range 0 to 15;
  data1 : in integer range 0 to 15;
  data2 : in integer range 0 to 15;
  data3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  displayData : out STD_LOGIC_VECTOR(7 downto 0);
  displayDigit : out STD_LOGIC_VECTOR(3 downto 0));
end component;



signal nD0: std_logic:='0';
signal nD1: std_logic:='0';
signal nD2: std_logic:='0';
signal nD3: std_logic:='0';

signal hexVal0: integer range 0 to 9;
signal hexVal1: integer range 0 to 9;
signal hexVal2: integer range 0 to 9;
signal hexVal3: integer range 0 to 9;

begin

dig0: DigitCounterForScore port map(button => score_button, Value => hexVal0, nextDigit => nD0);
dig1: DigitCounterForScore port map(button => nD0, Value => hexVal1, nextDigit => nD1);
dig2: DigitCounterForScore port map(button => nD1, Value => hexVal2, nextDigit => nD2);
dig3: DigitCounterForScore port map(button => nD2, Value => hexVal3, nextDigit => nD3);

DrivSevenSeg: sevenSegmentDriver port map(data0 => hexVal3, data1 => hexVal2, data2 => hexVal1, data3 => hexVal0, 
                                 clk => clk, rst => rst, displayData => D1_SEG, displayDigit => D1_AN); 
end Behavioral;
