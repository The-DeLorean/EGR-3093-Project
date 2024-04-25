--Rename file **clyde.vhd**
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clyde is

    port (
        --pacman location
        pacman_x_int   : in integer range 0 to 640;
        pacman_y_int   : in integer range 0 to 480;
        --clyde location
        clyde_x_int    : in integer range 0 to 640;
        clyde_y_int    : in integer range 0 to 480;
        --output new clyde location
        clyde_x_out : out integer range 0 to 640;
        clyde_y_out : out integer range 0 to 480;
        clk       : in std_logic;
        --check ghost state
        powerup     : in std_logic;
        --p e c s r
        ghost_state_vec     : in std_logic_vector (4 downto 0)
    );
end clyde;

architecture Behavioral of clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=299;
        signal clydeyy : integer range 0 to 480:=202;
        signal xdirr : integer range 0 to 640:=299;
        signal ydirr : integer range 0 to 480:=202;
        --top left
        signal t_l_corner : std_logic :='0';
        --top right
        signal t_r_corner : std_logic :='0';
        --bot right
        signal b_r_corner : std_logic :='0';
        --bot left
        signal b_l_corner : std_logic :='0';
        
        
        --signals for collisions
        signal right_i : std_logic:='1';
        signal left_i : std_logic:='1';
        signal up_i : std_logic:='1';
        signal down_i : std_logic:='1';
        
        --Signal to move ghost back and forth in prison
        signal prison_right : std_logic:='0';
        
        signal ghost_state_vec_i : std_logic_vector(4 downto 0); 
        
        --Collision Signals
        constant rom_depth : natural := 29; --30
        constant rom_width : natural := 26;--27
        
        --Array of Bit to represent map
        type wall_type is array (0 to rom_depth -1) of std_logic_vector(rom_width - 1 downto 0);
        constant walls : wall_type :=(
                                    "00000000000011000000000000",
                                    "01111011111011011111011110",
                                    "01111011111011011111011110",
                                    "01111011111011011111011110",
                                    "00000000000000000000000000",
                                    "01111011011111111011011110",
                                    "01111011011111111011011110",
                                    "00000011000011000011000000",
                                    "11111011111011011111011111",
                                    "00001011111011011111010000",
                                    "00001011000000000011010000",
                                    "00001011011111111011010000",
                                    "11111011010000001011011111",
                                    "00000000010000001000000000",
                                    "11111011010000001011011111",
                                    "00001011011111111011010000",
                                    "00001011000000000011010000",
                                    "00001011011111111011010000",
                                    "11111011011111111011011111",
                                    "00000000000011000000000000",
                                    "01111011111011011111011110",
                                    "01111011111011011111011110",
                                    "00011000000000000000011000",
                                    "11011011011111111011011011",
                                    "11011011011111111011011011",
                                    "00000011000011000011000000",
                                    "01111111111011011111111110",
                                    "01111111111011011111111110",
                                    "00000000000000000000000000"
                                    );
        
        --Integer values to store top left corner and bottom right integer values for when moving right
        signal clyde_loc_x_right_lc :integer range 0 to 30;
        signal clyde_loc_y_right_lc :integer range 0 to 30;
        signal clyde_loc_x_right_rc :integer range 0 to 30;
        signal clyde_loc_y_right_rc :integer range 0 to 30;
        
        --Integer values to store top left corner and bottom rightinteger values for when moving left
        signal clyde_loc_x_left_lc :integer range 0 to 30;
        signal clyde_loc_y_left_lc :integer range 0 to 30;
        signal clyde_loc_x_left_rc :integer range 0 to 30;
        signal clyde_loc_y_left_rc :integer range 0 to 30;
        
        --Integer values to store top left corner and bottom rightinteger values for when moving up
        signal clyde_loc_x_up_lc :integer range 0 to 30;
        signal clyde_loc_y_up_lc :integer range 0 to 30;
        signal clyde_loc_x_up_rc :integer range 0 to 30;
        signal clyde_loc_y_up_rc :integer range 0 to 30;
        
        --Integer values to store top left corner and bottom rightinteger values for when moving down
        signal clyde_loc_x_down_lc :integer range 0 to 30;
        signal clyde_loc_y_down_lc :integer range 0 to 30;
        signal clyde_loc_x_down_rc :integer range 0 to 30;
        signal clyde_loc_y_down_rc :integer range 0 to 30;
        
