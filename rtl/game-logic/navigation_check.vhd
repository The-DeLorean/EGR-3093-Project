----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Dorian Quimby
-- 
-- Create Date: 04/16/2024 04:35:17 PM
-- Design Name: 
-- Module Name: navigation_check - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module takes in the location of a game object (Pacman or ghost).
-- It will return flags based on whether certain moves are possible.
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
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity navigation_check is
    Port ( x_pos : in integer;
           y_pos : in integer;
           down  : in std_logic;
           right : in std_logic;
           clk :in std_logic;
           collision : out std_logic
           --up : out std_logic;
           --down : out std_logic
           );
end navigation_check;

architecture Behavioral of navigation_check is
constant rom_depth : natural := 30; --30
constant rom_width : natural := 27;--27
signal collision_i : std_logic:='0';

signal wall_bit: std_logic:='0';
signal y_pos_i : integer;
signal x_pos_i : integer;

signal pac_loc_x :integer range 0 to 30;
signal pac_loc_y :integer range 0 to 30;

signal count_i :integer;

type wall_type is array (0 to rom_depth -1) of std_logic_vector(rom_width - 1 downto 0);
constant walls : wall_type :=(
                            "000000000000110000000000001",
                            "011110111110110111110111101",
                            "011110111110110111110111101",
                            "011110111110110111110111101",
                            "000000000000000000000000001",
                            "011110110111111110110111101",
                            "011110110111111110110111101",
                            "000000110000110000110000001",
                            "111110111110110111110111111",
                            "000010111110110111110100001",
                            "000010110000000000110100001",
                            "000010110111111110110100001",
                            "111110110100000010110111111",
                            "000000000100000010000000001",
                            "111110110100000010110111111",
                            "000010110111111110110100001",
                            "000010110000000000110100001",
                            "000010110111111110110100001",
                            "111110110111111110110111111",
                            "000000000000110000000000001",
                            "011110111110110111110111101",
                            "011110111110110111110111101",
                            "000110000000000000000110001",
                            "110110110111111110110110111",
                            "110110110111111110110110111",
                            "000000110000110000110000001",
                            "011111111110110111111111101",
                            "011111111110110111111111101",
                            "000000000000000000000000001",
                            "111111111111111111111111111");

begin 

y_pos_i<=y_pos;
x_pos_i<=x_pos;

process
begin
     if rising_edge(clk) then
            count_i <= count_i +1;          --increment
            if count_i = 2000000 then
                count_i <= 0;             
                if down='0' then
                    pac_loc_x<= x_pos/14;
                    pac_loc_y<= (y_pos+1)/14;
                    if (walls(pac_loc_y+1)(pac_loc_x)='1') then
                        collision_i<='1';
                    else
                        collision_i<='0';
                    end if;
                 elsif right='0' then
                    pac_loc_x<= (x_pos+1)/14;
                    pac_loc_y<= y_pos/14;
                    if (walls(pac_loc_y)(pac_loc_x+1)='1') then
                        collision_i<='1';
                    else
                        collision_i<='0';
                    end if;
                 else
                    collision_i<='0';
                end if;
            end if;
    end if;
end process;

process
begin 
    
end process;

process
begin
----            WORKS BEST I THINK Unccoment lines below to have it almost work perfectly
--    for i in 0 to rom_depth - 1 loop 
--        for j in 0 to rom_width - 1 loop
--           wait for 1 ns;
--           --assign wall bit
--           wall_bit <= walls(i)(j);
--           if( wall_bit = '1' ) then --if there is actually a block there
--                if(down='0') then -- if pac man is moving down
--                        if (((y_pos_i  >= (i*14) + 6-14) and y_pos_i<(i*14) And x_pos_i > (j*14)+124 and x_pos_i < (j*14)+124+14)) then--or ((x_pos_i=(j*14)+124)and(y_pos_i  >= (i*14) + 6-14) and y_pos_i<(i*14)) then
--                            collision_i<='1'; -- collision
--                        elsif ((x_pos_i=(j*14)+124) and (y_pos_i  > (i*14) + 6-14) and y_pos_i<(i*14)) then
--                            collision_i<='1';
--                       end if;
--                end if;
--           end if;
--        end loop;
--    end loop;  
end process;

collision <= collision_i;
end Behavioral;
