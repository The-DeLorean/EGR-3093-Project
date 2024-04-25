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
signal inky_y_int_i     : integer range 0 to 480:=146; 
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

component Ghost_navigation_check is
  Port (  
        Ghost_x_pos        : in integer;
        Ghost_y_pos        : in integer;
        clk                : in std_logic;
        right_collision    : out std_logic;
        left_collision     : out std_logic;
        up_collision       : out std_logic;
        down_collision     : out std_logic
        );
end component;

--signals for collisions
signal right_i : std_logic:='1';
signal left_i : std_logic:='1';
signal up_i : std_logic:='1';
signal down_i : std_logic:='1';

begin
    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    inky_x_int_i <= inky_x_int;
    inky_y_int_i <= inky_y_int;
    
    --Inky's movements are the inverse of PacMan's
    process
        begin
        wait for 10 ns;
        if rising_edge(clk) then
            count_i <= count_i +1;
            if count_i = 2000000 then
                count_i <= 0; --reset counter
                
                --move left
                if right = '0' then
                    inky_x_int_i <= inky_x_int_i-1;
                    if inky_x_int_i =123 then
                        inky_x_int_i<=124;
                    end if;
                
                --move right
                elsif left = '0' then
                    inky_x_int_i <= inky_x_int_i+1;
                    if inky_x_int_i = 503 then
                        inky_x_int_i<=502;
                    end if;
                
                --move up
                elsif down = '0' then
                    inky_y_int_i <= inky_y_int_i-1;
                    if inky_y_int_i = 4 then
                        inky_y_int_i <= 5;
                    end if;
                
                --move down
                elsif up = '0' then
                    inky_y_int_i <= inky_y_int_i+1;
                    if inky_y_int_i = 440 then
                        inky_y_int_i<= 439;
                    end if;
                end if;
            end if;
        end if;
    end process;

    inky_x_int_out <= inky_x_int_i;
    inky_y_int_out <= inky_y_int_i;
end Behavioral;
