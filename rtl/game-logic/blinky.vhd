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
-- Description: This file is module controlling blinky
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

entity blinky is
    Port (  clk       : in std_logic;
            rst      : in std_logic;
            --moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640;
            pacman_y_int   : in integer range 0 to 480;
            blinky_x_int    : in integer range 0 to 640;
            blinky_y_int    : in integer range 0 to 480;
            blinky_x_int_out : out integer range 0 to 640;
            blinky_y_int_out : out integer range 0 to 480;
            powerup     : in std_logic;
            --p e c s r
            ghost_state_vec   : in std_logic_vector(4 downto 0));
end blinky;


architecture Behavioral of Blinky is
         --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=314; 
signal blinky_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal blinky_y_int_i     : integer range 0 to 480:=188; 
signal count : integer;
signal alternate : integer:=0;
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

--Signal to move ghost back and forth in prison
signal prison_right : std_logic:='0';


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
signal blinky_loc_x_right_lc :integer range 0 to 30;
signal blinky_loc_y_right_lc :integer range 0 to 30;
signal blinky_loc_x_right_rc :integer range 0 to 30;
signal blinky_loc_y_right_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving left
signal blinky_loc_x_left_lc :integer range 0 to 30;
signal blinky_loc_y_left_lc :integer range 0 to 30;
signal blinky_loc_x_left_rc :integer range 0 to 30;
signal blinky_loc_y_left_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving up
signal blinky_loc_x_up_lc :integer range 0 to 30;
signal blinky_loc_y_up_lc :integer range 0 to 30;
signal blinky_loc_x_up_rc :integer range 0 to 30;
signal blinky_loc_y_up_rc :integer range 0 to 30;

--Integer values to store top left corner and bottom rightinteger values for when moving down
signal blinky_loc_x_down_lc :integer range 0 to 30;
signal blinky_loc_y_down_lc :integer range 0 to 30;
signal blinky_loc_x_down_rc :integer range 0 to 30;
signal blinky_loc_y_down_rc :integer range 0 to 30;


