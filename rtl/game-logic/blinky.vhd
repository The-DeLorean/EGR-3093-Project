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
signal blinky_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal blinky_y_int_i     : integer range 0 to 480:=188; 
signal count : integer;
signal count_blinky : integer range 0 to 17:=0;
--signal moving_i : boolean := moving;
signal ghost_state_vec_i   : std_logic_vector(4 downto 0);

--Signal to move ghost back and forth in prison
signal prison_right : std_logic:='0';



begin
    blinky_x_int_i <= blinky_x_int;
    blinky_y_int_i <= blinky_y_int;
    
    ghost_state_vec_i <= ghost_state_vec;
    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count>=2000000 then
            count<=0;
            
            
            --Prison state
            if ghost_state_vec="10000" then
                count_blinky <= 0;
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
                count_blinky <= 0;
                blinky_x_int_i<=299;
                blinky_y_int_i<=146;
            -- Chase state
            elsif ghost_state_vec="00100" or ghost_state_vec="00010"then
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
                            blinky_y_int_i <= blinky_y_int_i+1;
                        elsif blinky_y_int_i >= 188 then
                            count_blinky <= count_blinky+1;
                        end if;
                    --x194
                    elsif count_blinky = 2 then
                        if blinky_x_int_i > 194 then
                            blinky_x_int_i <= blinky_x_int_i-1;
                        elsif blinky_x_int_i <= 194 then
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
           end if;
        end if;
    end if;   
    end process;
    --output pinky new position 
    blinky_x_int_out <= blinky_x_int_i;
    blinky_y_int_out <= blinky_y_int_i;
end Behavioral;
