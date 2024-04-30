-- author: Kyle Dramov, 2024
-- description: object buffer that holds the objects to display
--    object locations can be controlled from upper level
--    example contains a wall, a rectanble box and a round ball

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity objectbuffer is
    generic (
        OBJECT_SIZE : natural := 14;
        PIXEL_SIZE : natural := 24;
        RES_X : natural := 640;
        RES_Y : natural := 480
    );
    port (
        video_active       : in  std_logic;
        pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        object1x, object1y : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        pacman_x, pacman_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        inky_x, inky_y       : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        clyde_x, clyde_y     : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        pinky_x, pinky_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        blinky_x, blinky_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        backgrnd_rgb       : in  std_logic_vector(PIXEL_SIZE-1 downto 0);
        rgb                : out std_logic_vector(PIXEL_SIZE-1 downto 0);
        mVariable          : in boolean;
        death_int              : in integer range 0 to 4;
        score_out           : out integer;
        pacman_x_int        : in integer range 0 to 640;
        pacman_y_int        : in integer range 0 to 480
    );
end objectbuffer;

architecture rtl of objectbuffer is
    -- create a 5 pixel vertical wall
    constant WALL_X_L0: integer := 118;
    constant WALL_X_R0: integer := 123;
    
    constant WALL_X_L1: integer := 489;
    constant WALL_X_R1: integer := 494;
    
    constant WALL_Y_B2: integer := 5;
    
    constant WALL_Y_T3: integer := 412;
    constant WALL_Y_B3: integer := 417;
    
    constant Ghost_GateXL: integer :=(124+(OBJECT_SIZE*12));
    constant Ghost_GateXR: integer :=(124+(OBJECT_SIZE*14));
    constant Ghost_GateYT: integer :=((11*OBJECT_SIZE)+6+4);
    constant Ghost_GateYB: integer :=((OBJECT_SIZE*11)+6+OBJECT_SIZE-4);

    -- 1st object is a vertical box 48x8 pixel
    constant BOX_SIZE_X: integer :=  14;
    constant BOX_SIZE_Y: integer := 14;
    -- x, y coordinates of the box
    signal box_x_l : unsigned (OBJECT_SIZE-1 downto 0);
    signal box_y_t : unsigned (OBJECT_SIZE-1 downto 0);
    signal box_x_r : unsigned (OBJECT_SIZE-1 downto 0);
    signal box_y_b : unsigned (OBJECT_SIZE-1 downto 0);

    -- signals that holds the x, y coordinates
    signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);

    signal Border_on0, Border_on1, Border_on2, Border_on3, box_on, PacMan_on, Inky_on, Clyde_on, Pinky_on, Blinky_on, stillPacMan_on0, stillPacMan_on1, stillPacMan_on2, GhostGate_on, game_over_on_G, game_Over_on_A, game_Over_on_M, game_Over_on_E, game_Over_on_O, game_Over_on_V, game_Over_on_E1, game_Over_on_R, portal_on : std_logic;
    signal Border_rgb, box_rgb, PacMan_rgb, Clyde_rgb, Inky_rgb, Pinky_rgb, Blinky_rgb, GhostGate_rgb: std_logic_vector(23 downto 0);

    --Coordinates of the Pac Man Lives
    signal stillpacman_x0 : std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(130, OBJECT_SIZE));
    signal stillpacman_x1 : std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(150, OBJECT_SIZE));
    signal stillpacman_x2 : std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(170, OBJECT_SIZE));
    signal stillpacman_y0 : std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(420, OBJECT_SIZE));
    
    -- ****   MAZE WALLS   *****
    --NUMBER OF WALLS DRAWN
    constant wall_num : integer := 49;
    --Arrays for wall positions
    type int_vect_Walls is array (0 to wall_num-1) of integer range 0 to 32;
    --                                    | Walls go from left to right top to bottom in a snaking pattern. Starting at the top of the wall down|              | left tunnel sides | |  right tunnel sides  ||    Ghost Box     |                       
    constant  Wall_Xvalues : int_vect_walls := (12, 1, 6, 15, 21, 1, 6, 8, 9, 12, 18, 15, 21, 6,  18, 9,  12, 1,  3,  6,  15, 21, 21, 0,  24, 6,  1,  9,  12, 18, 15, 0, 4, 0,  0,  4,  0,  21, 21, 21, 21, 21, 21, 9,  9,  9,  14, 16, 12 );
    constant  Wall_Yvalues : int_vect_walls := (0,  1, 1, 1,  1,  5, 5, 8, 5, 7,  5,  8,  5,  14, 14, 17, 19, 20, 22, 20, 20, 20, 22, 23, 23, 23, 26, 23, 25, 23, 26, 8, 9, 12, 14, 15, 18, 8,  9,  12, 14, 15, 18, 11, 12, 15, 11, 12, 0  );
    constant  Wall_Lengths : int_vect_walls := (2,  4, 5, 5,  4,  4, 2, 3, 8, 2,  2,  3,  4,  2,  2,  8,  2,  4,  2,  5,  5,  4,  2,  2,  2,  2,  10, 8,  2,  2,  10, 5, 1, 5,  5,  1,  5,  5,  1,  5,  5,  1,  5,  3,  1,  8,  3,  1,  0  );
    constant  Wall_Heights : int_vect_walls := (4,  3, 3, 3,  3,  2, 8, 2, 2, 3,  8,  2,  2,  5,  5,  2,  3,  2,  3,  2,  2,  2,  3,  2,  2,  3,  2,  2,  3,  3,  2,  1, 3, 1,  1,  3,  1,  1,  3,  1,  1,  3,  1,  1,  3,  1,  1,  3,  0  );
    
   --Variable to hold the outputs of all the walls   
    type std_logic_array_walls is array (0 to wall_num-1) of std_logic;
    signal Wall_On : std_logic_array_walls;   
    
    -- ****   DOTS   ***** prev 68 
    constant dot_num : integer:=256;--:= NuM;
    --Array type to hold all the dot positions
    type int_vect_dots is array (0 to dot_num-1) of integer range 0 to 32;
    --
    --                                                                          *** TOP ROW***                                   |                         Columns                                ||                                         2nd Big Row                                        ||                           2nd Columns   ||               Snd Row with multiple dots                             ||          Dots Through top of ghost gate                                                                   | New Dots further down    line below ghost gate                       |     NEXT                                           5 rows of dots                           174 dots here     |                                                   200 Dots here                                        |
    constant dot_xvalues : int_vect_dots :=(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0, 5, 11, 14, 20, 25, 0, 5, 11, 14, 20, 25, 0, 5, 11, 14, 20, 25, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0, 5, 8, 17, 20, 25, 0, 5, 8, 17, 20, 25, 0, 1, 2, 3, 4, 5, 8, 9, 10, 11, 14, 15, 16, 17, 20, 21, 22, 23, 24, 25, 5, 20, 5, 20, 5,  20, 5,  20, 5,  20, 0,  1,  2,  3,  4,  5,  20, 21, 22, 23, 24, 25, 5,  20, 5,  20, 5,  20, 5,  20, 5,  20, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0,  5,  11, 14, 20, 25, 0,  5,  11, 14, 20, 25, 0,  1,  2,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 23, 24, 25, 2,  5,  8,  17, 20, 23, 2,  5,  8,  17, 20, 23, 0,  1,  2,  3,  4,  5,  8,  9,  10, 11, 14, 15, 16, 17, 20, 21, 22, 23, 24, 25, 0,  11, 14, 25, 0,  11, 14, 25, 0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25);
    constant dot_yvalues : int_vect_dots :=(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1, 1, 1,  1,  1,  1,  2, 2, 2,  2,  2,  2,  3, 3, 3,  3,  3,  3,  4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  5, 5, 5, 5,  5,  5,  6, 6, 6, 6,  6,  6,  7, 7, 7, 7, 7, 7, 7, 7, 7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  8, 8,  9, 9,  10, 10, 11, 11, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 27, 27, 27, 27,28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28);
    
    --Variable to hold the outputs of all the dots
    type std_logic_array_dots is array (0 to dot_num-1) of std_logic;
    signal Dot_on      : std_logic_array_dots;
    --Arrays to make a dot disappearing add 1 to score
    signal score_out_arr      : std_logic_array_dots  :=('0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0');
    signal score_out_arr_i      : std_logic_array_dots:=('1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1','1'); 
    signal score_out_i  : integer := 0;
    signal temp         : integer :=0;
    
    component StillPacManDraw is
    Port (
        pixel_x, pixel_y   : in  std_logic_vector(13 downto 0);
        object_x, object_y : in  std_logic_vector(13 downto 0);
        animation          : in boolean;
        visible            : in std_logic;
        PacMan_on : out std_logic
    );
    end component;
    
    component GhostDraw is
    Port ( 
        pixel_x, pixel_y   : in  std_logic_vector(13 downto 0);
        object_x, object_y : in  std_logic_vector(13 downto 0);
        Ghost_on : out std_logic
    );
    end component;
    
    component MazeWalls is
      Port (
            Wall_XL             : in integer range 0 to 392;
            Wall_YT             : in integer range 0 to 453;
            length             : in integer range 0 to 453;
            height             : in integer range 0 to 453;
            pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
            Wall_on            : out std_logic
        );
    end component;
    
  component DotDraw is
  Port ( 
        Dot_XL             : in integer range 0 to 28;
        Dot_YT             : in integer range 0 to 32;
        pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
        Dot_on             : out std_logic;
        pacman_x_int        : in integer range 0 to 640;
        pacman_y_int        : in integer range 0 to 480;
        score_out           : out std_logic
       );
  end component ;
  
  component Game_Over_text is
    Port (
     pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
     object_x, object_y : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
     letter             : in std_logic_vector (6 downto 0);
     death_int          : in integer range 0 to 4;
     game_over_on          : out std_logic
     );
