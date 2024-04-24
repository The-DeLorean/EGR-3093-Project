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
           right : in std_logic;
           left  : in std_logic;
           up    : in std_logic;
           down  : in std_logic;
           clk :in std_logic;
           collision : out std_logic
           
           );
end navigation_check;

architecture Behavioral of navigation_check is
constant rom_depth : natural := 29; --30
constant rom_width : natural := 26;--27
signal collision_i : std_logic:='0';

signal y_pos_i : integer;
signal x_pos_i : integer;

signal pac_loc_x :integer range 0 to 30;
signal pac_loc_y :integer range 0 to 30;

signal count_i :integer;

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

y_pos_i<=y_pos;
x_pos_i<=x_pos;

process
begin
     if rising_edge(clk) then
            count_i <= count_i +1;          --increment
            if count_i = 2000000 then
                count_i <= 0;   
                if right='0' then
                    pac_loc_x<= (x_pos_i-124)/14;
                    pac_loc_y<= (y_pos_i-6)/14;
                    if (walls(pac_loc_y)(pac_loc_x+1)='1') then
                        collision_i<='1';
                    else
                        collision_i<='0';
                    end if;  
                elsif left='0' then
                    pac_loc_x<= (x_pos_i-124+11)/14;
                    pac_loc_y<= (y_pos_i-6)/14;
                    if (walls(pac_loc_y)(pac_loc_x-1)='1') then
                        collision_i<='1';
                    else
                        collision_i<='0';
                    end if;
                 elsif up='0' then
                    pac_loc_x<= (x_pos_i-124)/14;
                    pac_loc_y<= (y_pos_i-6+11)/14;
                    if (walls(pac_loc_y-1)(pac_loc_x)='1') then
                        collision_i<='1';
                    else
                        collision_i<='0';
                    end if;        
                elsif down='0' then
                    pac_loc_x<= (x_pos_i-124)/14;
                    pac_loc_y<= (y_pos_i-6)/14;
                    if (walls(pac_loc_y+1)(pac_loc_x)='1') then
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
collision <= collision_i;
end Behavioral;
