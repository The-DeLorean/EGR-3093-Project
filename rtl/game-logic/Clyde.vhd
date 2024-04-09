--This entity 
--Rename file **clyde.vhd**
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clyde is

    port (
        --pacman location
        PacMan_x   : in integer range 0 to 640:=240;
        PacMan_y   : in integer range 0 to 480:=340;
        --clyde location
        Clyde_X    : in integer range 0 to 640:=240;
        Clyde_Y    : in integer range 0 to 480:=100;
        --output new clyde location
        Clyde_Xout : out integer range 0 to 640:=240;
        Clyde_Yout : out integer range 0 to 480:=100;
        clk       : in std_logic;
        --check ghost state
        Chase     : in std_logic;
        Scatter   : in std_logic;
        Retreat   : in std_logic
    );
end Clyde;

architecture ClydeYhunter of Clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=240;
        signal clydeyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    clydexx <= Clyde_X;
    clydeyy <= Clyde_Y;
    xdirr <= PacMan_x;
    ydirr <= PacMan_y;
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
    Clyde_Xout <= clydexx;
    Clyde_Yout <= clydeyy;
end ClydeYhunter;
