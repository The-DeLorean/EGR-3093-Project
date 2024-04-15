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
-- Description: This file changes pacman's location based on user input.
-- Dependencies: game_logic.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pacman is
Port (  clk     : in std_logic;
        rst      : in std_logic;
        right    : in std_logic;
        left     : in std_logic;
        up       : in std_logic;
        down     : in std_logic;
        moving   : in boolean;
        moving_out   : out boolean;
        pacman_x_int     : in integer range 0 to 640:=240; -- starting coordinates (240,340)
        pacman_y_int     : in integer range 0 to 480:=340;
        pacman_x_int_out     : out integer range 0 to 640:=240; -- starting coordinates (240,340)
        pacman_y_int_out     : out integer range 0 to 480:=340;
        powerup     : in std_logic;
        prison   : in std_logic;
        escape   : in std_logic;
        chase     : in std_logic;
        scatter   : in std_logic;
        retreat   : in std_logic
        );
end pacman;

architecture Behavioral of pacman is

--internal signals
signal pacman_x_int_i     : integer range 0 to 640:=240; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=340; 
signal count_i          : integer;
signal moving_i : boolean := moving;

begin
    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    process
        begin
        wait for 10 ns;
        
        --PacMan movement, reimplement as state machine
        if rising_edge(clk) then
            count_i <= count_i +1;          --increment
            if count_i = 2000000 then
                moving_i <= not(moving_i);  --toggle pacman mouth
                count_i <= 0;               --reset counter
                
                --move right
                if right = '0' then
                    pacman_x_int_i <= pacman_x_int_i+1;
                    if pacman_x_int_i = 503 then
                        pacman_x_int_i <= 502;
                    end if;
                
                --move left
                elsif left = '0' then
                    pacman_x_int_i <= pacman_x_int_i-1;
                    if pacman_x_int_i = 123 then
                        pacman_x_int_i<= 124;
                    end if;
                
                --move down
                elsif down = '0' then
                    pacman_y_int_i <= pacman_y_int_i+1;
                    if pacman_y_int_i = 440 then
                        pacman_y_int_i <= 439;
                    end if;
                    
                --move up
                elsif up = '0' then
                    pacman_y_int_i <= pacman_y_int_i-1;
                    if pacman_y_int_i = 4 then
                        pacman_y_int_i <= 5;
                    end if;
                end if;
                
            end if;
        end if;
    end process;
    
    --drive output signals 
    pacman_x_int_out <= pacman_x_int_i;
    pacman_y_int_out <= pacman_y_int_i;
    moving_out <= moving_i;
end Behavioral;
