
----------------------------------------------------------------------------------




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity UserNameSelectorWithJoystick is
Port ( 
    --Pins of the tactile buttons on breadboard
    rButtonO : in STD_LOGIC;
    lButtonO : in STD_LOGIC;
    uButtonO : in STD_LOGIC;
    dButtonO : in STD_LOGIC;
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    
    --LED's to ensure buttons are working correctly
    rLED : out STD_LOGIC;
    lLED : out STD_LOGIC;
    uLED : out STD_LOGIC;
    dLED : out STD_LOGIC;
    
    -- Anode: Controls which segment is active at any given time
    D0_AN : out std_logic_vector (3 downto 0):= "1111";
    
    D0_SEG : out std_logic_vector (7 downto 0)
    
 );
end UserNameSelectorWithJoystick;

architecture Behavioral of UserNameSelectorWithJoystick is
--Variable that stores the hexvalue to be displayed on each screen.
signal hexBuffer0 : integer range -2 to 17:= 0; --stores hex value with small buffer on either side
signal hexBuffer1 : integer range -2 to 17:= 0; --stores hex value with small buffer on either side
signal hexBuffer2 : integer range -2 to 17:= 0; --stores hex value with small buffer on either side

--Variables to allow for the user name to be chosen
signal userName: STD_LOGIC := '1';
signal digitSelector : integer range 0 to 4:= 0;

--Signals to hold the previous button push
signal u: STD_LOGIC:='1';
signal d: STD_LOGIC:='1';

component sevenSegmentDriver is
  port (
  data0 : in integer range 0 to 16;
  data1 : in integer range 0 to 16;
  data2 : in integer range 0 to 16;
  data3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  displayData : out STD_LOGIC_VECTOR(7 downto 0);
  displayDigit : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component ButtonDebouncer is 
Port ( Button : in STD_LOGIC;
       clk : in STD_LOGIC;
       DebouncedButton : out STD_LOGIC);
end component;

begin
   --Making rButton change the digit selector when userName is being edited
   process
   begin
       if userName= '1' then
          if (falling_edge(rButtonO)) then
            digitSelector <= digitSelector + 1;
            if digitSelector= 4 then
               digitSelector<= 3;   
            end if;
          end if;
       end if;
    end process;

    --Process to add or subtract 1 when a button is pressed  
    process 
    begin
       --If user name editing is active
       if userName= '1' then
         if(rising_edge(clk)) then
         if digitSelector=0 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (uButtonO='0' and u='1' and dButtonO='1') then
                    hexBuffer0<= hexBuffer0 + 1;
                elsif (dButtonO='0' and d='1' and uButtonO='1')then
                    hexBuffer0<= hexBuffer0 - 1;
                else
                --nothing please
                end if;
                u<=uButtonO;
                d<=dButtonO;
                if hexBuffer0 < 0 then 
                    hexBuffer0 <= 15;
                elsif hexBuffer0 > 15 then 
                    hexBuffer0 <= 0;
                end if;
         elsif digitSelector=1 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (uButtonO='0' and u='1' and dButtonO='1') then
                    hexBuffer1<= hexBuffer1 + 1;
                elsif (dButtonO='0' and d='1' and uButtonO='1')then
                    hexBuffer1<= hexBuffer1 - 1;
                else
                --nothing please
                end if;
                u<=uButtonO;
                d<=dButtonO;
                if hexBuffer1 < 0 then 
                    hexBuffer1 <= 15;
                elsif hexBuffer1 > 15 then 
                    hexBuffer1 <= 0;
                end if;
         elsif digitSelector=2 then
                -- Button 0 adds 1 when pressed and does nothing when not pressed
                if (uButtonO='0' and u='1' and dButtonO='1') then
                    hexBuffer2<= hexBuffer2 + 1;
                elsif (dButtonO='0' and d='1' and uButtonO='1')then
                    hexBuffer2<= hexBuffer2 - 1;
                else
                --nothing please
                end if;
                u<=uButtonO;
                d<=dButtonO;
                if hexBuffer2 < 0 then 
                    hexBuffer2 <= 15;
                elsif hexBuffer2 > 15 then 
                    hexBuffer2 <= 0;
                end if;
         elsif digitselector = 3 then
            userName <='0'; 
         end if;
         end if;
       --making nothing happen once userName = 0
       else
         rLed <= NOT(rButtonO);
         lLed <= NOT(lButtonO);
         uLed <= NOT(uButtonO);
         dLed <= NOT(dButtonO);
       end if ;
    end process;
    
    c1: sevenSegmentDriver port map(hexBuffer0, hexBuffer1, hexBuffer2, 16, clk, rst, D0_SEG, D0_AN);
end Behavioral;
