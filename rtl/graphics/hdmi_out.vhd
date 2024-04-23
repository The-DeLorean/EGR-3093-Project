-- author: Kyle Dramov, 2024
-- description: hdmi out top module
--    consists of the timing module, clock manager and tgb to tdms encoder
--    three different resolutions are added, selectable from the generic
--    objectbuffer is added that displays 2 controllable 1 stationary objects
--    optional pattern generator is added

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity hdmi_out is
    generic (
        RESOLUTION   : string  := "VGA"; -- HD1080P, HD720P, SVGA, VGA
        GEN_PATTERN  : boolean := false; -- generate pattern or objects
        GEN_PIX_LOC  : boolean := true; -- generate location counters for x / y coordinates
        OBJECT_SIZE  : natural := 14; -- size of the objects. should be higher than 11
        PIXEL_SIZE   : natural := 24; -- RGB pixel total size. (R + G + B)
        SERIES6      : boolean := false -- disables OSERDESE2 and enables OSERDESE1 for GHDL simulation (7 series vs 6 series)
    );
    port(
        clk, rst : in std_logic;
        right    : in std_logic;
        left     : in std_logic;
        up       : in std_logic;
        down     : in std_logic;
        -- tmds output ports
        clk_p    : out std_logic;
        clk_n    : out std_logic;
        data_p   : out std_logic_vector(2 downto 0);
        data_n   : out std_logic_vector(2 downto 0);
        chase_led     : out STD_LOGIC;
        scatter_led     : out STD_LOGIC;
        retreat_led     : out STD_LOGIC;
        score_out       : out INTEGER
    );
end hdmi_out;

architecture rtl of hdmi_out is

    --DO NOT TOUCH -HDMI converter signals
    signal pixclk, serclk : std_logic;
    signal video_active   : std_logic := '0';
    signal video_data     : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal vsync, hsync   : std_logic := '0';
    
    --Main Pixels used to draw images
    signal pixel_x        : std_logic_vector(OBJECT_SIZE-1 downto 0);
    signal pixel_y        : std_logic_vector(OBJECT_SIZE-1 downto 0);
    signal object1x       : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(500, OBJECT_SIZE));
    signal object1y       : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(140, OBJECT_SIZE));
    
    --PacMan Location
    signal pacman_x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(240, OBJECT_SIZE));
    signal pacman_y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(340, OBJECT_SIZE));
    signal pacman_x_int     : integer range 0 to 640; -- starting coordinates (240,340)
    signal pacman_y_int     : integer range 0 to 480; 
    
    --Inky Location
    signal inky_x          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal inky_y          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));

    --Clyde Location
    signal clyde_x         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal clyde_y         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));

    
    --Pinky
    signal pinky_x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal pinky_y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    --Blinky
    signal blinky_x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal blinky_y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));

    --Background color
    signal backgrnd_rgb   : std_logic_vector(PIXEL_SIZE-1 downto 0) := x"000000"; -- yellow

    signal pac_moving              : boolean;
    
    --Potentially Clock animation still working**
    signal animated_clock  : integer; 
    
    --Integer to keep trac of pac man deaths
    signal death : integer range 0 to 4 :=0;
    
begin
    game_logic_i: entity work.game_logic(Behavioral)
        port map (  clk => clk,
                    rst => rst,
                    right => right,
                    left => left,
                    up => up,
                    down => down,
                    pac_moving => pac_moving,
                    pac_moving_out=> pac_moving,
                    death_out=> death,
                    pacman_x => pacman_x, 
                    pacman_y => pacman_y,
                    inky_x => inky_x, 
                    inky_y => inky_y,
                    pinky_x => pinky_x,
                    pinky_y => pinky_y,
                    blinky_x => blinky_x,
                    blinky_y => blinky_y,
                    clyde_x => clyde_x,
                    clyde_y => clyde_y,
                    pacman_x_int_out => pacman_x_int, 
                    pacman_y_int_out => pacman_y_int);
    
    --chase_led <= chase_b;
    --scatter_led <= scatter_b;
    --retreat_led <= retreat_b;

    timing_vga: if RESOLUTION = "VGA" generate
    begin
    clock: entity work.clock_gen(rtl)
        generic map (CLKIN_PERIOD=>10.000, CLK_MULTIPLY=>10, CLK_DIVIDE=>1, CLKOUT0_DIV=>10, CLKOUT1_DIV=>50) -- 640x480
        port map (clk_i=>clk, clk0_o=>serclk, clk1_o=>pixclk );
    end generate;

    -- video timing
    timing: entity work.timing_generator(rtl)
        generic map (RESOLUTION => RESOLUTION, GEN_PIX_LOC => GEN_PIX_LOC, OBJECT_SIZE => OBJECT_SIZE)
        port map (clk=>pixclk, hsync=>hsync, vsync=>vsync, video_active=>video_active, pixel_x=>pixel_x, pixel_y=>pixel_y);

    -- tmds signaling
    tmds_signaling: entity work.rgb2tmds(rtl)
        generic map (SERIES6=>SERIES6)
        port map (rst=>rst, pixelclock=>pixclk, serialclock=>serclk,
        video_data=>video_data, video_active=>video_active, hsync=>hsync, vsync=>vsync,
        clk_p=>clk_p, clk_n=>clk_n, data_p=>data_p, data_n=>data_n);

    -- game object buffer
    gen_obj: if GEN_PATTERN = false generate
    begin
    objbuf: entity work.objectbuffer(rtl)
        generic map (OBJECT_SIZE=>OBJECT_SIZE, PIXEL_SIZE =>PIXEL_SIZE)
        port map (video_active=>video_active, pixel_x=>pixel_x, pixel_y=>pixel_y,
        object1x=>object1x, object1y=>object1y,
        pacman_x=>pacman_x, pacman_y=>pacman_y,
        inky_x=>inky_x, inky_y=>inky_y,
        clyde_x=>clyde_x, clyde_y=>clyde_y,
        pinky_x=>pinky_x, pinky_y=>pinky_y,
        blinky_x=>blinky_x, blinky_y=>blinky_y,
        backgrnd_rgb=>backgrnd_rgb, rgb=>video_data, MVariable=> pac_moving, death_int=>death,
        score_out=>score_out,
        pacman_x_int => pacman_x_int,
        pacman_y_int => pacman_y_int);
    end generate;
end rtl;
