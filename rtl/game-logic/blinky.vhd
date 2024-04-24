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
    blinky_x_int_i <= blinky_x_int;
    blinky_y_int_i <= blinky_y_int;
    pacman_x_int_i <= pacman_x_int;
    pacman_y_int_i <= pacman_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    Ghost_collisons_all_directions: Ghost_navigation_check port map (ghost_x_pos=>blinky_x_int_i, ghost_y_pos=>blinky_y_int_i, clk=>clk, right_collision=>right_i, left_collision=>left_i, up_collision=>up_i, down_collision=>down_i);
    
    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count>=2000000 then
            count<=0;
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
                    --head pacman hunter 
                    --top left stuck
                    if t_l_corner = '1' then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        if left_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i-1;
                            t_l_corner<='0'; 
                            alternate <= 1;
                        end if;   
                    --top right stuck
                    elsif t_r_corner = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        if up_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i-1;
                            t_r_corner<='0'; 
                            alternate <= 0;
                        end if;
                    --bot right stuck
                    elsif b_r_corner = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        if down_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i+1;
                            b_r_corner<='0'; 
                            alternate <= 0;
                        end if;
                    --bot left stuck
                    elsif b_l_corner = '1' then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        if left_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i-1;
                            b_l_corner<='0';
                            alternate <= 1; 
                        end if;
                    --down right move
                    elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                        --right
                        if alternate = 1 and right_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i+1;
                            alternate <= 0;
                        --down
                        elsif alternate = 0 and down_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i+1;
                            alternate <= 1;
                        end if;
                    --up rightmove
                    elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                        if alternate = 1 and right_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i+1;
                            alternate <= 0;
                        elsif alternate = 0 and up_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i-1;
                            alternate <= 1;
                        end if;
                    --left down move
                    elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i < pacman_y_int_i then
                        if alternate = 1 and left_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i-1;
                            alternate <= 0;
                        elsif alternate = 0 and down_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i+1;
                            alternate <= 1;
                        end if;
                    --left up move
                    elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i > pacman_y_int_i then
                        if alternate = 1 and left_i = '1' then
                            blinky_x_int_i<=blinky_x_int_i-1;
                            alternate <= 0;
                        elsif alternate = 0 and up_i = '1' then
                            blinky_y_int_i<=blinky_y_int_i-1;
                            alternate <= 1;
                        end if;
                    --down move
                    elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i < pacman_y_int_i and down_i = '1' then
                        blinky_y_int_i<=blinky_y_int_i+1;
                        alternate <= 0;
                    --up move
                    elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i > pacman_y_int_i and up_i = '1' then
                        blinky_y_int_i<=blinky_y_int_i-1;
                        alternate <= 0;   
                    --right move
                    elsif blinky_x_int_i < pacman_x_int_i and blinky_y_int_i = pacman_y_int_i and right_i = '1' then
                        blinky_x_int_i<=blinky_x_int_i+1;
                        alternate <= 1; 
                    --left move
                    elsif blinky_x_int_i > pacman_x_int_i and blinky_y_int_i = pacman_y_int_i and left_i = '1' then
                        blinky_x_int_i<=blinky_x_int_i-1;
                        alternate <= 1; 
                    --game over
                    elsif blinky_x_int_i = pacman_x_int_i and blinky_y_int_i = pacman_y_int_i then
                        --gameover
                    --top left corner stuck
                    elsif up_i = '0' and left_i = '0' then
                        t_l_corner<='1';
                        blinky_y_int_i<=blinky_y_int_i+1;
                    --top right corner stuck
                    elsif up_i = '0' and right_i = '0' then
                        t_r_corner<='1';
                        blinky_x_int_i<=blinky_x_int_i-1;
                    --bot right corner stuck
                    elsif down_i = '0' and right_i = '0' then
                        b_r_corner<='1';
                        blinky_x_int_i<=blinky_x_int_i-1;
                    --bot left corner stuck
                    elsif down_i = '0' and left_i = '0' then
                        b_l_corner<='1';
                        blinky_y_int_i<=blinky_y_int_i-1;
                    end if;
               end if;
           --Scatter state
           elsif ghost_state_vec="00010" then
               --Scattering to bot right corner
                if blinky_y_int_i = 6 or (blinky_y_int_i = 150 and (blinky_x_int_i = 240 or blinky_x_int_i = 241)) then
                --do y hunting
                    if blinky_x_int_i > 124 then
                        blinky_x_int_i<=blinky_x_int_i+1;
                    end if; 
                elsif blinky_y_int_i > 6 then
                    blinky_y_int_i<=blinky_y_int_i+1;
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
        end if;
    end if;   
    end process;
    --output pinky new position 
    blinky_x_int_out <= blinky_x_int_i;
    blinky_y_int_out <= blinky_y_int_i;
end Behavioral;
