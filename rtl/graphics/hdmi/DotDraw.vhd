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

entity DotDraw is
   generic(
        constant OBJECT_SIZE : integer :=14;
        constant Dot_SIZE : integer :=6
   );
  Port ( 
        Dot_XL             : in integer range 0 to 28;
        Dot_YT             : in integer range 0 to 32;
        pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        visible            : in std_logic;
        Dot_on             : out std_logic
  );
end DotDraw;

architecture Behavioral of DotDraw is
    constant start_X : integer:=124;
    constant start_Y : integer:=6;
    signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);
begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    process (visible)
    begin
        if(visible='1')then
            if ((start_X + (Dot_XL*OBJECT_SIZE)+Dot_SIZE) <= pix_x and pix_x <=((Dot_XL*OBJECT_SIZE) + start_X + OBJECT_SIZE-Dot_SIZE) and pix_y <= ((Dot_YT*OBJECT_SIZE) + start_Y + OBJECT_SIZE-Dot_SIZE) and (start_Y + (OBJECT_SIZE*Dot_YT)+Dot_SIZE) <= pix_y ) then
                Dot_on<='1';
            else 
                Dot_on<='0';
            end if;
        end if;
    end process;
end Behavioral;
