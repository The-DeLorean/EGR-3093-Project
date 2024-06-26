
--Rename file **clyde.vhd**
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clyde is

    port (
        right    : in std_logic;
        left     : in std_logic;
        up       : in std_logic;
        down     : in std_logic;
        --pacman location
        pacman_x_int   : in integer range 0 to 640:=240;
        pacman_y_int   : in integer range 0 to 480:=340;
        --clyde location
        clyde_x_int    : in integer range 0 to 640:=240;
        clyde_y_int    : in integer range 0 to 480:=100;
        --output new clyde location
        clyde_x_out : out integer range 0 to 640:=240;
        clyde_y_out : out integer range 0 to 480:=100;
        clk       : in std_logic;
        --check ghost state
        powerup     : in std_logic;
        --p e c s r
        ghost_state_vec     : in std_logic_vector (4 downto 0)
    );
end clyde;

architecture Behavioral of clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=240;
        signal clydeyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
        --top left
        signal t_l_corner : std_logic :='0';
        --top right
        signal t_r_corner : std_logic :='0';
        --bot right
        signal b_r_corner : std_logic :='0';
        --bot left
        signal b_l_corner : std_logic :='0';
begin
    clydexx <= clyde_x_int;
    clydeyy <= clyde_y_int;
    xdirr <= pacman_x_int;
    ydirr <= pacman_y_int;
    process
    begin
    if rising_edge(clk) then
        --chase
        if ghost_state_vec="00100" then
            count<=count +1;
            if count >=2000000 then
                count<=0;
--                if right='0' & down ='0' then
--                    b_r_corner='1';
--                    clydexx<=clydexx-1;
--                elsif b_r_corner ='1' then
--                    clydexx<=clydexx-1;
--                    if down='1' then
--                        clydeyy<=clydeyy+1;
--                        b_r_corner='0';
               --y pacman hunter hard coded values for walls (for now)
               --Add elsif below
               --top left
                if t_l_corner = '1' then
                    clydexx<=clydexx+1;
                    if up = '1' then
                        clydeyy<=clydeyy-1;
                        t_l_corner<='0'; 
                    end if;   
                --top right
                elsif t_r_corner = '1' then
                    clydexx<=clydexx-1;
                    if up = '1' then
                        clydeyy<=clydeyy-1;
                        t_r_corner<='0'; 
                    end if;
                --bot right
                elsif b_r_corner = '1' then
                    clydexx<=clydexx-1;
                    if down = '1' then
                        clydeyy<=clydeyy+1;
                        b_r_corner<='0'; 
                    end if;
                --bot left
                elsif b_l_corner = '1' then
                    clydexx<=clydexx+1;
                    if down = '1' then
                        clydeyy<=clydeyy+1;
                        b_l_corner<='0'; 
                    end if;
                elsif clydeyy = ydirr or (down = '0' and up = '0') then
                --do x hunting
                    if clydexx < xdirr and right = '1' then
                        clydexx<=clydexx+1;
                    elsif clydexx > xdirr and left = '1' then
                        clydexx<=clydexx-1;
                    end if;
                elsif clydeyy < ydirr and down = '1' then
                    clydeyy<=clydeyy+1;
                elsif clydeyy > ydirr and up = '1' then
                    clydeyy<=clydeyy-1;
                --top left corner stuck
                elsif up = '0' and left = '0' then
                    t_l_corner<='1';
                    clydexx<=clydexx+1;
                --top right corner stuck
                elsif up = '0' and right = '0' then
                    t_r_corner<='1';
                    clydexx<=clydexx-1;
                --bot right corner stuck
                elsif down = '0' and right = '0' then
                    b_r_corner<='1';
                    clydexx<=clydexx-1;
                --bot left corner stuck
                elsif down = '0' and left = '0' then
                    b_l_corner<='1';
                    clydexx<=clydexx+1;
                end if;
           end if;
       elsif ghost_state_vec="00010" then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --Scattering to Top LEft corner
                if clydeyy = 6 or (clydeyy = 150 and (clydexx = 240 or clydexx = 241)) then
                --do x hunting
                    if clydexx > 124 then
                        clydexx<=clydexx-1;
                    end if; 
                elsif clydeyy > 6 then
                    clydeyy<=clydeyy-1;
                end if;
            end if;
        --retreat
        elsif ghost_state_vec="00001" then
             count<=count +1;
             if count >=2000000 then
                count<=0;
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
    end process;
    --output clyde new position 
    clyde_x_out <= clydexx;
    clyde_y_out <= clydeyy;
    
    
end Behavioral;
