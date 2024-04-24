----------------------------------------------------------------------------------
-- Company: Point Loma Nazarene University
-- Engineer: Kyle Dramov
-- 
-- Create Date: 04/09/2024 08:36:19 PM
-- Design Name: DotDraw
-- Module Name: DotDraw - Behavioral
-- Project Name: PacMan
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity DotDraw is
   generic(
        constant OBJECT_SIZE : integer :=14;
        constant Dot_SIZE : integer :=6
   );
  Port ( 
        Dot_XL             : in integer range 0 to 28;
        Dot_YT             : in integer range 0 to 32;
        pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        Dot_on             : out std_logic;
        pacman_x_int        : in integer range 0 to 640;
        pacman_y_int        : in integer range 0 to 480;
        score_out           : out std_logic :='0'
  );
end DotDraw;

architecture Behavioral of DotDraw is
    constant start_X : integer:=124;
    constant start_Y : integer:=6;
    signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);
    --signal pacman_x_int : integer;
    --signal pacman_y_int : integer;
    signal dot_x : integer;
    signal dot_y : integer;
    
    signal dot_crash: std_logic := '0';
    signal eaten : std_logic := '0';


begin
    
    dot_x <= Dot_XL*OBJECT_SIZE + start_X;
    dot_y <= Dot_YT*OBJECT_SIZE + start_Y;

    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    
    process
    begin
        if(eaten = '0') then
            if ( (pacman_x_int=dot_x AND pacman_y_int=dot_y) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x+1 AND pacman_y_int=dot_y) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x+2 AND pacman_y_int=dot_y) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x-1 AND pacman_y_int=dot_y) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x-2 AND pacman_y_int=dot_y) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x AND pacman_y_int=dot_y+1) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x AND pacman_y_int=dot_y+2) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x AND pacman_y_int=dot_y-1) ) then
                eaten <= '1';
                score_out <= '1';
            elsif ( (pacman_x_int=dot_x AND pacman_y_int= (dot_y-2)) ) then
                eaten <= '1';
                score_out <= '1';
            end if;
         end if;
--        if ( rising_edge(dot_crash) AND eaten = '0') then
--             eaten <= '1';
--             score_out <= '1';
--        end if;
    end process;
    
    process
    begin
        if(eaten= '0')then
            if ((dot_x+Dot_SIZE) <= pix_x and 
            pix_x <=(dot_x + OBJECT_SIZE-Dot_SIZE) and 
            pix_y <= (dot_y + OBJECT_SIZE-Dot_SIZE) and 
            (dot_y+Dot_SIZE) <= pix_y ) then
                Dot_on<='1';
            else
                dot_on <= '0';
            end if;
        else 
            Dot_on<='0';
        end if;
        
    end process;
end Behavioral;