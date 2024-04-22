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
        death    : out integer range 0 to 4;
        moving_out   : out boolean;
        pacman_x_int     : in integer range 0 to 640:=240; -- starting coordinates (240,340)
        pacman_y_int     : in integer range 0 to 480:=340;
        pacman_x_int_out     : out integer range 0 to 640:=240; -- starting coordinates (240,340)
        pacman_y_int_out     : out integer range 0 to 480:=340;
        powerup     : in std_logic;
        pac_death : in std_logic
        );
end pacman;

architecture Behavioral of pacman is

--internal signals
signal pacman_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=314; 
signal count_i          : integer;
signal moving_i : boolean := moving;


--Directional internal signals to keep pacman moving in a certain direction
signal right_i : std_logic:='0';
signal left_i : std_logic:='0';
signal up_i : std_logic:='0';
signal down_i : std_logic:='0';
-- Vector is in order of right - left - up - down
signal prev_direction : std_logic_vector (3 downto 0):="0000";
signal new_direction : std_logic_vector (3 downto 0):="0000";


signal pac_crash : std_logic :='0';

signal death_i : integer range 0 to 4 :=0;

--A counter to know when pac man has moved 14 pixels
signal pixel_count : integer range 0 to 14:=0;
signal pixel_clk   : std_logic;

begin


 

    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    
    collision_i: entity work.navigation_check(Behavioral)
    port map (  x_pos => pacman_x_int_i,
                y_pos => pacman_y_int_i,
                down=> down,
                clk=>clk, 
                collision => pac_crash
                );
    --Continual motion process
--    process
--    begin
--        if right='1' then
--            right_i<='1';
--            left_i<='0';
--            up_i<='0';
--            down_i<='0';
--            prev_direction<="1000";
--        elsif left='1' then 
--            right_i<='0';
--            left_i<='1';
--            up_i<='0';
--            down_i<='0';
--            prev_direction<="0100";
--        elsif up='1' then 
--            right_i<='0';
--            left_i<='0';
--            up_i<='1';
--            down_i<='0';
--            prev_direction<="0010";
--        elsif down='1' then 
--            right_i<='0';
--            left_i<='0';
--            up_i<='0';
--            down_i<='1';
--            prev_direction<="0001";
--        end if;
        
--  end process;
    
    process
        begin        
        --PacMan movement, reimplement as state machine
        if rising_edge(clk) then
            count_i <= count_i +1;          --increment
            if count_i = 2000000 then
                moving_i <= not(moving_i);  --toggle pacman mouth
                count_i <= 0;               --reset counter
                --move right
                if (right = '0' and pac_crash='0') then
                    pacman_x_int_i <= pacman_x_int_i+1;
                    if pacman_x_int_i = 517 then
                        pacman_x_int_i <= 516;
                    end if;
                
                --move left
                elsif (left = '0' and pac_crash='0') then
                    pacman_x_int_i <= pacman_x_int_i-1;
                    if pacman_x_int_i = 123 then
                        pacman_x_int_i<= 124;
                    end if;
                
                --move down
                elsif (down = '0' and pac_crash='0') then
                    pacman_y_int_i <= pacman_y_int_i+1;
                    if pacman_y_int_i = 427 then
                        pacman_y_int_i <= 426;
                    end if;
                    
                --move up
                elsif (up = '0' and pac_crash='0') then
                    pacman_y_int_i <= pacman_y_int_i-1;
                    if pacman_y_int_i = 5 then
                        pacman_y_int_i <= 6;
                    end if;
                elsif (pac_crash='1') then
--                    if down='0' then
--                        pacman_y_int_i<= pacman_y_int_i-1;
--                    end if;
                end if;
                
                if (pac_death = '1') then
                    --reset pacman coordinates
                    pacman_x_int_i <= 299;
                    pacman_y_int_i <= 314;
                    death_i<=death_i+1;
                    if death_i =4 then
                        death_i<=3;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    

    --drive output signals 
    pacman_x_int_out <= pacman_x_int_i;
    pacman_y_int_out <= pacman_y_int_i;
    moving_out <= moving_i;
    death<=death_i;
end Behavioral;
