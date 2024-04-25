----------------------------------------------------------------------------------
-- Company: Point Loma nazarene University
-- Engineer: Dorian Quimby
-- 
-- Create Date: 04/13/2024 08:34:31 PM
-- Design Name: 
-- Module Name: game_logic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This file is module controlling inky
-- Dependencies: hdmi_out.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inky is
    Port (  clk       : in std_logic;
            rst      : in std_logic;
            right    : in std_logic;
            left     : in std_logic;
            up       : in std_logic;
            down     : in std_logic;
            moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640;
            pacman_y_int   : in integer range 0 to 480;
            inky_x_int    : in integer range 0 to 640;
            inky_y_int    : in integer range 0 to 480;
            inky_x_int_out : out integer range 0 to 640;
            inky_y_int_out : out integer range 0 to 480;
            powerup     : in std_logic;
            ghost_state_vec   : in std_logic_vector(4 downto 0)
            );
end inky;

architecture Behavioral of inky is

 --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=314; 
signal inky_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal inky_y_int_i     : integer range 0 to 480:=202; 
signal count_i          : integer;
signal moving_i : boolean := moving;
--signal moving_i : boolean := moving;
signal ghost_state_vec_i   : std_logic_vector(4 downto 0);
--top left
signal t_l_corner : std_logic :='0';
--top right
signal t_r_corner : std_logic :='0';
--bot right
signal b_r_corner : std_logic :='0';
--bot left
signal b_l_corner : std_logic :='0';


--signals for collisions
signal right_i : std_logic:='1';
signal left_i : std_logic:='1';
signal up_i : std_logic:='1';
signal down_i : std_logic:='1';

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


--Integer values to store top left corner and bottom right integer values for when moving right
signal inky_loc_x_right_lc :integer range 0 to 30;
signal inky_loc_y_right_lc :integer range 0 to 30;
signal inky_loc_x_right_rc :integer range 0 to 30;
signal inky_loc_y_right_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving left
signal inky_loc_x_left_lc :integer range 0 to 30;
signal inky_loc_y_left_lc :integer range 0 to 30;
signal inky_loc_x_left_rc :integer range 0 to 30;
signal inky_loc_y_left_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving up
signal inky_loc_x_up_lc :integer range 0 to 30;
signal inky_loc_y_up_lc :integer range 0 to 30;
signal inky_loc_x_up_rc :integer range 0 to 30;
signal inky_loc_y_up_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving down
signal inky_loc_x_down_lc :integer range 0 to 30;
signal inky_loc_y_down_lc :integer range 0 to 30;
signal inky_loc_x_down_rc :integer range 0 to 30;
signal inky_loc_y_down_rc :integer range 0 to 30;

--Signal to move ghost back and forth in prison
signal prison_right : std_logic:='0';