begin
    blinky_x_int_i <= blinky_x_int;
    blinky_y_int_i <= blinky_y_int;
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    
    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count>=2000000 then
            count<=0;
            
            
            --Blinky Collision Check
            --Collision check right
            --Calculating Blinky's top left for moving right
            blinky_loc_x_right_lc<= (blinky_x_int_i-124)/14;
            blinky_loc_y_right_lc<= (blinky_y_int_i-6)/14;
            --Calculating Blinky's bototm right for moving right
            blinky_loc_x_right_rc<= (blinky_x_int_i-124+2)/14;
            blinky_loc_y_right_rc<= (blinky_y_int_i-6+13)/14;
            if (walls(blinky_loc_y_right_lc)(blinky_loc_x_right_lc+1)='1' or walls(blinky_loc_y_right_rc)(blinky_loc_x_right_rc+1)='1') then
                right_i<='0';
            else
                right_i<='1';
            end if;  
            
            --Collision check left
            --Calculating Blinky's top left for moving left
            blinky_loc_x_left_lc<= (blinky_x_int_i-124+11)/14;
            blinky_loc_y_left_lc<= (blinky_y_int_i-6)/14;
            --Calculating Blinky's bototm right for moving left
            blinky_loc_x_left_rc<= (blinky_x_int_i-124+13)/14;
            blinky_loc_y_left_rc<= (blinky_y_int_i-6+13)/14;
            if (walls(blinky_loc_y_left_lc)(blinky_loc_x_left_lc-1)='1' or  walls(blinky_loc_y_left_rc)(blinky_loc_x_left_rc-1)='1') then
                left_i<='0';
            else
                left_i<='1';
            end if;
            
            --Collision check up
            --Calculating Blinky's top left for moving up
            blinky_loc_x_up_lc<= (blinky_x_int_i-124)/14;
            blinky_loc_y_up_lc<= (blinky_y_int_i-6+11)/14;
            --Calculating Blinky's bototm right for moving up
            blinky_loc_x_up_rc<= (blinky_x_int_i-124+13)/14;
            blinky_loc_y_up_rc<= (blinky_y_int_i-6+13)/14;
            if (walls(blinky_loc_y_up_lc-1)(blinky_loc_x_up_lc)='1' or walls(blinky_loc_y_up_rc-1)(blinky_loc_x_up_rc)='1') then
                up_i<='0';
            else
                up_i<='1';
            end if;        
            
            --Collision check Down
            --Calculating Blinky's top left for moving down
            blinky_loc_x_down_lc<= (blinky_x_int_i-124)/14;
            blinky_loc_y_down_lc<= (blinky_y_int_i-6)/14;
            --Calculating Blinky's bototm right for moving down
            blinky_loc_x_down_rc<= (blinky_x_int_i-124+13)/14;
            blinky_loc_y_down_rc<= (blinky_y_int_i-6+2)/14;
            if (walls(blinky_loc_y_down_lc+1)(blinky_loc_x_down_lc)='1' or walls(blinky_loc_y_down_rc+1)(blinky_loc_x_down_rc)='1') then
                down_i<='0';
            else
                down_i<='1';
            end if;
            
            --End Ghost COllision Logic
            
            
            --Prison state
            if ghost_state_vec="10000" then
                if prison_right='1' then
                    blinky_x_int_i<=blinky_x_int_i+1;
                    if blinky_x_int_i >=334 then
                        prison_right<='0';
                    end if;
                else
                    blinky_x_int_i<=blinky_x_int_i-1;
                    if blinky_x_int_i <=264 then
                        prison_right<='1';
                    end if;
                end if;
                blinky_y_int_i<=188;
            --Escape state
            elsif ghost_state_vec="01000" then
                blinky_x_int_i<=299;
                blinky_y_int_i<=146;
            -- Chase state
            elsif ghost_state_vec="00100" then
                    --x236
                    if count_blinky = 0 then
                        if blinky_x_int_i > 236 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif blinky_x_int_i >= 236 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y188
                    elsif count_blinky = 1 then
                        if blinky_y_int_i < 188 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 188 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x194
                    elsif count_blinky = 2 then
                        if blinky_x_int_i > 194 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif inky_x_int_i <= 194 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y356
                    elsif count_blinky = 3 then
                        if blinky_y_int_i < 356 then
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 356 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x124
                    elsif count_blinky = 4 then
                        if blinky_x_int_i > 124 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif blinky_x_int_i <= 124 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y398
                    elsif count_blinky = 5 then
                        if blinky_y_int_i < 398 then
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 398 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x320
                    elsif count_blinky = 6 then
                        if blinky_x_int_i < 320 then
                            blinky_x_int_i <= blinky_x_int_i+1;
                        elsif blinky_x_int_i >= 320 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y356
                    elsif count_blinky = 7 then
                        if blinky_y_int_i > 356 then
                            blinky_y_int_i <= blinky_y_int_i-1;
                        elsif blinky_y_int_i <= 356 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x362
                    elsif count_blinky = 8 then
                        if blinky_x_int_i < 362 then
                            blinky_x_int_i <= blinky_x_int_i+1;
                        elsif blinky_x_int_i >= 362 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y314
                    elsif count_blinky = 9 then
                        if blinky_y_int_i > 314 then
                            blinky_y_int_i <= blinky_y_int_i-1;
                        elsif blinky_y_int_i <= 314 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x404
                    elsif count_blinky = 10 then
                        if blinky_x_int_i < 404 then
                            blinky_x_int_i <= blinky_x_int_i+1;
                        elsif blinky_x_int_i >= 404 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y6
                    elsif count_blinky = 11 then
                        if blinky_y_int_i > 6 then
                            blinky_y_int_i <= blinky_y_int_i-1;
                        elsif blinky_y_int_i <= 6 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x320
                    elsif count_blinky = 12 then
                        if blinky_x_int_i > 320 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif blinky_x_int_i <= 320 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y62
                    elsif count_blinky = 13 then
                        if blinky_y_int_i < 62 then
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 62 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x236
                    elsif count_blinky = 14 then
                        if blinky_x_int_i > 236 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif blinky_x_int_i <= 236 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y104
                    elsif count_blinky = 15 then
                        if blinky_y_int_i < 104 then
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 104 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x278
                    elsif count_blinky = 16 then
                        if blinky_x_int_i < 278 then
                            blinky_x_int_i <= blinky_x_int_i+1;
                        elsif blinky_x_int_i >= 278 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --y146
                    elsif count_blinky = 17 then
                        if blinky_y_int_i < 146 then
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 146 then
                            count_blinky <= 0;
                        end if;
                    end if;
           --Scatter state
           elsif ghost_state_vec="00010" then
               --Scattering to bot right corner
                if b_r_corner = '1' then
                    blinky_y_int_i<=blinky_y_int_i-1;
                    if right_i = '1' then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        b_r_corner<='0';
                    end if;
                elsif blinky_y_int_i = 398 or down_i = '0' then
                --do y hunting
                    if blinky_x_int_i < 464 and right_i = '1' then
                        blinky_x_int_i<=blinky_x_int_i+1;
                    end if; 
                elsif blinky_y_int_i < 398 and down_i = '1' then
                    blinky_y_int_i<=blinky_y_int_i+1;
                elsif down_i = '0' and right_i = '0' then
                    b_r_corner<='1';
                    blinky_y_int_i<=blinky_y_int_i-1;
                end if;
            --Retreat state
            elsif ghost_state_vec="00001" then
               --head pacman hunter hard coded values for walls (for now)
                if blinky_x_int_i < pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                    if alternate = 1 then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        alternate <= 1;
                    end if;
                elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                    if alternate = 1 then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        alternate <= 1;
                    end if;
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                    if alternate = 1 then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        alternate <= 1;
                    end if;
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                    if alternate = 1 then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        alternate <= 1;
                    end if;
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                    blinky_y_int_i<=blinky_y_int_i-1;
                    alternate <= 0;
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                    blinky_y_int_i<=blinky_y_int_i+1;
                    alternate <= 0;   
                elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i = pacman_y_int_i then
                    blinky_x_int_i<=blinky_x_int_i-1;
                    alternate <= 1; 
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i = pacman_y_int_i then
                    blinky_x_int_i<=blinky_x_int_i+1;
                    alternate <= 1; 
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i = pacman_y_int_i then
                    --eaten
                end if;    
           end if;
           --Hard coding pinky border      
             if blinky_x_int_i= 123 then
                blinky_x_int_i<=124;
             end if;
             if blinky_y_int_i= 5 then
                blinky_y_int_i<=6;
             end if;
             if blinky_y_int_i= 399 then
                blinky_y_int_i<=398;
             end if;
             if blinky_x_int_i = 475 then
                blinky_x_int_i<=474;
             end if;
        end if;
    end if;   
    end process;
    --output pinky new position 
    blinky_x_int_out <= blinky_x_int_i;
    blinky_y_int_out <= blinky_y_int_i;
end Behavioral;
