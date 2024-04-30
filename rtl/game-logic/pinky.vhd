----------------------------------------------------------------------------------
-- Company: Point Loma nazarene University
-- Engineer: Dorian Quimby
-- 
-- Create Date: 04/15/2024 12:28:00 PM
-- Design Name: 
-- Module Name: inky - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This file is module controlling pinky
-- Dependencies: hdmi_out.vhd, game_logic.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pinky is
    Port (  clk       : in std_logic;
            rst      : in std_logic;
            moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640;
            pacman_y_int   : in integer range 0 to 480;
            pinky_x_int    : in integer range 0 to 640;
            pinky_y_int    : in integer range 0 to 480;
            pinky_x_int_out : out integer range 0 to 640;
            pinky_y_int_out : out integer range 0 to 480;
            powerup     : in std_logic;
            --p e c s r
            ghost_state_vec   : in std_logic_vector(4 downto 0));
end pinky;

architecture Behavioral of pinky is

 --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=314; 
signal pinky_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pinky_y_int_i     : integer range 0 to 480:=174; 
signal count          : integer;
signal moving_i : boolean;
signal ghost_state_vec_i : std_logic_vector(4 downto 0); 
--top left
signal t_l_corner : std_logic :='0';
--top right
signal t_r_corner : std_logic :='0';
--bot right
signal b_r_corner : std_logic :='0';
--bot left
signal b_l_corner : std_logic :='0';

--Signal to move ghost back and forth in prison
signal prison_right : std_logic:='0';

--Collision Signals
constant rom_depth : natural := 29; --30
constant rom_width : natural := 26;--27

--Array of Bit to represent map
type wall_type is array (0 to rom_depth -1) of std_logic_vector(rom_width - 1 downto 0);
constant walls : wall_type :=(
                            "00000000000011000000000000",
                            "01111011111011011111011110",
                            "01111011111011011111011110",
                            "01111011111011011111011110",
                            "00000000000000000000000000",
                            "01111011011111111011011110",
                            "01111011011111111011011110",
                            "00000011000011000011000000",
                            "11111011111011011111011111",
                            "00001011111011011111010000",
                            "00001011000000000011010000",
                            "00001011011111111011010000",
                            "11111011010000001011011111",
                            "00000000010000001000000000",
                            "11111011010000001011011111",
                            "00001011011111111011010000",
                            "00001011000000000011010000",
                            "00001011011111111011010000",
                            "11111011011111111011011111",
                            "00000000000011000000000000",
                            "01111011111011011111011110",
                            "01111011111011011111011110",
                            "00011000000000000000011000",
                            "11011011011111111011011011",
                            "11011011011111111011011011",
                            "00000011000011000011000000",
                            "01111111111011011111111110",
                            "01111111111011011111111110",
                            "00000000000000000000000000"
                            );

--signals to signify collision
signal right_i : std_logic:='1';
signal left_i : std_logic:='1';
signal up_i : std_logic:='1';
signal down_i : std_logic:='1';

--Integer values to store top left corner and bottom right integer values for when moving right
signal pinky_loc_x_right_lc :integer range 0 to 30;
signal pinky_loc_y_right_lc :integer range 0 to 30;
signal pinky_loc_x_right_rc :integer range 0 to 30;
signal pinky_loc_y_right_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving left
signal pinky_loc_x_left_lc :integer range 0 to 30;
signal pinky_loc_y_left_lc :integer range 0 to 30;
signal pinky_loc_x_left_rc :integer range 0 to 30;
signal pinky_loc_y_left_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving up
signal pinky_loc_x_up_lc :integer range 0 to 30;
signal pinky_loc_y_up_lc :integer range 0 to 30;
signal pinky_loc_x_up_rc :integer range 0 to 30;
signal pinky_loc_y_up_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving down
signal pinky_loc_x_down_lc :integer range 0 to 30;
signal pinky_loc_y_down_lc :integer range 0 to 30;
signal pinky_loc_x_down_rc :integer range 0 to 30;
signal pinky_loc_y_down_rc :integer range 0 to 30;


