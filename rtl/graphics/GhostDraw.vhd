
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity GhostDraw is
    generic (
        OBJECT_SIZE : natural := 14
        );
    Port ( 
    pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
    object_x, object_y : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
    Ghost_on : out std_logic
    );
end GhostDraw;
architecture Behavioral of GhostDraw is
    constant GHOST_SIZE : integer :=OBJECT_SIZE;
    signal Ghost_x_l : unsigned(GHOST_SIZE-1 downto 0);
    signal Ghost_x_r : unsigned(GHOST_SIZE-1 downto 0);
    signal Ghost_y_t : unsigned(GHOST_SIZE-1 downto 0);
    signal Ghost_y_b : unsigned(GHOST_SIZE-1 downto 0);
    
    
    signal Ghost_onBuffer, square_Ghost_on : std_logic;
    
    type rom_typeG is array (0 to GHOST_SIZE-1) of std_logic_vector(GHOST_SIZE-1 downto 0);
    constant GHOST_ROM: rom_typeG := (
        "00000011100000",     
        "00011111111000",
        "00111111111100", 
        "00111111111100", 
        "01100011000110",
        "01100011000110", 
        "11100011000111",
        "11111111111111", 
        "11111111111111",
        "11111111111111",
        "11111111111111",
        "11111111111111",
        "11001100110011",
        "10000100100001"
    );

    --Sigals for calculating the memory adress
    signal rom_addrG, rom_colG: unsigned(0 to 3);
    signal rom_bitG: std_logic;
    
    -- signals that holds the x, y coordinates
    signal pix_x, pix_y: unsigned (GHOST_SIZE-1 downto 0);
begin
    
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);
    
    --DRAW GHOSTS
    --Determining the square of the ghosts
    ghost_x_l <= unsigned(object_x);
    ghost_y_t <= unsigned(object_y);
    ghost_x_r <= ghost_x_l + GHOST_SIZE - 1;
    ghost_y_b <= ghost_y_t + GHOST_SIZE - 1;
    --Checking to see if the pixel is in the ghost's square
    square_ghost_on <= '1' when ghost_x_l<=pix_x and pix_x<=ghost_x_r and
                               ghost_y_t<=pix_y and pix_y<=ghost_y_b else '0';
    -- map current pixel location to ROM addr/col
    rom_addrG <= pix_y(3 downto 0) - ghost_y_t(3 downto 0);
    rom_colG <= pix_x(3 downto 0) - ghost_x_l(3 downto 0);
    rom_bitG <= GHOST_ROM(to_integer(rom_addrG))(to_integer(rom_colG));
    -- pixel within ball
    ghost_on <= '1' when square_ghost_on='1' and rom_bitG='1' else '0';
    -- ball rgb output

end Behavioral;
