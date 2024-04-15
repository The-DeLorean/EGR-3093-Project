
--Rename file **clyde.vhd**
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clyde is

    port (
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
        prison   : in std_logic;
        escape   : in std_logic;
        chase     : in std_logic;
        scatter   : in std_logic;
        retreat   : in std_logic
    );
end clyde;

architecture Behavioral of clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=240;
        signal clydeyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    clydexx <= clyde_x_int;
    clydeyy <= clyde_y_int;
    xdirr <= pacman_x_int;
    ydirr <= pacman_y_int;
    process
    begin
    if rising_edge(clk) then
        if Chase='1' then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --y pacman hunter hard coded values for walls (for now)
                if clydeyy = ydirr or (clydeyy = 150 and (clydexx = 240 or clydexx = 241)) then
                --do x hunting
                    if clydexx < xdirr then
                        clydexx<=clydexx+1;
                    elsif clydexx > xdirr then
                        clydexx<=clydexx-1;
                    end if;
                elsif clydeyy < ydirr then
                    clydeyy<=clydeyy+1;
                elsif clydeyy > ydirr then
                    clydeyy<=clydeyy-1;
                end if;
           end if;
       elsif Scatter='1' then
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
        elsif Retreat='1' then
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
               --other ghosts here (future)
           end if;
        end if;
    end if;
    end process;
    --output clyde new position 
    clyde_x_out <= clydexx;
    clyde_y_out <= clydeyy;
    
    
end Behavioral;