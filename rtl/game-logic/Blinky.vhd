
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Blinky is

    port (
        --pacman location
        PacMan_x   : in integer range 0 to 640:=240;
        PacMan_y   : in integer range 0 to 480:=340;
        --blinky location
        Blinky_X    : in integer range 0 to 640:=240;
        Blinky_Y    : in integer range 0 to 480:=100;
        --output new blinky location
        Blinky_Xout : out integer range 0 to 640:=240;
        Blinky_Yout : out integer range 0 to 480:=100;
        clk       : in std_logic;
        --check ghost state
        Chase     : in std_logic;
        Scatter   : in std_logic;
        Retreat   : in std_logic
    );
end Blinky;

architecture Blinkyheadhunter of Blinky is
        signal count : integer;
        signal alternate : integer:=0;
        signal blinkyxx : integer range 0 to 640:=240;
        signal blinkyyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    blinkyxx <= Blinky_X;
    blinkyyy <= Blinky_Y;
    xdirr <= PacMan_x;
    ydirr <= PacMan_y;
    process
    begin
    if rising_edge(clk) then
        if Chase='1' then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --head pacman hunter hard coded values for walls (for now)
                if blinkyxx < xdirr and blinkyyy < ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy+1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx < xdirr and blinkyyy > ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy-1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx > xdirr and blinkyyy < ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy+1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx > xdirr and blinkyyy > ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy-1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx = xdirr and blinkyyy < ydirr then
                    blinkyyy<=blinkyyy+1;
                    alternate <= 0;
                elsif blinkyxx = xdirr and blinkyyy > ydirr then
                    blinkyyy<=blinkyyy-1;
                    alternate <= 0;   
                elsif blinkyxx < xdirr and blinkyyy = ydirr then
                    blinkyxx<=blinkyxx+1;
                    alternate <= 1; 
                elsif blinkyxx > xdirr and blinkyyy = ydirr then
                    blinkyxx<=blinkyxx-1;
                    alternate <= 1; 
                elsif blinkyxx = xdirr and blinkyyy = ydirr then
                    --gameover
                end if;
           end if;
       elsif Scatter='1' then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --Scattering to bot right corner
                if blinkyyy = 6 or (blinkyyy = 150 and (blinkyxx = 240 or blinkyxx = 241)) then
                --do y hunting
                    if blinkyxx > 124 then
                        blinkyxx<=blinkyxx+1;
                    end if; 
                elsif blinkyyy > 6 then
                    blinkyyy<=blinkyyy+1;
                end if;
            end if;
        elsif Retreat='1' then
             count<=count +1;
            if count >=2000000 then
                count<=0;
               --head pacman hunter hard coded values for walls (for now)
                if blinkyxx < xdirr and blinkyyy < ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy-1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx < xdirr and blinkyyy > ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx-1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy+1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx > xdirr and blinkyyy < ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy-1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx > xdirr and blinkyyy > ydirr then
                    if alternate = 1 then
                        blinkyxx<=blinkyxx+1;
                        alternate <= 0;
                    elsif alternate = 0 then
                        blinkyyy<=blinkyyy+1;
                        alternate <= 1;
                    end if;
                elsif blinkyxx = xdirr and blinkyyy < ydirr then
                    blinkyyy<=blinkyyy-1;
                    alternate <= 0;
                elsif blinkyxx = xdirr and blinkyyy > ydirr then
                    blinkyyy<=blinkyyy+1;
                    alternate <= 0;   
                elsif blinkyxx < xdirr and blinkyyy = ydirr then
                    blinkyxx<=blinkyxx-1;
                    alternate <= 1; 
                elsif blinkyxx > xdirr and blinkyyy = ydirr then
                    blinkyxx<=blinkyxx+1;
                    alternate <= 1; 
                elsif blinkyxx = xdirr and blinkyyy = ydirr then
                    --eaten
                end if;
           end if;
               
           --end if;
        end if;
    end if;
    end process;
    --output pinky new position 
    Blinky_Xout <= blinkyxx;
    Blinky_Yout <= blinkyyy;
end Blinkyheadhunter;
