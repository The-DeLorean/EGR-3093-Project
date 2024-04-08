--Top module containing logic/inputs/outputs for joystick, score, and username control
--Rename file to **top_module**
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_module is
    Port ( --non-debounced joystick input
           right_raw, left_raw, up_raw, down_raw : in STD_LOGIC; 
           --clk variables
           clk, rst : in STD_LOGIC;
           --Button on board to increment score
           score_raw : in STD_LOGIC;
           --LEDs to ensure buttons are working correctly
           led_right, led_left, led_up, led_down : out STD_LOGIC;
            -- Anodes of 7seg Display #1
            name_anode : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            name_segment : out std_logic_vector (7 downto 0);
            --Anodes of 7seg Display #2
            score_anode : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            score_segment : out std_logic_vector (7 downto 0)
           );
end top_module;

architecture Behavioral of top_module is

--Declare component that receives raw input and debounces.
component button_debounce is
    Port ( raw_button, clk : in STD_LOGIC;
           debounced_button : out STD_LOGIC);
end component;

--Declare component that uses debounced input for username selection logic
component username_select is
Port ( 
    right, left, up, down, clk, rst : in STD_LOGIC;
    led_right, led_left, led_up, led_down : out STD_LOGIC;
    -- Anode: Controls which segment is active at any given time
    name_anode : out std_logic_vector (3 downto 0):= "1111";
    name_segment : out std_logic_vector (7 downto 0));
end component;

--Declare component that uses a debounced button to increment score
component score_controller is
    Port ( score_button, clk, rst : in STD_LOGIC;
            --Anodes of 7seg Display
            score_anode : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            score_segment : out std_logic_vector (7 downto 0));
end component;

--Declare signals to hold the debounced output
signal up_i: STD_LOGIC:='1';
signal down_i: STD_LOGIC:='1';
signal right_i: STD_LOGIC:='1';
signal left_i: STD_LOGIC:='1';
signal score_button_i: STD_LOGIC:='1';

begin
    --the following calls map the raw input to debounced output signals
    debounce_up: button_debounce port map(raw_button => up_raw , clk => clk, debounced_button => up_i);
    debounce_down: button_debounce port map(raw_button => down_raw , clk => clk, debounced_button => down_i);
    debounce_right: button_debounce port map(raw_button => right_raw , clk => clk, debounced_button => right_i);
    debounce_left: button_debounce port map(raw_button => left_raw , clk => clk, debounced_button => left_i);
    debounce_score: button_debounce port map(raw_button => score_raw, clk => clk, debounced_button => score_button_i);

    username_select_i: username_select port map(right => right_i, left => left_i, 
    up => up_i, down => down_i, clk => clk, rst => rst, led_right => led_right, led_left => led_left, 
    led_up => led_up, led_down => led_down, name_anode => name_anode, name_segment => name_segment);
    score_controller_i: score_controller port map(score_button => score_button_i, clk => clk, 
    rst => rst, score_anode => score_anode, score_segment => score_segment);
end Behavioral;
