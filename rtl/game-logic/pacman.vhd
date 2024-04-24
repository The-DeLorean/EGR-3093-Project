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

--Collision Cvariables
constant rom_depth : natural := 29; --30
constant rom_width : natural := 26;--27

signal pac_loc_x :integer range 0 to 30;
signal pac_loc_y :integer range 0 to 30;

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

begin


 

    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    
--    collision_i: entity work.navigation_check(Behavioral)
--    port map (  x_pos => pacman_x_int_i,
--                y_pos => pacman_y_int_i,
--                right=>right,
--                left=> left,
--                up=> up,
--                down=> down,
--                clk=>clk, 
--                collision => pac_crash
--                );

    
    process
        begin        
        --PacMan movement, reimplement as state machine
        if rising_edge(clk) then
            count_i <= count_i +1;          --increment
            if count_i = 2000000 then
                moving_i <= not(moving_i);  --toggle pacman mouth
                count_i <= 0; 
                
                --Collision Check
                if right='0' then
                    pac_loc_x<= (pacman_x_int_i-124)/14;
                    pac_loc_y<= (pacman_y_int_i-6)/14;
                    if (walls(pac_loc_y)(pac_loc_x+1)='1') then
                        pac_crash<='1';
                    else
                        pac_crash<='0';
                    end if;  
                    
                elsif left='0' then
                    pac_loc_x<= (pacman_x_int_i-124)/14;
                    pac_loc_y<= (pacman_y_int_i-6+13)/14;
                    if (walls(pac_loc_y)(pac_loc_x-1)='1') then
                        pac_crash<='1';
                    else
                        pac_crash<='0';
                    end if;
                    
                 elsif up='0' then
                    pac_loc_x<= (pacman_x_int_i-124)/14;
                    pac_loc_y<= (pacman_y_int_i-6+13)/14;
                    if (walls(pac_loc_y-1)(pac_loc_x)='1') then
                        pac_crash<='1';
                    else
                        pac_crash<='0';
                    end if;        
                    
                elsif down='0' then
                    pac_loc_x<= (pacman_x_int_i-124)/14;
                    pac_loc_y<= (pacman_y_int_i-6)/14;
                    if (walls(pac_loc_y+1)(pac_loc_x)='1') then
                        pac_crash<='1';
                    else
                        pac_crash<='0';
                    end if;
                end if;  
                
                --End Collision Check
                
                
                --move right
                if (right = '0' and pac_crash='0' )then --and not(death_i=3)) then
                    pacman_x_int_i <= pacman_x_int_i+1;
                    if (pacman_x_int_i=474 and (Pacman_y_int_i=202 or Pacman_y_int_i=201 or Pacman_y_int_i=200 or Pacman_y_int_i=203 or Pacman_y_int_i=204) )then
                        pacman_x_int_i<=124;
                    elsif pacman_x_int_i = 475 then
                        pacman_x_int_i <= 474;
                    end if;
                
                --move left
                elsif (left = '0' and pac_crash='0' )then -- and not(death_i=3)) then
                    pacman_x_int_i <= pacman_x_int_i-1;
                    if (pacman_x_int_i=124 and (Pacman_y_int_i=202 or Pacman_y_int_i=201 or Pacman_y_int_i=200 or Pacman_y_int_i=203 or Pacman_y_int_i=204) )then
                        pacman_x_int_i<=474;
                    elsif pacman_x_int_i = 123 then
                        pacman_x_int_i<= 124;
                    end if;
                
                --move down
                elsif (down = '0' and pac_crash='0' )then -- and not(death_i=3)) then
                    pacman_y_int_i <= pacman_y_int_i+1;
                    if pacman_y_int_i = 399 then
                        pacman_y_int_i <= 398;
                    end if;
                    
                --move up
                elsif (up = '0' and pac_crash='0' )then -- and not(death_i=3)) then
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
                    if death_i >=4 then
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
