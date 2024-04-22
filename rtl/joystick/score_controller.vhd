--This is the primary driver that controls the displayed score.
--Includes component calls to secondary driver which controls place values,
--as well as the seven segment display driver to display score.
--Rename file to **score_controller**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity score_controller is
    Port ( score_button : in STD_LOGIC;
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            --Anodes of 7seg Display
            score_anode : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            score_segment : out std_logic_vector (7 downto 0);
            score_in       : in STD_LOGIC);
end score_controller;

architecture Behavioral of score_controller is

--declare secondary driver component
component place_value_driver is
    Port ( button : in STD_LOGIC;
           value : out integer range 0 to 9;
           next_digit: out STD_LOGIC;
           score_in   : in STD_LOGIC);
end component;

--declare seven segment controller component
component sev_seg_driver is
  port (
  data_0 : in integer range 0 to 15;
  data_1 : in integer range 0 to 15;
  data_2 : in integer range 0 to 15;
  data_3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  display_data : out STD_LOGIC_VECTOR(7 downto 0);
  display_digit : out STD_LOGIC_VECTOR(3 downto 0));
end component;

--declare internal signals
signal nD0: std_logic:='0'; --change variable names to enhance readibility
signal nD1: std_logic:='0';
signal nD2: std_logic:='0';
signal nD3: std_logic:='0';

signal hex_val_0: integer range 0 to 9;
signal hex_val_1: integer range 0 to 9;
signal hex_val_2: integer range 0 to 9;
signal hex_val_3: integer range 0 to 9;

begin
    --drive internal signals with component calls for each place value
    dig_0: place_value_driver port map(button => score_button, value => hex_val_0, next_digit => nD0, score_in => score_in);  --ones
    dig_1: place_value_driver port map(button => nD0, value => hex_val_1, next_digit => nD1, score_in => score_in);           --tens
    dig_2: place_value_driver port map(button => nD1, value => hex_val_2, next_digit => nD2, score_in => score_in);           --hundreds
    dig_3: place_value_driver port map(button => nD2, value => hex_val_3, next_digit => nD3, score_in => score_in);           --thousands
    --compoent call for displaying the data
    display: sev_seg_driver port map(data_0 => hex_val_3, data_1 => hex_val_2, data_2 => hex_val_1, data_3 => hex_val_0, 
                                     clk => clk, rst => rst, display_data => score_segment, display_digit => score_anode); 
end Behavioral;
