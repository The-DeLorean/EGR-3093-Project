
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LabTask2 is
Port ( 
    --Pins of the tactile buttons on breadboard
    PmodC0 : in STD_LOGIC;
    PmodC1 : in STD_LOGIC;
    PmodC2 : in STD_LOGIC;
    PmodC3 : in STD_LOGIC;
    --Pin for photo resistor input
    PmodC4 : in STD_LOGIC;
    
    
    --Cathode: Controls which segments are active to display hex values
    D0_SEG : out std_logic_vector (7 downto 0);
    
    -- Anode: Controls which segment is active at any given time
    D0_AN : out std_logic_vector (3 downto 0)
 );
end LabTask2;

architecture Behavioral of LabTask2 is

signal mySignal : integer range -2 to 17; --stores hex value with small buffer on either side
signal digitSelect : integer range -2 to 5; --stores which digit is active
component sevSegConverter --duplicate ports from sevSegConverter file
port ( sevSegConv: in integer range -2 to 17; 
D0_SEG1 : out std_logic_vector (7 downto 0));
end component;

begin
    process (PmodC2, PmodC3, digitSelect)--increments/decrements digitSelect variable
    
    --moves right
    begin 
        if PmodC2 = '0' then
        digitSelect <= digitSelect + 1;
        end if;
        
        --moves left
        if PmodC3 = '0' then
        digitSelect <= digitSelect - 1;
        end if;
        
        --"wraps around" left
        if digitSelect = -1 then 
            digitSelect <= 3;
        end if;
        
        if digitSelect = 4 then 
            digitSelect <= 0;
        end if;
    end process;
    
    process (digitSelect)--case statement of digitSelect
    begin
        if PmodC4 = '0' then
            case digitSelect is 
            when 0 => D0_AN <= "1110";
            when 1 => D0_AN <= "1101";
            when 2 => D0_AN <= "1011";
            when 3 => D0_AN <= "0111";
            when others => null;
            end case;
        else 
            D0_AN <= "1111";
        end if;
    end process;


    --Process to add or subtract 1 when a button is pressed  
    process (PmodC0, PmodC1, mySignal)
    begin
        -- Button 0 adds 1 when pressed and does nothing when not pressed
        if PmodC0 = '0' then
            mySignal <= mySignal + 1;
        end if;
        
        if PmodC1 = '0' then
            mySignal <= mySignal - 1;
        end if;
        if mySignal = -1 then 
            mySignal <= 15;
        end if;
        
        if mySignal = 16 then 
            mySignal <= 0;
        end if;
        
    end process;

--makes call to external source
c1: sevSegConverter port map(mySignal, D0_SEG);



end Behavioral;
