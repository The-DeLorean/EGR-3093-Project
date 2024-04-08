--This entity 
--Rename file **clyde.vhd**

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clyde is

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
end clyde;

architecture clyde_yhunter of Clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=240;
        signal clydeyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    clydexx <= clyde_x;
    clydeyy <= clyde_y;
    xdirr <= pacman_x;
    ydirr <= pacman_y;
    process
    begin
    if chase='1' then
        if rising_edge(clk) then
            count<=count +1;
            if count =2000000 then
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
        end if;
    end if;
    end process;
    --output clyde new position 
    clyde_xout <= clydexx;
    clyde_yout <= clydeyy;
end clyde_yhunter;