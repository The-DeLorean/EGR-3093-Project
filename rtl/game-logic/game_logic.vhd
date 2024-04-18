----------------------------------------------------------------------------------
-- Company: Point Loma nazarene University
-- Engineer: Dorian Quimby
-- 
-- Create Date: 04/13/2024 08:34:31 PM
-- Design Name: 
-- Module Name: game_logic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This file is a game logic manager module
-- It receives user input and drives components controlling pacman's movements, and thus the ghosts' movements.
-- Dependencies: hdmi_out.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_logic is
    generic (
        OBJECT_SIZE  : natural := 14
    );
    Port (  clk, rst : in std_logic;
            right    : in std_logic;
            left     : in std_logic;
            up       : in std_logic;
            down     : in std_logic;
            pac_moving: in boolean;
            pacman_x        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(240, OBJECT_SIZE));
            pacman_y        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(340, OBJECT_SIZE));
            inky_x          : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
            inky_y          : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
            pinky_x        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
            pinky_y        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
            blinky_x        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
            blinky_y        : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE));
            clyde_x         : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(300, OBJECT_SIZE));
            clyde_y         : out std_logic_vector(OBJECT_SIZE-1 downto 0) := std_logic_vector(to_unsigned(100, OBJECT_SIZE))
         );
end game_logic;