end component;

     signal game_over_y: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(130, OBJECT_SIZE));
     
     --Signal to hold x values of all the Lettters in game over
     signal g_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(243, OBJECT_SIZE));
     signal a_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(257, OBJECT_SIZE));
     signal m_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(271, OBJECT_SIZE));
     signal e_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(285, OBJECT_SIZE));
     signal o_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(313, OBJECT_SIZE));
     signal v_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(327, OBJECT_SIZE));
     signal e_x_1: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(341, OBJECT_SIZE));
     signal r_x: std_logic_vector(OBJECT_SIZE-1 downto 0):= std_logic_vector(to_unsigned(355, OBJECT_SIZE));
     
     --Visible Bits for PacMan Lifes
     signal visible_i_0 : std_logic;
     signal visible_i_1 : std_logic;
     signal visible_i_2 : std_logic;
     
     --Pac_mans Visibility signal
     signal Pac_visible : std_logic:='1';

begin
    
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    --Pac Man Frame
    -- draw Right wall
    Border_on0 <= '1' when WALL_X_L0<=pix_x and pix_x<=WALL_X_R0 and pix_y <= WALL_Y_B3 else '0';
    -- draw left wall and color
    Border_on1 <= '1' when WALL_X_L1<=pix_x and pix_x<=WALL_X_R1 and pix_y <= WALL_Y_B3 else '0';
    -- draw Top Border
    Border_on2 <= '1' when WALL_X_L0<=pix_x and pix_x<=WALL_X_R1 and pix_y <= WALL_Y_B2 else '0';
    -- draw Bottom Border
    Border_on3 <= '1' when WALL_X_L0<=pix_x and pix_x<=WALL_X_R1 and pix_y <= WALL_Y_B3 and WALL_Y_T3 <= pix_y  else '0';
    --The Border Color
    Border_rgb <= x"0000FF"; -- blue
    
    --portal openening
    portal_on <= '1' when (WALL_X_L0 <=pix_x and pix_x<= WALL_X_R0 and pix_y <= 202  and 188 <= pix_y) or (WALL_X_L1 <=pix_x and pix_x<= WALL_X_R1 and pix_y <= 202  and 188 <= pix_y) else '0';


    --Drawing PAC MAN Maze
    Walls: for i in 0 to wall_num-1 generate
        wall: MazeWalls port map (Wall_XL=> Wall_Xvalues(i), Wall_YT=> Wall_Yvalues(i), length=> Wall_Lengths(i), height => Wall_Heights(i), pixel_x=> pixel_x, pixel_y=> pixel_y, Wall_on=>Wall_on(i)); 
    end generate Walls;
    
     --Drawing dots 
    dots: for i in 0 to dot_num-1 generate
        dot: dotdraw port map (Dot_XL=> dot_xvalues(i) ,Dot_YT=> dot_yvalues(i), pixel_x=>pixel_x, pixel_y=> pixel_y, dot_on=> dot_on(i), pacman_x_int => pacman_x_int, pacman_y_int => pacman_y_int, score_out => score_out_arr(i));
    end generate dots;
    
    --Drawing the Ghost Gate
    GhostGate_on <= '1' when (Ghost_GateXL) <= pix_x and pix_x <=(Ghost_GateXR) and pix_y <= (Ghost_GateYB) and (Ghost_GateYT) <= pix_y  else '0';
    GhostGate_rgb<= x"FFB8FF";
    

