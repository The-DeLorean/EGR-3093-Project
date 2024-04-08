-- Kyle Dramov 2024
-- Point Loma Nazarene University
-- Digital Electronics 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MazeWalls is
   generic(
        constant OBJECT_SIZE : integer :=14
   );
  Port (
        Wall_XL             : in integer range 0 to 28;
        Wall_YT             : in integer range 0 to 32;
        length             : in integer range 0 to 28;
        height             : in integer range 0 to 32;
        pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        Wall_on            : out std_logic
   );
end MazeWalls;

architecture Behavioral of MazeWalls is
    constant statX : integer:=124;
    constant statY : integer:=5;
    signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);
      
begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    Wall_on <= '1' when (124 + (WALL_XL*14)) <= pix_x and pix_x <=((WALL_XL*14) + 124 + (length*14)) and pix_y <= ((WALL_YT*14) + 6 + (height*14)) and (6 + (14*WALL_YT)) <= pix_y  else '0';
end Behavioral;
