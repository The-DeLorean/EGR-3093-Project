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
            moving   : in boolean;
            pacman_x_int   : in integer range 0 to 640;
            pacman_y_int   : in integer range 0 to 480;
            pinky_x_int    : in integer range 0 to 640;
            pinky_y_int    : in integer range 0 to 480;
            pinky_x_int_out : out integer range 0 to 640;
            pinky_y_int_out : out integer range 0 to 480;
            powerup     : in std_logic;
            --p e c s r
            ghost_state_vec   : in std_logic_vector(4 downto 0));
end pinky;

architecture Behavioral of pinky is

 --internal signals
signal pacman_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pacman_y_int_i     : integer range 0 to 480:=314; 
signal pinky_x_int_i     : integer range 0 to 640:=299; -- starting coordinates (240,340)
signal pinky_y_int_i     : integer range 0 to 480:=174; 
signal count          : integer;
signal moving_i : boolean;
signal ghost_state_vec_i : std_logic_vector(4 downto 0); 
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

component Ghost_navigation_check is
  Port (  
        Ghost_x_pos        : in integer;
        Ghost_y_pos        : in integer;
        clk                :in std_logic;
        right_collision    : out std_logic;
        left_collision     : out std_logic;
        up_collision       : out std_logic;
        down_collision     : out std_logic
        );
end component;

--signals to signify collision
signal right_i : std_logic:='1';
signal left_i : std_logic:='1';
signal up_i : std_logic:='1';
signal down_i : std_logic:='1';

begin
    --assign internals
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    pinky_x_int_i <= pinky_x_int;
    pinky_y_int_i <= pinky_y_int;
    ghost_state_vec_i <= ghost_state_vec;

    --checking for collisions
    collision_check_all_directions: Ghost_navigation_check port map (ghost_x_pos=>pinky_x_int_i, ghost_y_pos=>pinky_y_int_i, clk=>clk, right_collision=> right_i, left_collision=> left_i, up_collision=> up_i, down_collision=> down_i);

    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count >=2000000 then
            count<=0;
            if ghost_state_vec="10000" then
                if prison_right='0' then
                    pinky_x_int_i<=pinky_x_int_i+1;
                    if pinky_x_int_i >=334 then
                        prison_right<='1';
                    end if;
                else
                    pinky_x_int_i<=pinky_x_int_i-1;
                    if pinky_x_int_i <=264 then
                        prison_right<='0';
                    end if;
                end if;
                pinky_y_int_i<=174;
            elsif ghost_state_vec="01000" then
                pinky_x_int_i<=299;
                pinky_y_int_i<=146;
            elsif ghost_state_vec="00100" then
                    --x pacman hunter 
                    --top left
                    if t_l_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        if left_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i-1;
                            t_l_corner<='0'; 
                        end if;   
                    --top right
                    elsif t_r_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i+1;
                        if right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                            t_r_corner<='0'; 
                        end if;
                    --bot right
                    elsif b_r_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                        if right_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i+1;
                            b_r_corner<='0'; 
                        end if;
                    --bot left
                    elsif b_l_corner = '1' then
                        pinky_y_int_i<=pinky_y_int_i-1;
                        if left_i = '1' then
                            pinky_x_int_i<=pinky_x_int_i-1;
                            b_l_corner<='0'; 
                        end if;
                    elsif pinky_x_int_i = pacman_x_int_i or (left_i = '0' and right_i = '0') then
                    --do y hunting
                        --down
                        if pinky_y_int_i < pacman_y_int_i and down_i = '1' then
                            pinky_y_int_i<=pinky_y_int_i+1;
                        --up
                        elsif pinky_y_int_i > pacman_y_int_i and up_i = '1' then
                            pinky_y_int_i<=pinky_y_int_i-1;
                        end if;
                    --right
                    elsif pinky_x_int_i < pacman_x_int_i and right_i = '1' then
                        pinky_x_int_i<=pinky_x_int_i+1;
                    --left
                    elsif pinky_x_int_i > pacman_x_int_i and left_i = '1' then
                        pinky_x_int_i<=pinky_x_int_i-1;
                    --top left corner stuck
                    elsif up_i = '0' and left_i = '0' then
                        t_l_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i+1;
                    --top right corner stuck
                    elsif up_i = '0' and right_i = '0' then
                        t_r_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i+1;
                    --bot right corner stuck
                    elsif down_i = '0' and right_i = '0' then
                        b_r_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i-1;
                    --bot left corner stuck
                    elsif down_i = '0' and left_i = '0' then
                        b_l_corner<='1';
                        pinky_y_int_i<=pinky_y_int_i-1;
                    end if;
            elsif ghost_state_vec="00010" then
                   --Scattering to Top Right corner
                    if pinky_y_int_i = 6 or (pinky_y_int_i = 150 and (pinky_x_int_i = 240 or pinky_x_int_i = 241)) then
                    --do y hunting
                        if pinky_x_int_i > 124 then
                            pinky_x_int_i<=pinky_x_int_i+1;
                        end if; 
                    elsif pinky_y_int_i > 6 then
                        pinky_y_int_i<=pinky_y_int_i-1;
                    end if;
            elsif ghost_state_vec="00001" then
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
           end if;
        end if;
    end process;
    --output pinky new position 
    pinky_x_int_out <= pinky_x_int_i;
    pinky_y_int_out <= pinky_y_int_i;
end Behavioral;