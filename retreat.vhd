library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity retreat is
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
end retreat;

architecture retreat of retreat is
        signal count : integer;
        signal ghostxx : integer range 0 to 640:=240;
        signal ghostyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
        --check if clyde that needs retreat
        signal clydeBool : std_logic;
        
begin
    ghostxx <= Ghostx;
    ghostyy <= Ghosty;
    xdirr <= pacman_x;
    ydirr <= pacman_y;
    clydeBool <= clyde;
    process
    begin
    if rising_edge(clk) then
        count<=count +1;
        if count =5000000 then
            count<=0;
           --y pacman hunter hard coded values for walls (for now)
           if clydeBool = '1' then
                if ghostyy = ydirr or (ghostyy = 150 and (ghostxx = 240 or ghostxx = 241)) then
                --do x hunting
                    if ghostxx < xdirr then
                        ghostxx<=ghostxx-1;
                    elsif ghostxx > xdirr then
                        ghostxx<=ghostxx+1;
                    end if;
                elsif ghostyy < ydirr then
                    ghostyy<=ghostyy-1;
                elsif ghostyy > ydirr then
                    ghostyy<=ghostyy+1;
                end if;
           --other ghosts here (future)
           end if;
       end if;
    end if;
    end process;
    --output ghost new position 
    GhostXout <= ghostxx;
    GhostYout <= ghostyy;
end retreat;