begin
    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    inky_x_int_i <= inky_x_int;
    inky_y_int_i <= inky_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    --Inky's movements are the inverse of PacMan's
    process
        begin
        wait for 10 ns;
        if rising_edge(clk) then
            count_i <= count_i +1;
            if count_i = 2000000 then
                count_i <= 0; --reset counter
                
                --Pinky Collision Check
            --Collision check right
            --Calculating pinky's top left for moving right
            inky_loc_x_right_lc<= (inky_x_int_i-124)/14;
            inky_loc_y_right_lc<= (inky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving right
            inky_loc_x_right_rc<= (inky_x_int_i-124+2)/14;
            inky_loc_y_right_rc<= (inky_y_int_i-6+13)/14;
            if (walls(inky_loc_y_right_lc)(inky_loc_x_right_lc+1)='1' or walls(inky_loc_y_right_rc)(inky_loc_x_right_rc+1)='1') then
                right_i<='0';
            else
                right_i<='1';
            end if;  
            
            --Collision check left
            --Calculating pinky's top left for moving left
            inky_loc_x_left_lc<= (inky_x_int_i-124+11)/14;
            inky_loc_y_left_lc<= (inky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving left
            inky_loc_x_left_rc<= (inky_x_int_i-124+13)/14;
            inky_loc_y_left_rc<= (inky_y_int_i-6+13)/14;
            if (walls(inky_loc_y_left_lc)(inky_loc_x_left_lc-1)='1' or  walls(inky_loc_y_left_rc)(inky_loc_x_left_rc-1)='1') then
                left_i<='0';
            else
                left_i<='1';
            end if;
            
            --Collision check up
            --Calculating pinky's top left for moving up
            inky_loc_x_up_lc<= (inky_x_int_i-124)/14;
            inky_loc_y_up_lc<= (inky_y_int_i-6+11)/14;
            --Calculating pinky's bototm right for moving up
            inky_loc_x_up_rc<= (inky_x_int_i-124+13)/14;
            inky_loc_y_up_rc<= (inky_y_int_i-6+13)/14;
            if (walls(inky_loc_y_up_lc-1)(inky_loc_x_up_lc)='1' or walls(inky_loc_y_up_rc-1)(inky_loc_x_up_rc)='1') then
                up_i<='0';
            else
                up_i<='1';
            end if;        
            
            --Collision check Down
            --Calculating pinky's top left for moving down
            inky_loc_x_down_lc<= (inky_x_int_i-124)/14;
            inky_loc_y_down_lc<= (inky_y_int_i-6)/14;
            --Calculating pinky's bototm right for moving down
            inky_loc_x_down_rc<= (inky_x_int_i-124+13)/14;
            inky_loc_y_down_rc<= (inky_y_int_i-6+2)/14;
            if (walls(inky_loc_y_down_lc+1)(inky_loc_x_down_lc)='1' or walls(inky_loc_y_down_rc+1)(inky_loc_x_down_rc)='1') then
                down_i<='0';
            else
                down_i<='1';
            end if;
            
            --End Ghost COllision Logic
                
                --Prison state logic
            if ghost_state_vec="10000" then
                if prison_right='0' then
                    inky_x_int_i<=inky_x_int_i+1;
                    if inky_x_int_i >=334 then
                        prison_right<='1';
                    end if;
                else
                    inky_x_int_i<=inky_x_int_i-1;
                    if inky_x_int_i <=264 then
                        prison_right<='0';
                    end if;
                end if;
                inky_y_int_i<=202;
            -- Escape state
            elsif ghost_state_vec="01000" then
                inky_x_int_i<=299;
                inky_y_int_i<=146;
            -- Chase state logic
                elsif ghost_state_vec_i="00100" then
                    --top left
                    if t_l_corner = '1' then
                        inky_x_int_i<=inky_x_int_i+1;
                        if up_i = '1' then
                            inky_y_int_i<=inky_y_int_i-1;
                            t_l_corner<='0'; 
                        end if;   
                    --top right
                    elsif t_r_corner = '1' then
                        inky_x_int_i<=inky_x_int_i-1;
                        if up_i = '1' then
                            inky_y_int_i<=inky_y_int_i-1;
                            t_r_corner<='0'; 
                        end if;
                    --bot right
                    elsif b_r_corner = '1' then
                        inky_x_int_i<=inky_x_int_i-1;
                        if down_i = '1' then
                            inky_y_int_i<=inky_y_int_i+1;
                            b_r_corner<='0'; 
                        end if;
                    --bot left
                    elsif b_l_corner = '1' then
                        inky_x_int_i<=inky_x_int_i+1;
                        if down_i = '1' then
                            inky_y_int_i<=inky_y_int_i+1;
                            b_l_corner<='0'; 
                        end if;
                    --move left
                    elsif right = '0' and left_i = '1' then
                        inky_x_int_i <= inky_x_int_i-1;
                        if inky_x_int_i =123 then
                            inky_x_int_i<=124;
                        end if;
                    
                    --move right
                    elsif left = '0' and right_i = '1' then
                        inky_x_int_i <= inky_x_int_i+1;
                        if inky_x_int_i = 503 then
                            inky_x_int_i<=502;
                        end if;
                    
                    --move up
                    elsif down = '0' and up_i = '1' then
                        inky_y_int_i <= inky_y_int_i-1;
                        if inky_y_int_i = 4 then
                            inky_y_int_i <= 5;
                        end if;
                    
                    --move down
                    elsif up = '0' and down_i = '1' then
                        inky_y_int_i <= inky_y_int_i+1;
                        if inky_y_int_i = 440 then
                            inky_y_int_i<= 439;
                        end if;
                    --top left corner stuck
                    elsif up_i = '0' and left_i = '0' then
                        t_l_corner<='1';
                        inky_x_int_i<=inky_x_int_i+1;
                    --top right corner stuck
                    elsif up_i = '0' and right_i = '0' then
                        t_r_corner<='1';
                        inky_x_int_i<=inky_x_int_i-1;
                    --bot right corner stuck
                    elsif down_i = '0' and right_i = '0' then
                        b_r_corner<='1';
                        inky_x_int_i<=inky_x_int_i-1;
                    --bot left corner stuck
                    elsif down_i = '0' and left_i = '0' then
                        b_l_corner<='1';
                        inky_x_int_i<=inky_x_int_i+1;
                    end if;
                --scatter
                elsif ghost_state_vec_i="00010" then 
                    --Scattering to bot LEft corner
                    if b_l_corner = '1' then
                        inky_x_int_i<=inky_x_int_i+1;
                        if down_i = '1' then
                            inky_y_int_i<=inky_y_int_i+1;
                            b_l_corner<='0';
                        end if;
                    elsif inky_y_int_i = 398 or down_i='0' then
                    --do x hunting
                        if inky_x_int_i > 124 and left_i = '1' then
                            inky_x_int_i<=inky_x_int_i-1;
                        end if; 
                    elsif inky_y_int_i < 398 and down_i ='1' then
                        inky_y_int_i<=inky_y_int_i+1;
                    elsif down_i = '0' and left_i = '0' then
                        inky_x_int_i<=inky_x_int_i+1;
                        t_l_corner<='1';
                    end if;    
                end if;
                
                --Hard coding pinky border      
             if inky_x_int_i= 123 then
                inky_x_int_i<=124;
             end if;
             if inky_y_int_i= 5 then
                inky_y_int_i<=6;
             end if;
             if inky_y_int_i= 399 then
                inky_y_int_i<=398;
             end if;
             if inky_x_int_i = 475 then
                inky_x_int_i<=474;
             end if;
                
            end if;
        end if;
    end process;

    inky_x_int_out <= inky_x_int_i;
    inky_y_int_out <= inky_y_int_i;
end Behavioral;
