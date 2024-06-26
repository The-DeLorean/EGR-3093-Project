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
            right    : in std_logic;
            left     : in std_logic;
            up       : in std_logic;
            down     : in std_logic;
            --moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640:=240;
            pacman_y_int   : in integer range 0 to 480:=340;
            blinky_x_int    : in integer range 0 to 640:=240;
            blinky_y_int    : in integer range 0 to 480:=100;
            blinky_x_int_out : out integer range 0 to 640:=240;
            blinky_y_int_out : out integer range 0 to 480:=100;
            powerup     : in std_logic;
            --p e c s r
            ghost_state_vec   : in std_logic_vector(4 downto 0));
end blinky;


architecture Behavioral of Blinky is
         --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=240; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=340; 
signal blinky_x_int_i     : integer range 0 to 640:=240; -- starting coordinates (240,340)
signal blinky_y_int_i     : integer range 0 to 480:=340; 
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

begin
    blinky_x_int_i <= blinky_x_int;
    blinky_y_int_i <= blinky_y_int;
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    process
    begin
    if rising_edge(clk) then
        if ghost_state_vec="00100" then
            count<=count +1;
            if count>=2000000 then
                count<=0;
                --head pacman hunter 
                --top left
                if t_l_corner = '1' then
                    blinky_y_int_i<=blinky_y_int_i+1;
                    if left = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        t_l_corner<='0'; 
                        alternate <= 1;
                    end if;   
                --top right
                elsif t_r_corner = '1' then
                    blinky_x_int_i<=blinky_x_int_i-1;
                    if up = '1' then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        t_r_corner<='0'; 
                        alternate <= 0;
                    end if;
                --bot right
                elsif b_r_corner = '1' then
                    blinky_x_int_i<=blinky_x_int_i-1;
                    if down = '1' then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        b_r_corner<='0'; 
                        alternate <= 0;
                    end if;
                --bot left
                elsif b_l_corner = '1' then
                    blinky_y_int_i<=blinky_y_int_i-1;
                    if left = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        b_l_corner<='0';
                        alternate <= 1; 
                    end if;
                --down right
                elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                    --right
                    if alternate = 1 and right = '1' then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        alternate <= 0;
                    --down
                    elsif alternate = 0 and down = '1' then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        alternate <= 1;
                    end if;
                --up right
                elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                    if alternate = 1 and right = '1' then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        alternate <= 0;
                    elsif alternate = 0 and up = '1' then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        alternate <= 1;
                    end if;
                --left down
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                    if alternate = 1 and left = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        alternate <= 0;
                    elsif alternate = 0 and down = '1' then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        alternate <= 1;
                    end if;
                --left up
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                    if alternate = 1 and left = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        alternate <= 0;
                    elsif alternate = 0 and up = '1' then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        alternate <= 1;
                    end if;
                --down
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i < pacman_y_int_i and down = '1' then
                    blinky_y_int_i<=blinky_y_int_i+1;
                    alternate <= 0;
                --up
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i > pacman_y_int_i and up = '1' then
                    blinky_y_int_i<=blinky_y_int_i-1;
                    alternate <= 0;   
                --right
                elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i = pacman_y_int_i and right = '1' then
                    blinky_x_int_i<=blinky_x_int_i+1;
                    alternate <= 1; 
                --left
                elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i = pacman_y_int_i and left = '1' then
                    blinky_x_int_i<=blinky_x_int_i-1;
                    alternate <= 1; 
                --game over
                elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i = pacman_y_int_i then
                    --gameover
                --top left corner stuck
                elsif up = '0' and left = '0' then
                    t_l_corner<='1';
                    blinky_y_int_i<=blinky_y_int_i+1;
                --top right corner stuck
                elsif up = '0' and right = '0' then
                    t_r_corner<='1';
                    blinky_x_int_i<=blinky_x_int_i-1;
                --bot right corner stuck
                elsif down = '0' and right = '0' then
                    b_r_corner<='1';
                    blinky_x_int_i<=blinky_x_int_i-1;
                --bot left corner stuck
                elsif down = '0' and left = '0' then
                    b_l_corner<='1';
                    blinky_y_int_i<=blinky_y_int_i-1;
                end if;
           end if;
       elsif ghost_state_vec="00010" then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --Scattering to bot right corner
                if blinky_y_int_i = 6 or (blinky_y_int_i = 150 and (blinky_x_int_i = 240 or blinky_x_int_i = 241)) then
                --do y hunting
                    if blinky_x_int_i > 124 then
                        blinky_x_int_i<=blinky_x_int_i+1;
                    end if; 
                elsif blinky_y_int_i > 6 then
                    blinky_y_int_i<=blinky_y_int_i+1;
                end if;
            end if;
        elsif ghost_state_vec="00001" then
             count<=count +1;
            if count >=2000000 then
                count<=0;
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
               
           --end if;
        end if;
    end if;
    end process;
    --output pinky new position 
    blinky_x_int_out <= blinky_x_int_i;
    blinky_y_int_out <= blinky_y_int_i;
end Behavioral;
