library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity StillPacManDraw is
    generic (
        OBJECT_SIZE : natural := 14
        );
    Port (
    pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
    object_x, object_y : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
    Animation          : in boolean;
    PacMan_on          : out std_logic
    );
end StillPacManDraw;

architecture Behavioral of StillPacManDraw is
    constant PACMAN_SIZE: integer:=OBJECT_SIZE;
    signal PacMan_x_l : unsigned(PACMAN_SIZE-1 downto 0);
    signal PacMan_y_t : unsigned(PACMAN_SIZE-1 downto 0);
    signal PacMan_x_r : unsigned(PACMAN_SIZE-1 downto 0);
    signal PacMan_y_b : unsigned(PACMAN_SIZE-1 downto 0);
   
    
    signal PacMan_onBuffer, square_PacMan_on : std_logic;
    
    --ROM FOR PAC MAN LIFE GRAPHIC
    type rom_type is array (0 to PACMAN_SIZE-1) of std_logic_vector(PACMAN_SIZE-1 downto 0);
    constant Pac_ROMO: rom_type := (
        "00001111110000", --   ******     000000000000000
        "00011111111000", --  ********
        "00111111111100", -- **********
        "01111111001100", -- **********
        "00111111001110", -- **********
        "00011111111110", -- **********
        "00000111111111", --  ********
        "00000111111111", --   ******
        "00011111111110",
        "00111111111110",
        "01111111111100",
        "00111111111100",
        "00011111111000",
        "00001111110000"
    );
    
    constant Pac_ROMC: rom_type := (
        "00001111110000", --   ******     000000000000000
        "00011111111000", --  ********
        "00111111111100", -- **********
        "00111110011100", -- **********
        "01111110011110", -- **********
        "01111111111110", -- **********
        "11111111111111", --  ********
        "11111111111111", --   ******
        "01111111111110",
        "01111111111110",
        "00111111111100",
        "00111111111100",
        "00011111111000",
        "00001111110000"
    );
    
    --signals for the rom address
    signal rom_addr, rom_col: unsigned(0 to 3);
    signal rom_bit: std_logic;
    
    -- signals that holds the x, y coordinates
    signal pix_x, pix_y: unsigned (PACMAN_SIZE-1 downto 0);
    
begin
    
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    PacMan_x_l <= unsigned(object_x);
    PacMan_y_t <= unsigned(object_y);
    PacMan_x_r <= PacMan_x_l + PACMAN_SIZE - 1;
    PacMan_y_b <= PacMan_y_t + PACMAN_SIZE - 1;
    --** finding where the pac man footprint square is
    square_PacMan_on <= '1' when PacMan_x_l<=pix_x and pix_x<=PacMan_x_r and
                                 PacMan_y_t<=pix_y and pix_y<=PacMan_y_b else '0';

    --IF IN the Pacman square find the ROM to produce the PACMAN image                           
    -- map current pixel location to ROM addr/col
    rom_addr <= pix_y(3 downto 0) - PacMan_y_t(3 downto 0);
    rom_col <= pix_x(3 downto 0) - PacMan_x_l(3 downto 0);
    --MAKING THE MOUTH OPEN/CLOSE
rom_bit <= Pac_ROMC(to_integer(rom_addr))(to_integer(rom_col)) when animation else
               Pac_ROMO(to_integer(rom_addr))(to_integer(rom_col));
    --turning on Pixels of pac man
    PacMan_onBuffer <= '1' when square_PacMan_on='1' and rom_bit='1' else '0';
    
    PacMan_on<= PacMan_onBuffer;
end Behavioral;
