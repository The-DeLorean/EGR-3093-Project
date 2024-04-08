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
        right    : in boolean:=true;
        left     : in boolean:=false;
        up       : in boolean:=false;
        down     : in boolean:=false;
        -- tmds output ports
        clk_p    : out std_logic;
        clk_n    : out std_logic;
        data_p   : out std_logic_vector(2 downto 0);
        data_n   : out std_logic_vector(2 downto 0);
        chaseLED     : out STD_LOGIC;
        scatterLED     : out STD_LOGIC;
        RetreatLED     : out STD_LOGIC
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
    --Inky Location
    signal inky_x          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal inky_y          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    --Clyde Location
    signal clyde_x         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal clyde_y         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    signal ghost_2_x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal ghost_2_y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    signal ghost_3_x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal ghost_3_y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    --Background color
    signal backgrnd_rgb   : std_logic_vector(PIXEL_SIZE-1 downto 0) := x"000000"; -- yellow
    --Pac Man Direction variables
    signal pacman_dir_x     : integer range 0 to 640:=240;
    signal pacman_dir_y     : integer range 0 to 480:=340; 
    --Inky Direction variables
    signal inky_dir_x       : integer range 0 to 640:=300;
    signal inky_dir_y       : integer range 0 to 480:=100;
    --Clyde Direction variables
    signal clyde_dir_x      : integer range 0 to 640:=100;
    signal clyde_dir_y      : integer range 0 to 480:=100;
    signal clyde_dir_x_out      : integer range 0 to 640:=100;
    signal clyde_dir_y_out      : integer range 0 to 480:=100;
    --Counter for game speed
    signal count          : integer;
    --Pac Man Boolean variables
    signal r              : boolean:=true;
    signal l              : boolean:=false;
    signal u              : boolean:=false;
    signal d              : boolean:=false;
    signal m              : boolean:=true;
    --Potentially Clock animation still working**
    signal animated_clock  : integer; 
    
    --Variables to signify power up chase scatter retreat
    signal powerup_b       : std_logic:='0';
    signal prison_b        : std_logic:='0';
    signal escape_b        : std_logic:='0';
    signal chase_b         : std_logic:='0';
    signal scatter_b       : std_logic:='0';
    signal retreat_b       : std_logic:='0';
    
    signal start_time      : integer;
    signal start_game     : std_logic:='0';
    

    --Component to call Clyde Logic
    component Clyde is
    port (
        --pacman location
        pacman_x : in integer range 0 to 640:=240;
        pacman_y : in integer range 0 to 480:=340;
        --clyde location
        clyde_x : in integer range 0 to 640:=240;
        clyde_y : in integer range 0 to 480:=100;
        --output new clyde location
        clyde_xout : out integer range 0 to 640:=240;
        clyde_yout : out integer range 0 to 480:=100;
        clk : in std_logic;
        chase : in std_logic
        );
    end Component;

    --Component for the Ghost state Machine
    Component Ghost_SM is
        Port ( 
               start_game : in std_logic;
               clk        : in STD_LOGIC;
               powerup    : in STD_LOGIC;
               chase      : out STD_LOGIC;
               scatter    : out STD_LOGIC;
               Retreat    : out STD_LOGIC);
    end component;
    signal chaseS : std_logic:='1';
    --Component For the Retreat logic
    Component retreat is
    port (
        --pacman location
        pacman_x : in integer range 0 to 640;
        pacman_y : in integer range 0 to 480;
        --ghost location
        GhostX : in integer range 0 to 640;
        Ghosty : in integer range 0 to 480;
        --outputs
        GhostXout : out integer range 0 to 640;
        GhostYout : out integer range 0 to 480;
        clk : in std_logic;
        --check if clyde that needs retreat
        clyde : in std_logic
    );
    end component;
    
begin

