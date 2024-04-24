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
        clk                : in std_logic;
        right_collision    : out std_logic;
        left_collision     : out std_logic;
        up_collision       : out std_logic;
        down_collision     : out std_logic
        );
end Ghost_navigation_check;

architecture Behavioral of Ghost_navigation_check is
constant rom_depth : natural := 31; --30
constant rom_width : natural := 28;--27

--integer locatio of ghost pos
signal ghost_y_pos_i : integer;
signal ghost_x_pos_i : integer;

-- location of ghost truncated
signal ghost_loc_x :integer range 0 to 30;
signal ghost_loc_y :integer range 0 to 30;
signal ghost_loc_x_fright :integer range 0 to 30;
signal ghost_loc_y_fdown :integer range 0 to 30;
signal ghost_loc_x_left :integer range 0 to 30;
signal ghost_loc_y_up :integer range 0 to 30;

--Counter to keep in sync
signal count_i :integer;

--Array of Bit to represent map
type wall_type is array (0 to rom_depth -1) of std_logic_vector(rom_width - 1 downto 0);
constant walls : wall_type :=(
                            "1111111111111111111111111111",
                            "1000000000000110000000000001",
                            "1011110111110110111110111101",
                            "1011110111110110111110111101",
                            "1011110111110110111110111101",
                            "1000000000000000000000000001",
                            "1011110110111111110110111101",
                            "1011110110111111110110111101",
                            "1000000110000110000110000001",
                            "1111110111110110111110111111",
                            "1000010111110110111110100001",
                            "1000010110000000000110100001",
                            "1000010110111111110110100001",
                            "1111110110100000010110111111",
                            "1000000000100000010000000001",
                            "1111110110100000010110111111",
                            "1000010110111111110110100001",
                            "1000010110000000000110100001",
                            "1000010110111111110110100001",
                            "1111110110111111110110111111",
                            "1000000000000110000000000001",
                            "1011110111110110111110111101",
                            "1011110111110110111110111101",
                            "1000110000000000000000110001",
                            "1110110110111111110110110111",
                            "1110110110111111110110110111",
                            "1000000110000110000110000001",
                            "1011111111110110111111111101",
                            "1011111111110110111111111101",
                            "1000000000000000000000000001",
                            "1111111111111111111111111111"
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
    ghost_loc_x_fright<=(ghost_x_pos_i-124+1)/14;
    ghost_loc_y_fdown<= (ghost_y_pos_i-6+1)/14;
    --Use one of these for left and Up moving the corner to the spo its supposed to be
    ghost_loc_x_left<= (ghost_x_pos_i-124+13)/14;
    ghost_loc_y_up<= (ghost_y_pos_i-6+13)/14;
    if (rising_edge(clk)) then
    count_i <= count_i +1;          --increment
        if count_i = 2000000 then
            count_i <= 0;
            --Checking for right collision
            if (walls(ghost_loc_y+1)(ghost_loc_x_fright+1+1)='1') then
                right_collision_i<='0';
            else
                right_collision_i<='1';
            end if; 
            
            --Checking for left collision
            if (walls(ghost_loc_y+1)(ghost_loc_x_left-1+1)='1') then
                left_collision_i<='0';
            else
                left_collision_i<='1';
            end if; 
            
            --Checking for down collision
            if (walls(ghost_loc_y_fdown+1+1)(ghost_loc_x+1)='1') then
                down_collision_i<='0';
            else
                down_collision_i<='1';
            end if; 
            
            --Checking for up collision
            if (walls(ghost_loc_y_up-1+1)(ghost_loc_x+1)='1') then
                up_collision_i<='0';
            else
                up_collision_i<='1';
            end if; 
        end if;   
    end if;
end process;

--Assigning signals
right_collision<=right_collision_i;
left_collision<=left_collision_i;
up_collision<=up_collision_i;
down_collision<=down_collision_i;

end Behavioral;