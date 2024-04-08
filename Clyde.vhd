library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clyde is

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
end Clyde;

architecture ClydeYhunter of Clyde is
        signal count : integer;
        signal clydexx : integer range 0 to 640:=240;
        signal clydeyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    clydexx <= ClydeX;
    clydeyy <= ClydeY;
    xdirr <= PacManx;
    ydirr <= PacMany;
    process
    begin
    if Chase='1' then
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
    ClydeXout <= clydexx;
    ClydeYout <= clydeyy;
end ClydeYhunter;