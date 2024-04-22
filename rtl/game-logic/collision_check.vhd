----------------------------------------------------------------------------------
-- Company: Point Loma Nazarene University
-- Engineer: Dorian Quimby
-- 
-- Create Date: 04/15/2024 09:59:52 PM
-- Design Name: 
-- Module Name: collision_check - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Checks if ghosts and pacman are overlapping by comparing x and y coordinates 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity collides is
    Port ( obj_a_x : in integer;
           obj_a_y : in integer;
           obj_b_x : in integer;
           obj_b_y : in integer;
           collision : out std_logic);
end collides;

architecture Behavioral of collides is

begin

    process
    begin
        --if object coordinates match then a collision is triggered
        if ((obj_a_x = obj_b_x) AND (obj_a_y = obj_b_y)) then
        collision <= '1';
        else
        collision <= '0';
        end if;
    end process;
    
end Behavioral;
