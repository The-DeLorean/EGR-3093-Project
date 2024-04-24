----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2024 03:58:16 PM
-- Design Name: 
-- Module Name: Ghost_navigation_check - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
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

entity Ghost_navigation_check is
  Port (  
        Ghost_x_pos        : in integer;
        Ghost_y_pos        : in integer;
        clk                :in std_logic;
        right_collision    : out std_logic;
        left_collision     : out std_logic;
        up_collision       : out std_logic;
        down_collision     : out std_logic
        );
end Ghost_navigation_check;

architecture Behavioral of Ghost_navigation_check is
constant rom_depth : natural := 29; --30
constant rom_width : natural := 26;--27

--integer locatio of ghost pos
signal ghost_y_pos_i : integer;
signal ghost_x_pos_i : integer;

-- location of ghost truncated
signal ghost_loc_x :integer range 0 to 30;
signal ghost_loc_y :integer range 0 to 30;
signal ghost_loc_x_left :integer range 0 to 30;
signal ghost_loc_y_up :integer range 0 to 30;

--Counter to keep in sync
signal count_i :integer;

--Array of Bit to represent map
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

--Signals to output collisions for valid moves                           
signal right_collision_i : std_logic:='1';
signal left_collision_i : std_logic:='1';
signal up_collision_i : std_logic:='1';
signal down_collision_i : std_logic:='1';

begin
ghost_x_pos_i<=ghost_x_pos;
ghost_y_pos_i<=ghost_y_pos;

process
begin
    --Works for right and Down.
    ghost_loc_x<= (ghost_x_pos_i-124)/14;
    ghost_loc_y<= (ghost_y_pos_i-6)/14;
    --Use one of these for left and Up
    ghost_loc_x_left<= (ghost_x_pos_i-124+14)/14;
    ghost_loc_y_up<= (ghost_y_pos_i-6+14)/14;
    if (rising_edge(clk)) then
    count_i <= count_i +1;          --increment
        if count_i = 2000000 then
            count_i <= 0;
            --Checking for right collision
            if (walls(ghost_loc_y)(ghost_loc_x+1)='1') then
                right_collision_i<='0';
            else
                right_collision_i<='1';
            end if; 
            
            --Checking for left collision
            if (walls(ghost_loc_y)(ghost_loc_x_left-1)='1') then
                left_collision_i<='0';
            else
                left_collision_i<='1';
            end if; 
            
            --Checking for down collision
            if (walls(ghost_loc_y_up+1)(ghost_loc_x)='1') then
                down_collision_i<='0';
            else
                down_collision_i<='1';
            end if; 
            
            --Checking for up collision
            if (walls(ghost_loc_y-1)(ghost_loc_x)='1') then
                up_collision_i<='0';
            else
                up_collision_i<='1';
            end if; 
        end if;   
    end if;
end process;

right_collision<=right_collision_i;
left_collision<=left_collision_i;
up_collision<=up_collision_i;
down_collision<=down_collision_i;

end Behavioral;