begin
    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    pinky_x_int_i <= pinky_x_int;
    pinky_y_int_i <= pinky_y_int;
    ghost_state_vec_i <= ghost_state_vec;

    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count >=2000000 then
            count<=0;
            
            --Pinky Collision Check
            --Collision check right
            --Calculating pinky's top left for moving right
            pinky_loc_x_right_lc<= (pinky_x_int_i-124)/14;
            pinky_loc_y_right_lc<= (pinky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving right
            pinky_loc_x_right_rc<= (pinky_x_int_i-124+2)/14;
            pinky_loc_y_right_rc<= (pinky_y_int_i-6+13)/14;
            if (walls(pinky_loc_y_right_lc)(pinky_loc_x_right_lc+1)='1' or walls(pinky_loc_y_right_rc)(pinky_loc_x_right_rc+1)='1') then
                right_i<='0';
            else
                right_i<='1';
            end if;  
            
            --Collision check left
            --Calculating pinky's top left for moving left
            pinky_loc_x_left_lc<= (pinky_x_int_i-124+11)/14;
            pinky_loc_y_left_lc<= (pinky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving left
            pinky_loc_x_left_rc<= (pinky_x_int_i-124+13)/14;
            pinky_loc_y_left_rc<= (pinky_y_int_i-6+13)/14;
            if (walls(pinky_loc_y_left_lc)(pinky_loc_x_left_lc-1)='1' or  walls(pinky_loc_y_left_rc)(pinky_loc_x_left_rc-1)='1') then
                left_i<='0';
            else
                left_i<='1';
            end if;
            
            --Collision check up
            --Calculating pinky's top left for moving up
            pinky_loc_x_up_lc<= (pinky_x_int_i-124)/14;
            pinky_loc_y_up_lc<= (pinky_y_int_i-6+11)/14;
            --Calculating pinky's bototm right for moving up
            pinky_loc_x_up_rc<= (pinky_x_int_i-124+13)/14;
            pinky_loc_y_up_rc<= (pinky_y_int_i-6+13)/14;
            if (walls(pinky_loc_y_up_lc-1)(pinky_loc_x_up_lc)='1' or walls(pinky_loc_y_up_rc-1)(pinky_loc_x_up_rc)='1') then
                up_i<='0';
            else
                up_i<='1';
            end if;        
            
            --Collision check Down
            --Calculating pinky's top left for moving down
            pinky_loc_x_down_lc<= (pinky_x_int_i-124)/14;
            pinky_loc_y_down_lc<= (pinky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving down
            pinky_loc_x_down_rc<= (pinky_x_int_i-124+13)/14;
            pinky_loc_y_down_rc<= (pinky_y_int_i-6+2)/14;
            if (walls(pinky_loc_y_down_lc+1)(pinky_loc_x_down_lc)='1' or walls(pinky_loc_y_down_rc+1)(pinky_loc_x_down_rc)='1') then
                down_i<='0';
            else
                down_i<='1';
            end if;
            
            --End Ghost COllision Logic
            
            --Prison state logic
            if ghost_state_vec="10000" then
                if prison_right='0' then
                    pinky_x_int_i<=pinky_x_int_i+1;
                    if pinky_x_int_i >=334 then
                        prison_right<='1';
                    end if;
                else
                    pinky_x_int_i<=pinky_x_int_i-1;
                    if pinky_x_int_i <=264 then
                        prison_right<='0';
                    end if;
                end if;
                pinky_y_int_i<=174;
            -- Escape state
            elsif ghost_state_vec="01000" then
                pinky_x_int_i<=299;
                pinky_y_int_i<=146;
            -- Chase state logic
            elsif ghost_state_vec="00100" then
                    --x pacman hunter 
                    --top left
                    if t_l_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        if left_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i-1;
                            t_l_corner<='0'; 
                        end if;   
                    --top right
                    elsif t_r_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        if right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                            t_r_corner<='0'; 
                        end if;
                    --bot right
                    elsif b_r_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                        if right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                            b_r_corner<='0'; 
                        end if;
                    --bot left
                    elsif b_l_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                        if left_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i-1;
                            b_l_corner<='0'; 
                        end if;
                    elsif pinky_x_int_i = pacman_x_int_i then
                    --do y hunting
                        --down
                        if pinky_y_int_i < pacman_y_int_i and down_i = '1' then
                            pinky_y_int_i<=pinky_y_int_i+1;
                        --up
                        elsif pinky_y_int_i > pacman_y_int_i and up_i = '1' then
                            pinky_y_int_i<=pinky_y_int_i-1;
                        end if;
                    --right
                    elsif pinky_x_int_i < pacman_x_int_i and right_i = '1' then
                        pinky_x_int_i<=pinky_x_int_i+1;
                    --left
                    elsif pinky_x_int_i > pacman_x_int_i and left_i = '1' then
                        pinky_x_int_i<=pinky_x_int_i-1;
                    --no left only up
                    elsif left_i = '0' and up_i = '1' and pinky_y_int_i > pacman_y_int_i then
                        --up
                        pinky_y_int_i<=pinky_y_int_i-1;
                        
                    --no left only down
                    elsif left_i = '0' and down_i = '1' and pinky_y_int_i < pacman_y_int_i then
                        --down
                        pinky_y_int_i<=pinky_y_int_i+1;
                        
                    --no right only up
                    elsif right_i = '0' and up_i = '1' and pinky_y_int_i > pacman_y_int_i then
                        --up
                        pinky_y_int_i<=pinky_y_int_i-1;
                        
                    elsif right_i = '0' and down_i = '1' and pinky_y_int_i < pacman_y_int_i then
                        --down
                        pinky_y_int_i<=pinky_y_int_i+1;
                            
                    --top left corner stuck
                    elsif up_i = '0' and left_i = '0' then
                        t_l_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i+1;
                    --top right corner stuck
                    elsif up_i = '0' and right_i = '0' then
                        t_r_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i+1;
                    --bot right corner stuck
                    elsif down_i = '0' and right_i = '0' then
                        b_r_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i-1;
                    --bot left corner stuck
                    elsif down_i = '0' and left_i = '0' then
                        b_l_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i-1;
                    end if;
             -- Scatter logic
            elsif ghost_state_vec="00010" then
                   --Scattering to Top Right corner
                    if t_r_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        if right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                            t_r_corner<='0';
                        end if;    
                    elsif pinky_y_int_i = 6 or up_i = '0' then
                    --do y hunting
                        if pinky_x_int_i < 474 and right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                        end if; 
                    elsif pinky_y_int_i > 6 and up_i = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                    elsif up_i = '0' and right_i = '0' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        t_r_corner<='1';
                    end if;
            -- retreat logic
            elsif ghost_state_vec="00001" then
                   --x pacman hunter hard coded values for walls (for now)
                    if pinky_x_int_i = pacman_x_int_i or (pinky_x_int_i = 150 and (pinky_y_int_i = 240 or pinky_y_int_i = 241)) then
                    --do y hunting
                        if pinky_y_int_i < pacman_y_int_i then
                            pinky_y_int_i<=pinky_y_int_i-1;
                        elsif pinky_y_int_i > pacman_y_int_i then
                            pinky_y_int_i<=pinky_y_int_i+1;
                        end if;
                    elsif pinky_x_int_i < pacman_x_int_i then
                        pinky_x_int_i<=pinky_x_int_i-1;
                    elsif pinky_x_int_i > pacman_x_int_i then
                        pinky_x_int_i<=pinky_x_int_i+1;
                    end if;
             end if;   
             
             --Hard coding pinky border      
             if pinky_x_int_i= 123 then
                pinky_x_int_i<=124;
             end if;
             if pinky_y_int_i= 5 then
                pinky_y_int_i<=6;
             end if;
             if pinky_y_int_i= 399 then
                pinky_y_int_i<=398;
             end if;
             if pinky_x_int_i = 475 then
                pinky_x_int_i<=474;
             end if;
           end if;
        end if;
    end process;
    --output pinky new position 
    pinky_x_int_out <= pinky_x_int_i;
    pinky_y_int_out <= pinky_y_int_i;
end Behavioral;
