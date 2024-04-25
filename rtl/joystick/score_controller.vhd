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
            score_int : in INTEGER
            );
end score_controller;

architecture Behavioral of score_controller is

--declare secondary driver component
component place_value_driver is
    Port ( button : in STD_LOGIC;
           value : out integer range 0 to 9;
           next_digit: out STD_LOGIC);
end component;

--declare seven segment controller component
component sev_seg_driver is
  port (
  data_0 : in integer range 0 to 9;
  data_1 : in integer range 0 to 9;
  data_2 : in integer range 0 to 9;
  data_3 : in integer range 0 to 9;
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

signal ones: integer range 0 to 9;
signal tens: integer range 0 to 9;
signal hundreds: integer range 0 to 9;
signal thousands: integer range 0 to 9;

--score int sginals
signal score_int_i : integer;
--signal score_driver : std_logic := '0';

begin
Score_int_i <= score_int;

process 
begin
    wait on score_int;
        thousands<= (score_int_i) /1000;
        hundreds<= (score_int_i - (thousands*1000)) /100;
        tens<= (score_int_i - (thousands*1000) - (hundreds*100))/10;
        ones<= (score_int_i - (thousands*1000) - (hundreds*100) - (tens*10));
end process;

    --drive internal signals with component calls for each place value
--    dig_0: place_value_driver port map(button => score_driver, value => hex_val_0, next_digit => nD0);  --ones
--    dig_1: place_value_driver port map(button => nD0, value => hex_val_1, next_digit => nD1);           --tens
--    dig_2: place_value_driver port map(button => nD1, value => hex_val_2, next_digit => nD2);           --hundreds
--    dig_3: place_value_driver port map(button => nD2, value => hex_val_3, next_digit => nD3);           --thousands
    --compoent call for displaying the data
    display: sev_seg_driver port map(data_0 => thousands, data_1 => hundreds, data_2 => tens, data_3 => ones, 
                                     clk => clk, rst => rst, display_data => score_segment, display_digit => score_anode); 
end Behavioral;