architecture Behavioral of game_logic is
    
    --PacMan Location
    signal pacman_x_int     : integer range 0 to 640:=240; -- starting coordinates (240,340)
    signal pacman_y_int     : integer range 0 to 480:=340; 
    
    --Inky Location
    signal inky_x_int       : integer range 0 to 640:=300; -- starting coordinates (640, 480)
    signal inky_y_int       : integer range 0 to 480:=100;

    --Pinky
    signal pinky_x_int       : integer range 0 to 640:=300; -- starting coordinates (300, 100)
    signal pinky_y_int       : integer range 0 to 480:=100;
    
    --Blinky
    signal blinky_x_int       : integer range 0 to 640:=300; -- starting coordinates (300, 100)
    signal blinky_y_int       : integer range 0 to 480:=100;
    
    --Clyde 
    signal clyde_x_int      : integer range 0 to 640:=100;
    signal clyde_y_int      : integer range 0 to 480:=100;
    
    --ghost state machine semaphores
    constant prison_time : integer:= 5000000;
    signal powerup       : std_logic:='0';
 
    signal clyde_state_vec   : std_logic_vector(4 downto 0);
    signal inky_state_vec   : std_logic_vector(4 downto 0);
    signal pinky_state_vec   : std_logic_vector(4 downto 0);
    signal blinky_state_vec   : std_logic_vector(4 downto 0);
    
    --misc. game data
    signal start_time      : integer;
    signal start_game     : std_logic:='0';
    signal pac_death    : std_logic:='0';
    
    --mouth moving (wokka wokka)
    signal moving              : boolean:=true;
    
    begin
    
    --Ghost State Machine to change between ghost states Prison->Escape->CHASE->SCATTER->Retreat
    --Still Need to make Prison and Escape
    --change ghost state output to one std_logic_vector
    clyde_state_i: entity work.ghost_state(Behavioral)
    port map(   start_game => start_game, 
                clk => clk, 
                prison_time=> prison_time,
                powerup => powerup, 
                ghost_state_vec=> clyde_state_vec);
    pinky_state_i: entity work.ghost_state(Behavioral)
    port map(   start_game => start_game, 
                clk => clk, 
                prison_time=> prison_time,
                powerup => powerup, 
                ghost_state_vec=> pinky_state_vec);
    blinky_state_i: entity work.ghost_state(Behavioral)
    port map(   start_game => start_game, 
                clk => clk, 
                prison_time=> prison_time,
                powerup => powerup, 
                ghost_state_vec=> blinky_state_vec);
    --PacMan port map
    pacman_i: entity work.pacman(Behavioral)
    port map (  clk => clk,
                rst => rst,
                right => right,
                left => left,
                up => up,
                down => down,
                moving => moving,
                moving_out => moving,
                pacman_x_int => pacman_x_int, 
                pacman_y_int => pacman_y_int,
                pacman_x_int_out => pacman_x_int, 
                pacman_y_int_out => pacman_y_int,
                powerup => powerup, 
                pac_death => pac_death);
    
    --drive Pacman position signals
    pacman_x <= std_logic_vector(to_unsigned(pacman_x_int, OBJECT_SIZE));
    pacman_y <= std_logic_vector(to_unsigned(pacman_y_int, OBJECT_SIZE));
    
    --Inky port map
    inky_i: entity work.inky(Behavioral)
    port map (  clk => clk,
                rst => rst,
                right => right,
                left => left,
                up => up,
                down => down,
                moving => moving,
                pacman_x_int => pacman_x_int, 
                pacman_y_int => pacman_y_int,
                inky_x_int => inky_x_int, 
                inky_y_int => inky_y_int,
                inky_x_int_out => inky_x_int, 
                inky_y_int_out => inky_y_int,
                powerup => powerup, 
                ghost_state_vec => inky_state_vec 
                );
                
    --Drive Inky position signals
    inky_x <= std_logic_vector(to_unsigned(inky_x_int, OBJECT_SIZE));
    inky_y <= std_logic_vector(to_unsigned(inky_y_int, OBJECT_SIZE));
    
    --Pinky port map
    pinky_i: entity work.pinky(Behavioral)
    port map (  clk => clk,
                rst => rst,
                right => right,
                left => left,
                up => up,
                down => down,
                moving => moving,
                pacman_x_int => pacman_x_int, 
                pacman_y_int => pacman_y_int,
                pinky_x_int => pinky_x_int, 
                pinky_y_int => pinky_y_int,
                pinky_x_int_out => pinky_x_int, 
                pinky_y_int_out => pinky_y_int,
                powerup => powerup, 
                ghost_state_vec => pinky_state_vec 
                );
                
    --Drive pInky position signals
    pinky_x <= std_logic_vector(to_unsigned(pinky_x_int, OBJECT_SIZE));
    pinky_y <= std_logic_vector(to_unsigned(pinky_y_int, OBJECT_SIZE));
    --Blinky port map
    blinky_i: entity work.blinky(Behavioral)
    port map (  clk => clk,
                rst => rst,
                right => right,
                left => left,
                up => up,
                down => down,
                --moving => moving,
                pacman_x_int => pacman_x_int, 
                pacman_y_int => pacman_y_int,
                blinky_x_int => blinky_x_int, 
                blinky_y_int => blinky_y_int,
                blinky_x_int_out => blinky_x_int, 
                blinky_y_int_out => blinky_y_int,
                powerup => powerup, 
                ghost_state_vec => blinky_state_vec 
                );
                
    --Drive blInky position signals
    blinky_x <= std_logic_vector(to_unsigned(blinky_x_int, OBJECT_SIZE));
    blinky_y <= std_logic_vector(to_unsigned(blinky_y_int, OBJECT_SIZE));
    --Clyde port map 
    clyde_i: entity work.clyde(Behavioral)
    --generic map (SERIES6=>SERIES6)
    port map (  
                right => right,
                left => left,
                up => up,
                down => down,
                pacman_x_int => pacman_x_int, 
                pacman_y_int => pacman_y_int, 
                clyde_x_int => clyde_x_int, 
                clyde_y_int => clyde_y_int,
                clyde_x_out => clyde_x_int, 
                clyde_y_out => clyde_y_int, 
                clk => clk, 
                powerup => powerup, 
                ghost_state_vec => clyde_state_vec
                );
    
    --Drive Clyde position signals
    clyde_x <= std_logic_vector(to_unsigned(clyde_x_int, OBJECT_SIZE));
    clyde_y <= std_logic_vector(to_unsigned(pacman_y_int, OBJECT_SIZE));
    
    clyde_hit: entity work.collides(Behavioral)
    port map (  obj_a_x => pacman_x_int, 
                obj_a_y => pacman_y_int, 
                obj_b_x => clyde_x_int, 
                obj_b_y => clyde_y_int,
                collision => pac_death);
    
    --Game delay/start time process
    process
    begin
        if rising_edge(clk) then
            start_time<=start_time+1;
            if start_time = 1700000000 then --17 secondds
                start_time<=0;
                start_game<='1';
            end if;
        end if;
    end process;

end Behavioral;
