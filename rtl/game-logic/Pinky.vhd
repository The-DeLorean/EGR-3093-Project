
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pinky is

    port (
        --pacman location
        PacMan_x   : in integer range 0 to 640:=240;
        PacMan_y   : in integer range 0 to 480:=340;
        --pinky location
        Pinky_X    : in integer range 0 to 640:=240;
        Pinky_Y    : in integer range 0 to 480:=100;
        --output new pinky location
        Pinky_Xout : out integer range 0 to 640:=240;
        Pinky_Yout : out integer range 0 to 480:=100;
        clk       : in std_logic;
        --check ghost state
        Chase     : in std_logic;
        Scatter   : in std_logic;
        Retreat   : in std_logic
    );
end Pinky;

architecture PinkyXhunter of Pinky is
        signal count : integer;
        signal pinkyxx : integer range 0 to 640:=240;
        signal pinkyyy : integer range 0 to 480:=100;
        signal xdirr : integer range 0 to 640:=240;
        signal ydirr : integer range 0 to 480:=340;
begin
    pinkyxx <= Pinky_X;
    pinkyyy <= Pinky_Y;
    xdirr <= PacMan_x;
    ydirr <= PacMan_y;
    process
    begin
    if rising_edge(clk) then
        if Chase='1' then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --x pacman hunter hard coded values for walls (for now)
                if pinkyxx = xdirr or (pinkyxx = 150 and (pinkyyy = 240 or pinkyyy = 241)) then
                --do y hunting
                    if pinkyyy < ydirr then
                        pinkyyy<=pinkyyy+1;
                    elsif pinkyyy > ydirr then
                        pinkyyy<=pinkyyy-1;
                    end if;
                elsif pinkyxx < xdirr then
                    pinkyxx<=pinkyxx+1;
                elsif pinkyxx > xdirr then
                    pinkyxx<=pinkyxx-1;
                end if;
           end if;
       elsif Scatter='1' then
            count<=count +1;
            if count >=2000000 then
                count<=0;
               --Scattering to Top Right corner
                if pinkyyy = 6 or (pinkyyy = 150 and (pinkyxx = 240 or pinkyxx = 241)) then
                --do y hunting
                    if pinkyxx > 124 then
                        pinkyxx<=pinkyxx+1;
                    end if; 
                elsif pinkyyy > 6 then
                    pinkyyy<=pinkyyy-1;
                end if;
            end if;
        elsif Retreat='1' then
             count<=count +1;
            if count >=2000000 then
                count<=0;
               --x pacman hunter hard coded values for walls (for now)
                if pinkyxx = xdirr or (pinkyxx = 150 and (pinkyyy = 240 or pinkyyy = 241)) then
                --do y hunting
                    if pinkyyy < ydirr then
                        pinkyyy<=pinkyyy-1;
                    elsif pinkyyy > ydirr then
                        pinkyyy<=pinkyyy+1;
                    end if;
                elsif pinkyxx < xdirr then
                    pinkyxx<=pinkyxx-1;
                elsif pinkyxx > xdirr then
                    pinkyxx<=pinkyxx+1;
                end if;
           end if;
               
           --end if;
        end if;
    end if;
    end process;
    --output pinky new position 
    Pinky_Xout <= pinkyxx;
    Pinky_Yout <= pinkyyy;
end PinkyXhunter;
