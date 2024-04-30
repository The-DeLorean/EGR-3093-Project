----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2024 03:03:38 PM
-- Design Name: 
-- Module Name: TIME_Graphic - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity Game_Over_text is
    generic (
        OBJECT_SIZE : natural := 14
        );
    Port (
     pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
     object_x, object_y : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
     letter             : in std_logic_vector (6 downto 0);
     death_int          : in integer range 0 to 4;
     user_win           : IN std_logic;
     game_over_on       : out std_logic
     
     );
end Game_Over_text;


architecture Behavioral of Game_Over_text is
    constant Graphic_size: integer:=OBJECT_SIZE;
    signal Graphic_x_l : unsigned(Graphic_size-1 downto 0);
    signal Graphic_y_t : unsigned(Graphic_size-1 downto 0);
    signal Graphic_x_r : unsigned(Graphic_size-1 downto 0);
    signal Graphic_y_b : unsigned(Graphic_size-1 downto 0);
   
    
    signal Graphic_onBuffer, square_Graphic_on : std_logic;
    
    --ROM FOR PAC MAN LIFE GRAPHIC
    type rom_type is array (0 to Graphic_size-1) of std_logic_vector(Graphic_size-1 downto 0);
    constant Rom_G: rom_type := (
         "00000000000000",
         "00000000000000",
         "11111111111000",
         "11111111111100",
         "00000000001100",
         "00000000001110",
         "11111110001110",
         "11111100001110",
         "11000000001110",
         "11000000001110",
         "01111111111110",
         "00111111111110",
         "00000000000000",
         "00000000000000"
     );
     
     constant Rom_A: rom_type := (
         "00000000000000",
         "00000000000000",
         "01111111111110",
         "01111111111110",
         "01110000001110",
         "01110000001110",
         "01110000001110",
         "01111111111110",
         "01111111111110",
         "01110000001110",
         "01110000001110",
         "01110000001110",
         "00000000000000",
         "00000000000000"
    );
     
constant Rom_O: rom_type := (
         "00000000000000",
         "00000000000000",
         "00011111111000",
         "00111111111100",
         "01110000001110",
         "01100000000110",
         "01100000000110",
         "01100000000110",
         "01100000000110",
         "01110000001110",
         "00111111111100",
         "00011111111000",
         "00000000000000",
         "00000000000000"
     );
     
     constant Rom_M: rom_type := (
         "00000000000000",
         "00000000000000",
         "01110000000111",
         "01111100001111",
         "01111110011111",
         "01111011110111",
         "01110011100111",
         "01110001100111",
         "01110000000111",
         "01110000000111",
         "01110000000111",
         "01110000000111",
         "00000000000000",
         "00000000000000"
    );
    
  constant Rom_E: rom_type := (
         "00000000000000",
         "00000000000000",
         "01111111111110",
         "01111111111110",
         "00000000001110",
         "00000000001110",
         "01111111111110",
         "01111111111110",
         "00000000001110",
         "00000000001110",
         "01111111111110",
         "01111111111110",
         "00000000000000",
         "00000000000000"
    );
    
    constant Rom_V: rom_type := (
         "00000000000000",
         "00000000000000",
         "01100000000011",
         "01100000000011",
         "01110000000111",
         "01110000000111",
         "00111100011110",
         "00111100011110",
         "00011110111100",
         "00001110111000",
         "00000111110000",
         "00000011100000",
         "00000000000000",
         "00000000000000"
        );
    constant Rom_R: rom_type := (
         "00000000000000",
         "00000000000000",
         "01111111111110",
         "01111111111110",
         "01100000001110",
         "01110000001110",
         "00111111111110",
         "00111111111110",
         "01111100001110",
         "01111000001110",
         "01110000001110",
         "01110000001110",
         "00000000000000",
         "00000000000000"
    );
    
    constant Rom_Y: rom_type := (
         "00000000000000",
         "01100000000011",
         "01100000000011",
         "01110000000111",
         "00111100011110",
         "00011110111100",
         "00001110111000",
         "00000111110000",
         "00000011100000",
         "00000011100000",
         "00000011100000",
         "00000011100000",
         "00000011100000",
         "00000000000000"
        );
    

--signals for the rom address
    signal rom_addr, rom_col: unsigned(0 to 3);
    signal rom_bit: std_logic;
    
    -- signals that holds the x, y coordinates
    signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);
    signal letter_x_l : unsigned(OBJECT_SIZE-1 downto 0);
    signal letter_y_t : unsigned(OBJECT_SIZE-1 downto 0);
    signal letter_x_r : unsigned(OBJECT_SIZE-1 downto 0);
    signal letter_y_b : unsigned(OBJECT_SIZE-1 downto 0);

    signal square_letter_on : std_logic;

begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    letter_x_l <= unsigned(object_x);
    letter_y_t <= unsigned(object_y);
    letter_x_r <= letter_x_l + OBJECT_SIZE - 1;
    letter_y_b <= letter_y_t + OBJECT_SIZE - 1;
    
    --** finding where the pac man footprint square is
        square_letter_on <= '1' when letter_x_l<=pix_x and pix_x<=letter_x_r and
                                  letter_y_t<=pix_y and pix_y<=letter_y_b else '0';
                                  
        rom_addr <= pix_y(3 downto 0) - letter_y_t(3 downto 0);
        rom_col <= pix_x(3 downto 0) - letter_x_l(3 downto 0);
        process
        begin
            case letter is
                when "1000000" =>
                 rom_bit<= ROM_G(to_integer(rom_addr))(to_integer(rom_col));
                 when "0100000" =>
                 rom_bit<= ROM_A(to_integer(rom_addr))(to_integer(rom_col));
                 when "0010000" =>
                 rom_bit<= ROM_M(to_integer(rom_addr))(to_integer(rom_col));
                 when "0001000" =>
                 rom_bit<= ROM_E(to_integer(rom_addr))(to_integer(rom_col));
                 when "0000100" =>
                 rom_bit<= ROM_O(to_integer(rom_addr))(to_integer(rom_col));
                 when "0000010" =>
                 rom_bit<= ROM_V(to_integer(rom_addr))(to_integer(rom_col));
                 when "0000001" =>
                 rom_bit<= ROM_R(to_integer(rom_addr))(to_integer(rom_col));
                 when others =>
                 rom_bit<='0';
            end case;
        end process;
        
        game_over_on <= '1' when square_letter_on='1' and rom_bit='1' and (death_int>=3 or user_win='1') else '0';
end Behavioral;