--DRAW the STILL PAC MAN AS LIVEs
    -- making the visibility of the lives on the screen change as the deaths increase 
      visible_i_0<='1' when death_int<=2 else '0';
      visible_i_1<='1' when death_int<=1 else '0';
      visible_i_2<='1' when death_int=0  else '0';
      --Drawing the Lives on the screen
      stillPac0 : StillPacManDraw port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>stillpacman_x0, object_y=>stillpacman_y0, animation=> false, visible=> visible_i_0, PacMan_on=>stillPacMan_on0); 
      stillPac1 : StillPacManDraw port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>stillpacman_x1, object_y=>stillpacman_y0, animation=> false, visible=> visible_i_1, PacMan_on=>stillPacMan_on1);
      stillPac2 : StillPacManDraw port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>stillpacman_x2, object_y=>stillpacman_y0, animation=> false, visible=> visible_i_2, PacMan_on=>stillPacMan_on2);
    
--Drawing game Over
    --Wont be on until deat_int=3
    G: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>g_x, object_y=>game_over_y, letter=>  "1000000", death_int=>death_int, game_Over_on=>game_Over_on_G);
    A: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>A_x, object_y=>game_over_y, letter=>  "0100000", death_int=>death_int, game_Over_on=>game_Over_on_A);
    M: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>M_x, object_y=>game_over_y, letter=>  "0010000", death_int=>death_int, game_Over_on=>game_Over_on_M);
    E0: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>E_x, object_y=>game_over_y, letter=> "0001000", death_int=>death_int, game_Over_on=>game_Over_on_E);
    O: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>O_x, object_y=>game_over_y, letter=>  "0000100", death_int=>death_int, game_Over_on=>game_Over_on_O);
    V: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>V_x, object_y=>game_over_y, letter=>  "0000010", death_int=>death_int, game_Over_on=>game_Over_on_V);
    E1: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>E_x_1, object_y=>game_over_y, letter=> "0001000", death_int=>death_int, game_Over_on=>game_Over_on_E1);
    R: Game_Over_text port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>R_x, object_y=>game_over_y, letter=> "0000001", death_int=>death_int, game_Over_on=>game_Over_on_R);

