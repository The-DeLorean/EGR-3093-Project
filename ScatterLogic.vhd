----------------------------------------------------------------------------------
-- Company: Point Loma Nazarene Universty
-- Engineer: Kyle Dramov
-- 
-- Create Date: 04/06/2024 10:35:58 PM
-- Design Name: Retro PacMan
-- Module Name: ScatterLogic - Behavioral
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity ScatterLogic is
    generic (
        OBJECT_SIZE : natural := 14
        );
    Port ( 
           clk        : in STD_LOGIC;
           Corner     : in integer range 0 to 3;
           right      : in boolean;
           left       : in boolean;
           up         : in boolean;
           down       : in boolean;
           prevX      : integer;
           prevY      : integer;
           PosX       : out std_logic_vector(OBJECT_SIZE-1 downto 0);
           PosY       : out std_logic_vector(OBJECT_SIZE-1 downto 0));
end ScatterLogic;

architecture Behavioral of ScatterLogic is
    signal xdir : integer range 0 to 520:=prevX;
    signal ydir : integer range 5 to 480:=prevY;
begin
    process
    begin
        if rising_edge(clk) then
            if Corner = 0 then
            
            elsif Corner =1 then
            
            elsif Corner =2 then
            
            elsif Corner =3 then
            
            end if;
        end if;
    end process;
PosX<= std_logic_vector(to_unsigned(xdir, OBJECT_SIZE));
PosY<= std_logic_vector(to_unsigned(ydir, OBJECT_SIZE));
end Behavioral;
