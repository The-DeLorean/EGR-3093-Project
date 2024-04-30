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
signal inky_x_int_i     : integer range 0 to 640:=306; -- starting coordinates (240,340)
signal inky_y_int_i     : integer range 0 to 480:=188; 
signal count_i          : integer;
--where to move inky
signal count_inky          : integer range 0 to 17:=0;

--State machine variable for Inky
signal ghost_state_vec_i   : std_logic_vector(4 downto 0);


--Signal to move ghost back and forth in prison
signal prison_right : std_logic:='1';

begin
    --assign internals
    inky_x_int_i <= inky_x_int;
    inky_y_int_i <= inky_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    --Inky's movements are the inverse of PacMan's
    process
        begin
        if rising_edge(clk) then
            count_i <= count_i +1;
            --Making inky stop moving if pac man has died 3 times
            if count_i = 2000000 then
                count_i <= 0; --reset counter
                --Prison state logic
            if ghost_state_vec="10000" then
                count_inky<=0;
                if prison_right='1' then
                    inky_x_int_i<=inky_x_int_i+1;
                    if inky_x_int_i >=334 then
                        prison_right<='0';
                    end if;
                else
                    inky_x_int_i<=inky_x_int_i-1;
                    if inky_x_int_i <=264 then
                        prison_right<='1';
                    end if;
                end if;
                inky_y_int_i<=188;
            -- Escape state
            elsif ghost_state_vec="01000" then
                inky_x_int_i<=299;
                inky_y_int_i<=146;
                count_inky<=0;
            -- Chase state logic
                elsif ghost_state_vec_i="00100" or ghost_state_vec_i="00010" then
                    if count_inky = 0 then
                        if inky_x_int_i < 362 then
                            inky_x_int_i <= inky_x_int_i+1;
                        elsif inky_x_int_i >= 362 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 1 then
                        if inky_y_int_i < 188 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 188 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 2 then
                        if inky_x_int_i < 404 then
                            inky_x_int_i <= inky_x_int_i+1;
                        elsif inky_x_int_i >= 404 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 3 then
                        if inky_y_int_i < 356 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 356 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 4 then
                        if inky_x_int_i < 474 then
                            inky_x_int_i <= inky_x_int_i+1;
                        elsif inky_x_int_i >= 474 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 5 then
                        if inky_y_int_i < 398 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 398 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 6 then
                        if inky_x_int_i > 278 then
                            inky_x_int_i <= inky_x_int_i-1;
                        elsif inky_x_int_i <= 278 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 7 then
                        if inky_y_int_i > 356 then
                            inky_y_int_i <= inky_y_int_i-1;
                        elsif inky_y_int_i <= 356 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 8 then
                        if inky_x_int_i > 236 then
                            inky_x_int_i <= inky_x_int_i-1;
                        elsif inky_x_int_i <= 236 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 9 then
                        if inky_y_int_i > 314 then
                            inky_y_int_i <= inky_y_int_i-1;
                        elsif inky_y_int_i <= 314 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 10 then
                        if inky_x_int_i > 194 then
                            inky_x_int_i <= inky_x_int_i-1;
                        elsif inky_x_int_i <= 194 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 11 then
                        if inky_y_int_i > 6 then
                            inky_y_int_i <= inky_y_int_i-1;
                        elsif inky_y_int_i <= 6 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 12 then
                        if inky_x_int_i < 278 then
                            inky_x_int_i <= inky_x_int_i+1;
                        elsif inky_x_int_i >= 278 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 13 then
                        if inky_y_int_i < 62 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 62 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 14 then
                        if inky_x_int_i < 362 then
                            inky_x_int_i <= inky_x_int_i+1;
                        elsif inky_x_int_i >= 362 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 15 then
                        if inky_y_int_i < 104 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 104 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 16 then
                        if inky_x_int_i > 320 then
                            inky_x_int_i <= inky_x_int_i-1;
                        elsif inky_x_int_i <= 320 then
                            count_inky <= count_inky+1;
                        end if;
                    elsif count_inky = 17 then
                        if inky_y_int_i < 146 then
                            inky_y_int_i <= inky_y_int_i+1;
                        elsif inky_y_int_i >= 146 then
                            count_inky <= 0;
                        end if;
                    end if; 
                -- making inky stop if pac man has died 3 times
                else
                  
                end if;
                          
            end if;
        end if;
    end process;

    inky_x_int_out <= inky_x_int_i;
    inky_y_int_out <= inky_y_int_i;
end Behavioral;