--Calculating Pac Man and Inky Position
-- TO MAKE JOYSTICK WORK REPLACE R L D AND U WITH RIGHT LEFT UP AND DOWN
process
    begin
    wait for 10 ns;
    if rising_edge(clk) then
        count<=count +1;
        if count =2000000 then
            clyde_dir_x<=clyde_dir_x_out;
            clyde_dir_y<=clyde_dir_y_out;
            m<=not(m);
            count<=0;
            if r = true then
                pacman_dir_x<=pacman_dir_x+1;
                inky_dir_x<=inky_dir_x-1;
                if pacman_dir_x =503 then
                    pacman_dir_x<=502;
                    r<= false;
                end if;
                if inky_dir_x =123 then
                    inky_dir_x<=124;
                end if;
            elsif l = true then
                pacman_dir_x<=pacman_dir_x-1;
                inky_dir_x<=inky_dir_x+1;
                if pacman_dir_x = 123 then
                    pacman_dir_x<= 124;
                end if;
                if inky_dir_x = 503 then
                    inky_dir_x<=502;
                end if;
            elsif d = true then
                pacman_dir_y<=pacman_dir_y+1;
                inky_dir_y<=inky_dir_y-1;
                if pacman_dir_y = 440 then
                    pacman_dir_y<= 439;
                end if;
                if inky_dir_y =4 then
                    inky_dir_y<=5;
                end if;
            elsif u = true then
                pacman_dir_y<=pacman_dir_y-1;
                inky_dir_y<=inky_dir_y+1;
                if pacman_dir_y = 4 then
                    pacman_dir_y<= 5;
                end if;
                if inky_dir_y = 440 then
                    inky_dir_y<= 439;
                end if;
            end if;
        end if;
    end if;
    end process;
    --PacMan Position
    pacman_x<= std_logic_vector(to_unsigned(pacman_dir_x, OBJECT_SIZE));
    pacman_y<= std_logic_vector(to_unsigned(pacman_dir_y, OBJECT_SIZE));
    
    --Ghost State Machine to change between ghost states Prison->Escape->CHASE->SCATTER->Retreat
    --Still Need to make Prison and Escape
    Clyde_States: Ghost_SM port map(start_game=>start_game, clk=> clk, powerup=> powerup_b, chase=> chase_b, scatter=> scatter_b, Retreat=> retreat_b);
    chaseLed<=chase_b;
    scatterLed<=scatter_b;
    RetreatLed<=retreat_b;
    process
    begin
        if rising_edge(clk) then
            start_time<=start_time+1;
            if start_time = 1700000000 then
                start_time<=0;
                start_game<='1';
            end if;
        end if;
    end process;
    
    --Giving Inky position
    inky_x<= std_logic_vector(to_unsigned(inky_dir_x, OBJECT_SIZE));
    inky_y<= std_logic_vector(to_unsigned(inky_dir_y, OBJECT_SIZE));
    
    -- Clyde Logic 
    clydechaseLogic:  Clyde port map (pacman_x=> pacman_dir_x, pacman_y=> pacman_dir_y, clyde_x=> clyde_dir_x, clyde_y=> clyde_dir_y, clyde_xout=> clyde_dir_x_out, clyde_yout => clyde_dir_y_out, clk=> clk, chase=> chase_b ); 
    --MAKE NOT HAVE MULTIPLE DRIVERS IF RETREAT THAN CLYDES LOCATION HAS MULTIPLE DRIVERS
    --clydeRetreatLogic: retreat port map (pacman_x=> pacman_dir_x, pacman_y=> pacman_dir_y, GhostX=> clyde_dir_x, GhostY=> clyde_dir_y, GhostXOut=> clyde_dir_x_out, GhostYOut => clyde_dir_y_out, clk=> clk, Clyde=> retreat_b);
    --Giving Clyde Position
    clyde_x<= std_logic_vector(to_unsigned(clyde_dir_x_out, OBJECT_SIZE));
    clyde_y<= std_logic_vector(to_unsigned(clyde_dir_y_out, OBJECT_SIZE));
    
    
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
        ghost_2_x=>ghost_2_x, ghost_2_y=>ghost_2_y,
        ghost_3_x=>ghost_3_x, ghost_3_y=>ghost_3_y,
        backgrnd_rgb=>backgrnd_rgb, rgb=>video_data, MVariable=> m);
    end generate;
end rtl;
