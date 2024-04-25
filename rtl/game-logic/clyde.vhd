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
        
        component Ghost_navigation_check is
        Port (  
        Ghost_x_pos        : in integer;
        Ghost_y_pos        : in integer;
        clk                : in std_logic;
        right_collision    : out std_logic;
        left_collision     : out std_logic;
        up_collision       : out std_logic;
        down_collision     : out std_logic
        );
        end component;
        
        --signals for collisions
        signal right_i : std_logic:='1';
        signal left_i : std_logic:='1';
        signal up_i : std_logic:='1';
        signal down_i : std_logic:='1';
        
        --Signal to move ghost back and forth in prison
        signal prison_right : std_logic:='0';
        
        signal ghost_state_vec_i : std_logic_vector(4 downto 0); 
        
begin
    clydexx <= clyde_x_int;
    clydeyy <= clyde_y_int;
    xdirr <= pacman_x_int;
    ydirr <= pacman_y_int;
    ghost_state_vec_i <= ghost_state_vec;
    
    clyde_collide: Ghost_navigation_check port map (ghost_x_pos=>clydexx, ghost_y_pos=>clydeyy, clk=>clk, right_collision=> right_i, left_collision=> left_i, up_collision=> up_i, down_collision=> down_i);
    
    process
    begin
    if rising_edge(clk) then
    count<=count +1;
        if count >=2000000 then
            count<=0;
         --prison stte
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
                elsif clydeyy = ydirr or (down_i = '0' and up_i = '0') then
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
                if t_l_corner = 1 then
                    clydexx<=clydexx+1;
                    if up_i = '1' then
                        clydeyy<=clydeyy-1;
                        t_l_corner<='0';
                    end if;
                elsif clydeyy = 6 or up_i = '0' or down_i = '0' then
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
