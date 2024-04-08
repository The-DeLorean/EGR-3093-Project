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
        ChaseLED     : out STD_LOGIC;
        ScatterLED     : out STD_LOGIC;
        RetreatLED     : out STD_LOGIC
    );
end hdmi_out;

architecture rtl of hdmi_out is

    --DO NOT TOUCH
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
    signal PacManx        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(240, OBJECT_SIZE));
    signal PacMany        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(340, OBJECT_SIZE));
    --Inky Location
    signal InkyX          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal InkyY          : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    --Clyde Location
    signal ClydeX         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal ClydeY         : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    signal ghost2x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal ghost2y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    signal ghost3x        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
    signal ghost3y        : std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
    --Background color
    signal backgrnd_rgb   : std_logic_vector(PIXEL_SIZE-1 downto 0) := x"000000"; -- yellow
    --Pac Man Direction variables
    signal PacMandirx     : integer range 0 to 640:=240;
    signal PacMandiry     : integer range 0 to 480:=340; 
    --Inky Direction variables
    signal Inkydirx       : integer range 0 to 640:=300;
    signal Inkydiry       : integer range 0 to 480:=100;
    --Clyde Direction variables
    signal ClydeDirx      : integer range 0 to 640:=100;
    signal ClydeDirY      : integer range 0 to 480:=100;
    signal ClydeDirxOut      : integer range 0 to 640:=100;
    signal ClydeDirYOut      : integer range 0 to 480:=100;
    --Counter for game speed
    signal count          : integer;
    --Pac Man Boolean variables
    signal r              : boolean:=true;
    signal l              : boolean:=false;
    signal u              : boolean:=false;
    signal d              : boolean:=false;
    signal m              : boolean:=true;
    --Potentially Clock animation still working**
    signal animatedclock  : integer; 
    
    --Variables to signify power up chase scatter retreat
    signal PowerupB       : std_logic:='0';
    signal PrisonB        : std_logic:='0';
    signal EscapeB        : std_logic:='0';
    signal ChaseB         : std_logic:='0';
    signal ScatterB       : std_logic:='0';
    signal RetreatB       : std_logic:='0';
    
    signal StartTime      : integer;
    signal Start_Game     : std_logic:='0';
    

    --Component to call Clyde Logic
    component Clyde is
    port (
        --pacman location
        PacManx : in integer range 0 to 640:=240;
        PacMany : in integer range 0 to 480:=340;
        --clyde location
        ClydeX : in integer range 0 to 640:=240;
        ClydeY : in integer range 0 to 480:=100;
        --output new clyde location
        ClydeXout : out integer range 0 to 640:=240;
        ClydeYout : out integer range 0 to 480:=100;
        clk : in std_logic;
        Chase : in std_logic
        );
    end Component;

    --Component for the Ghost state Machine
    Component Ghost_SM is
        Port ( 
               Start_Game : in std_logic;
               clk        : in STD_LOGIC;
               PowerUp    : in STD_LOGIC;
               Chase      : out STD_LOGIC;
               Scatter    : out STD_LOGIC;
               Retreat    : out STD_LOGIC);
    end component;
    signal ChaseS : std_logic:='1';
    --Component For the Retreat logic
    Component retreat is
    port (
        --pacman location
        PacManx : in integer range 0 to 640;
        PacMany : in integer range 0 to 480;
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
            ClydeDirx<=ClydeDirxOut;
            ClydeDiry<=ClydeDiryOut;
            m<=not(m);
            count<=0;
            if r = true then
                PacMandirx<=PacMandirx+1;
                Inkydirx<=Inkydirx-1;
                if PacMandirx =503 then
                    PacMandirx<=502;
                    r<= false;
                end if;
                if Inkydirx =123 then
                    Inkydirx<=124;
                end if;
            elsif l = true then
                PacMandirx<=PacMandirx-1;
                Inkydirx<=Inkydirx+1;
                if PacMandirx = 123 then
                    PacMandirx<= 124;
                end if;
                if Inkydirx = 503 then
                    Inkydirx<=502;
                end if;
            elsif d = true then
                PacMandiry<=PacMandiry+1;
                Inkydiry<=Inkydiry-1;
                if PacMandiry = 440 then
                    PacMandiry<= 439;
                end if;
                if Inkydiry =4 then
                    Inkydiry<=5;
                end if;
            elsif u = true then
                PacMandiry<=PacMandiry-1;
                Inkydiry<=Inkydiry+1;
                if PacMandiry = 4 then
                    PacMandiry<= 5;
                end if;
                if Inkydiry = 440 then
                    Inkydiry<= 439;
                end if;
            end if;
        end if;
    end if;
    end process;
    --PacMan Position
    PacManx<= std_logic_vector(to_unsigned(PacMandirx, OBJECT_SIZE));
    PacMany<= std_logic_vector(to_unsigned(PacMandiry, OBJECT_SIZE));
    
    --Ghost State Machine to change between ghost states Prison->Escape->CHASE->SCATTER->Retreat
    --Still Need to make Prison and Escape
    Clyde_States: Ghost_SM port map(Start_Game=>Start_Game, clk=> clk, PowerUp=> PowerUpB , Chase=> ChaseB, Scatter=> ScatterB, Retreat=> RetreatB);
    ChaseLed<=chaseB;
    ScatterLed<=ScatterB;
    RetreatLed<=RetreatB;
    process
    begin
        if rising_edge(clk) then
            StartTime<=StartTime+1;
            if StartTime = 1700000000 then
                StartTime<=0;
                Start_Game<='1';
            end if;
        end if;
    end process;
    
    --Giving Inky position
    InkyX<= std_logic_vector(to_unsigned(Inkydirx, OBJECT_SIZE));
    InkyY<= std_logic_vector(to_unsigned(Inkydiry, OBJECT_SIZE));
    
    -- Clyde Logic 
    clydeChaseLogic:  Clyde port map (PacManx=> PacMandirx, PacMany=> PacMandiry, ClydeX=> ClydeDirx, ClydeY=> ClydeDiry, ClydeXout=> ClydeDirxOut, ClydeYout => ClydeDiryOut, clk=> clk, Chase=> ChaseB ); 
    --MAKE NOT HAVE MULTIPLE DRIVERS IF RETREAT THAN CLYDES LOCATION HAS MULTIPLE DRIVERS
    --clydeRetreatLogic: retreat port map (PacManx=> PacMandirx, PacMany=> PacMandiry, GhostX=> ClydeDirx, GhostY=> ClydeDiry, GhostXOut=> ClydeDirxOut, GhostYOut => ClydeDiryOut, clk=> clk, Clyde=> RetreatB);
    --Giving Clyde Position
    ClydeX<= std_logic_vector(to_unsigned(ClydeDirxOut, OBJECT_SIZE));
    ClydeY<= std_logic_vector(to_unsigned(ClydeDiryOut, OBJECT_SIZE));
    
    
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
        PacManx=>PacManx, PacMany=>PacMany,
        InkyX=>InkyX, InkyY=>InkyY,
        ClydeX=>ClydeX, ClydeY=>ClydeY,
        ghost2x=>ghost2x, ghost2y=>ghost2y,
        ghost3x=>ghost3x, ghost3y=>ghost3y,
        backgrnd_rgb=>backgrnd_rgb, rgb=>video_data, MVariable=> m);
    end generate;
end rtl;