begin
    clydexx <= clyde_x_int;
    clydeyy <= clyde_y_int;
    xdirr <= pacman_x_int;
    ydirr <= pacman_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    
    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count >=2000000 then
            count<=0;
            
            --Pinky Collision Check
            --Collision check right
            --Calculating pinky's top left for moving right
            clyde_loc_x_right_lc<= (clydexx-124)/14;
            clyde_loc_y_right_lc<= (clydeyy-6)/14;
            --Calculating pinky's bototm right for moving right
            clyde_loc_x_right_rc<= (clydexx-124+2)/14;
            clyde_loc_y_right_rc<= (clydeyy-6+13)/14;
            if (walls(clyde_loc_y_right_lc)(clyde_loc_x_right_lc+1)='1' or walls(clyde_loc_y_right_rc)(clyde_loc_x_right_rc+1)='1') then
                right_i<='0';
            else
                right_i<='1';
            end if;  
            
            --Collision check left
            --Calculating pinky's top left for moving left
            clyde_loc_x_left_lc<= (clydexx-124+11)/14;
            clyde_loc_y_left_lc<= (clydeyy-6)/14;
            --Calculating pinky's bototm right for moving left
            clyde_loc_x_left_rc<= (clydexx-124+13)/14;
            clyde_loc_y_left_rc<= (clydeyy-6+13)/14;
            if (walls(clyde_loc_y_left_lc)(clyde_loc_x_left_lc-1)='1' or  walls(clyde_loc_y_left_rc)(clyde_loc_x_left_rc-1)='1') then
                left_i<='0';
            else
                left_i<='1';
            end if;
            
            --Collision check up
            --Calculating pinky's top left for moving up
            clyde_loc_x_up_lc<= (clydexx-124)/14;
            clyde_loc_y_up_lc<= (clydeyy-6+11)/14;
            --Calculating pinky's bototm right for moving up
            clyde_loc_x_up_rc<= (clydexx-124+13)/14;
            clyde_loc_y_up_rc<= (clydeyy-6+13)/14;
            if (walls(clyde_loc_y_up_lc-1)(clyde_loc_x_up_lc)='1' or walls(clyde_loc_y_up_rc-1)(clyde_loc_x_up_rc)='1') then
                up_i<='0';
            else
                up_i<='1';
            end if;        
            
            --Collision check Down
            --Calculating pinky's top left for moving down
            clyde_loc_x_down_lc<= (clydexx-124)/14;
            clyde_loc_y_down_lc<= (clydeyy-6)/14;
            --Calculating pinky's bototm right for moving down
            clyde_loc_x_down_rc<= (clydexx-124+13)/14;
            clyde_loc_y_down_rc<= (clydeyy-6+2)/14;
            if (walls(clyde_loc_y_down_lc+1)(clyde_loc_x_down_lc)='1' or walls(clyde_loc_y_down_rc+1)(clyde_loc_x_down_rc)='1') then
                down_i<='0';
            else
                down_i<='1';
            end if;
            
            --End Ghost COllision Logic
            
         --prison state
         if ghost_state_vec_i="10000" then   
                if prison_right='1' then
                    clydexx<=clydexx+1;
                    if clydexx >=334 then
                        prison_right<='0';
                    end if;
                else
                    clydexx<=clydexx-1;
                    if clydexx <=264 then
                        prison_right<='1';
                    end if;
                end if;
                clydeyy<=202;
        --Escape state
        elsif ghost_state_vec_i="01000" then
            clydexx<=299;
            clydeyy<=146;
        --chase
        elsif ghost_state_vec_i="00100" then
               --top left
                if t_l_corner = '1' then
                    clydexx<=clydexx+1;
                    if up_i = '1' then
                        clydeyy<=clydeyy-1;
                        t_l_corner<='0'; 
                    end if;   
                --top right
                elsif t_r_corner = '1' then
                    clydexx<=clydexx-1;
                    if up_i = '1' then
                        clydeyy<=clydeyy-1;
                        t_r_corner<='0'; 
                    end if;
                --bot right
                elsif b_r_corner = '1' then
                    clydexx<=clydexx-1;
                    if down_i = '1' then
                        clydeyy<=clydeyy+1;
                        b_r_corner<='0'; 
                    end if;
                --bot left
                elsif b_l_corner = '1' then
                    clydexx<=clydexx+1;
                    if down_i = '1' then
                        clydeyy<=clydeyy+1;
                        b_l_corner<='0'; 
                    end if;
                elsif clydeyy = ydirr or (down_i = '0' or up_i = '0') then
                --do x hunting
                    if clydexx < xdirr and right_i = '1' then
                        clydexx<=clydexx+1;
                    elsif clydexx > xdirr and left_i = '1' then
                        clydexx<=clydexx-1;
                    end if;
                elsif clydeyy < ydirr and down_i = '1' then
                    clydeyy<=clydeyy+1;
                elsif clydeyy > ydirr and up_i = '1' then
                    clydeyy<=clydeyy-1;
                --top left corner stuck
                elsif up_i = '0' and left_i = '0' then
                    t_l_corner<='1';
                    clydexx<=clydexx+1;
                --top right corner stuck
                elsif up_i = '0' and right_i = '0' then
                    t_r_corner<='1';
                    clydexx<=clydexx-1;
                --bot right corner stuck
                elsif down_i = '0' and right_i = '0' then
                    b_r_corner<='1';
                    clydexx<=clydexx-1;
                --bot left corner stuck
                elsif down_i = '0' and left_i = '0' then
                    b_l_corner<='1';
                    clydexx<=clydexx+1;
                end if;
       elsif ghost_state_vec_i="00010" then
               --Scattering to Top LEft corner
                if t_l_corner = '1' then
                    clydexx<=clydexx+1;
                    if up_i = '1' then
                        clydeyy<=clydeyy-1;
                        t_l_corner<='0';
                    end if;
                elsif clydeyy = 6 or up_i = '0' then
                --do x hunting
                    if clydexx > 124 and left_i = '1' then
                        clydexx<=clydexx-1;
                    end if; 
                elsif clydeyy > 6 and up_i ='1' then
                    clydeyy<=clydeyy-1;
                elsif up_i = '0' and left_i = '0' then
                    clydexx<=clydexx+1;
                    t_l_corner<='1';
                end if;
        --retreat
        elsif ghost_state_vec_i="00001" then
               --y pacman hunter hard coded values for walls (for now)
                if clydeyy = ydirr or (clydeyy = 150 and (clydexx = 240 or clydexx = 241)) then
                --do x hunting
                    if clydexx < xdirr then
                        clydexx<=clydexx-1;
                    elsif clydexx > xdirr then
                        clydexx<=clydexx+1;
                    end if;
                elsif clydeyy < ydirr then
                    clydeyy<=clydeyy-1;
                elsif clydeyy > ydirr then
                    clydeyy<=clydeyy+1;
                end if;
           end if;
        end if;
    end if;
    --Keeping clyde in border
    if clydeyy = 5 then
        clydeyy <= 6;
    elsif clydeyy= 399 then
        clydeyy<=398;
    end if;
    if clydexx = 123 then
        clydexx <= 124;
    elsif clydexx= 475 then
        clydexx<=474;
    end if;
    end process;
    --output clyde new position 
    clyde_x_out <= clydexx;
    clyde_y_out <= clydeyy;
    
    
end Behavioral;