-- DRAW MOVING PACKMAN *************
    --Always visible
    MovingPac : StillPacManDraw port map(pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>pacman_x, object_y=>pacman_y, animation=> mVariable, visible=> Pac_visible, PacMan_on=>PacMan_on);
    --Pac man's Color
    PacMan_rgb <= x"FFFF00";   -- yellow    
    
    --DRAW Clyde
    --Always visible
    Clyde: GhostDraw port map (pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>clyde_x, object_y=>clyde_y, Ghost_on=>Clyde_on);
    --Clyde's Color
    Clyde_rgb <= x"FF7F50";   -- orange
    
    --Drawing Inky
    --Always visible
    Inky: GhostDraw port map (pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>inky_x, object_y=>inky_y, Ghost_on=>Inky_on);
    Inky_rgb <= x"00FFFF";    -- Cyan
    
    --Pinky
    --Always visible
    Pinky: GhostDraw port map (pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>pinky_x, object_y=>pinky_y, Ghost_on=>Pinky_on);
    Pinky_rgb <= x"FFB8FF";    -- Pink
    
    --Blinky
    --Always visible
    Blinky: GhostDraw port map (pixel_x=> pixel_x, pixel_y=> pixel_y, object_x=>blinky_x, object_y=>blinky_y, Ghost_on=>Blinky_on);
    Blinky_rgb <= x"FF000F";    -- RED
    -- display the image based on who is active
    -- note that the order is important
    process(video_active, GhostGate_on, Border_on0, Border_on1, Border_on2, Border_on3, box_on, Border_rgb, box_rgb, PacMan_rgb, backgrnd_rgb, PacMan_on, Inky_on, Clyde_on, Clyde_rgb, Inky_rgb) is
    begin
        if video_active='0' then
            rgb <= x"00FFFF"; --blank
        else
            --Drawing Everything Else
            if Border_on0='1' or Border_on1='1' or Border_on2='1' or Border_on3='1' then
                rgb <= Border_rgb;
            elsif GhostGate_on = '1' then
                rgb<= GhostGate_rgb;
            elsif stillPacMan_on0='1' or stillPacMan_on1='1' or stillPacMan_on2='1' then
                rgb <= PacMan_rgb;
            else
                rgb <= backgrnd_rgb; -- x"000000"; -- black background
            end if;
            --Drawing Maze Walls
            wallon : for i in 0 to wall_num-1 loop
                if Wall_on(i)='1' then
                    rgb <=border_rgb;
                end if;
            end loop wallon;
            --Drawing dots
            Doton : for i in 0 to dot_num-1 loop
                if Dot_on(i)='1' then
                    rgb <= x"FFFFFF";
                end if;
            end loop doton;
            if Clyde_on='1' then
                rgb<= Clyde_rgb;
            elsif Inky_on='1' then
                rgb<= Inky_rgb;
            elsif Blinky_on='1' then
                rgb<= Blinky_rgb;
            elsif Pinky_on='1' then
                rgb<= Pinky_rgb;
            elsif PacMan_on='1' then
                rgb <= PacMan_rgb;
            elsif portal_on ='1' then
                rgb <= x"88e23b";
                
            --Drawing Game over bit
            elsif game_over_on_G='1' or game_over_on_A='1' or game_over_on_M='1' or game_over_on_E='1' or game_over_on_O='1' or game_over_on_V='1' or game_over_on_E1='1' or game_over_on_R='1' then
                    --Making game over Red
                    rgb<= blinky_rgb;
            end if;
        end if;
    end process;

    --Keeping track of score
    process
    begin
     wait on score_out_arr;
     dot_score: for i in 0 to dot_num - 1 loop
            if (score_out_arr(i)='1' and score_out_arr_i(i)='1') then
                score_out_i <= score_out_i+1;
                score_out_arr_i(i)<='0';
             end if;
        end loop dot_score;
        
    end process;
    
    score_out <= score_out_i;

    
    --Making Pac man Disapear after he dies.
    process
    begin
        if death_int<=2 then
            Pac_visible<='1';
        else
            Pac_visible<='0';
        end if;
    end process;
    

end rtl;
