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
            right    : in std_logic;
            left     : in std_logic;
            up       : in std_logic;
            down     : in std_logic;
            moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640:=240;
            pacman_y_int   : in integer range 0 to 480:=340;
            pinky_x_int    : in integer range 0 to 640:=240;
            pinky_y_int    : in integer range 0 to 480:=100;
            pinky_x_int_out : out integer range 0 to 640:=240;
            pinky_y_int_out : out integer range 0 to 480:=100;
            powerup     : in std_logic;
            --p e c s r
            ghost_state_vec   : in std_logic_vector(4 downto 0));
end pinky;

architecture Behavioral of pinky is

 --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=240; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=340; 
signal pinky_x_int_i     : integer range 0 to 640:=240; -- starting coordinates (240,340)
signal pinky_y_int_i     : integer range 0 to 480:=340; 
signal count          : integer;
signal moving_i : boolean;
signal ghost_state_vec_i : std_logic_vector(4 downto 0); 

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
        if ghost_state_vec="00100" then
            count<=count +1;
            if count >=2000000 then
                count<=0;
                --x pacman hunter 
                if pinky_x_int_i = pacman_x_int_i or (left = '0' and right = '0') then
                --do y hunting
                    --down
                    if pinky_y_int_i < pacman_y_int_i and down = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                    --up
                    elsif pinky_y_int_i > pacman_y_int_i and up = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                    end if;
                --right
                elsif pinky_x_int_i < pacman_x_int_i and right = '1' then
                    pinky_x_int_i<=pinky_x_int_i+1;
                --left
                elsif pinky_x_int_i > pacman_x_int_i and left = '1' then
                    pinky_x_int_i<=pinky_x_int_i-1;
                end if;
           end if;
        elsif ghost_state_vec="00010" then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --Scattering to Top Right corner
                if pinky_y_int_i = 6 or (pinky_y_int_i = 150 and (pinky_x_int_i = 240 or pinky_x_int_i = 241)) then
                --do y hunting
                    if pinky_x_int_i > 124 then
                        pinky_x_int_i<=pinky_x_int_i+1;
                    end if; 
                elsif pinky_y_int_i > 6 then
                    pinky_y_int_i<=pinky_y_int_i-1;
                end if;
            end if;
        elsif ghost_state_vec="00001" then
             count<=count +1;
            if count >=2000000 then
                count<=0;
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
               
           --end if;
        end if;
    end if;
    end process;
    --output pinky new position 
    pinky_x_int_out <= pinky_x_int_i;
    pinky_y_int_out <= pinky_y_int_i;
end Behavioral;
