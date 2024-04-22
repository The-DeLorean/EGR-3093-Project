--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity username_select is
Port (--Pins of the tactile buttons on breadboard
    right, left, up, down, clk, rst : in STD_LOGIC;
    --LEDs to ensure buttons are working correctly
    led_right, led_left, led_up, led_down : out STD_LOGIC;
    -- Anode: Controls which segment is active at any given time
    name_anode : out std_logic_vector (3 downto 0):= "1111";
    --controls which particular segments are active
    name_segment : out std_logic_vector (7 downto 0)
 );
end username_select;

architecture Behavioral of username_select is
--Declare seven segment component
component sev_seg_driver is
  port (
  data_0 : in integer range 0 to 16;
  data_1 : in integer range 0 to 16;
  data_2 : in integer range 0 to 16;
  data_3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  display_data : out STD_LOGIC_VECTOR(7 downto 0);
  display_digit : out STD_LOGIC_VECTOR(3 downto 0));
end component;

--Variable that stores the hexvalue to be displayed on each screen.
signal data_0_i : integer range -2 to 17:= 0; --stores hex value with small buffer on either side
signal data_1_i : integer range -2 to 17:= 0; --stores hex value with small buffer on either side
signal data_2_i : integer range -2 to 17:= 0; --stores hex value with small buffer on either side

--Boolean to
signal selection_active: STD_LOGIC := '1';

signal digitSelector : integer range 0 to 4:= 0;

--Signals to hold the previous button push
signal u: STD_LOGIC:='1';
signal d: STD_LOGIC:='1';

begin
   --Right changes the digit selector when username is being edited
   process
   begin
       if selection_active= '1' then
          if (falling_edge(right)) then
            digitSelector <= digitSelector + 1;
            if digitSelector= 4 then
               digitSelector<= 3;   
            end if;
          end if;
       end if;
    end process;

    --Process to add or subtract 1 when a button is pressed  
    process 
    begin
       --If username selection is active
       if selection_active = '1' then
         if rising_edge(clk) then
         if digitSelector = 0 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (up='0' and u='1' and down='1') then
                    data_0_i<= data_0_i + 1;
                elsif (down='0' and d='1' and up='1')then
                    data_0_i<= data_0_i - 1;
                else
                --do nothing
                end if;
                u<=up;
                d<=down;
                if data_0_i < 0 then 
                    data_0_i <= 15;
                elsif data_0_i > 15 then 
                    data_0_i <= 0;
                end if;
         elsif digitSelector = 1 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (up='0' and u='1' and down='1') then
                    data_1_i<= data_1_i + 1;
                elsif (down='0' and d='1' and up='1')then
                    data_1_i<= data_1_i - 1;
                else
                --do nothing 
                end if;
                u<=up;
                d<=down;
                if data_1_i < 0 then 
                    data_1_i <= 15;
                elsif data_1_i > 15 then 
                    data_1_i <= 0;
                end if;
         elsif digitSelector = 2 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (up='0' and u='1' and down='1') then
                    data_2_i<= data_2_i + 1;
                elsif (down='0' and d='1' and up='1')then
                    data_2_i<= data_2_i - 1;
                else
                --do nothing
                end if;
                u<=up;
                d<=down;
                if data_2_i < 0 then 
                    data_2_i <= 15;
                elsif data_2_i > 15 then 
                    data_2_i <= 0;
                end if;
         elsif digitselector = 3 then
            selection_active <='0'; 
         end if;
         end if;
       --Display is static and leds light up once selection_active = 0
       else
         led_right <= NOT(right);
         led_left <= NOT(left);
         led_up <= NOT(up);
         led_down <= NOT(down);
       end if ;
    end process;

    --controls right side LEDs on boolean board, displays username
    c1: sev_seg_driver port map(data_0 => data_0_i, 
                                data_1 => data_1_i, 
                                data_2 => data_2_i, 
                                data_3 => 16,--blank 
                                clk => clk, 
                                rst => rst, 
                                display_data => name_segment, 
                                display_digit => name_anode);
end Behavioral;
