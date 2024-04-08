
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UserNameWScoreCounterMar19 is
    Port ( rButton : in STD_LOGIC;
           lButton : in STD_LOGIC;
           uButton : in STD_LOGIC;
           dButton : in STD_LOGIC;
           --clk variables
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           --Button on board to increment score
           scoreButton: in STD_LOGIC;
           
           --LED's to ensure buttons are working correctly
           rLED : out STD_LOGIC;
           lLED : out STD_LOGIC;
           uLED : out STD_LOGIC;
           dLED : out STD_LOGIC;
    
            -- Anodes of 7seg Display #1
            D0_AN : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            D0_SEG : out std_logic_vector (7 downto 0);
            --Anodes of 7seg Display #2
            D1_AN : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            D1_SEG : out std_logic_vector (7 downto 0)
           );
end UserNameWScoreCounterMar19;

architecture Behavioral of UserNameWScoreCounterMar19 is
component UserNameSelectorWithJoystick is
Port ( 
    --Pins of the tactile buttons on breadboard
    rButton : in STD_LOGIC;
    lButton : in STD_LOGIC;
    uButton : in STD_LOGIC;
    dButton : in STD_LOGIC;
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    
    --LED's to ensure buttons are working correctly
    rLED : out STD_LOGIC;
    lLED : out STD_LOGIC;
    uLED : out STD_LOGIC;
    dLED : out STD_LOGIC;
    
    -- Anode: Controls which segment is active at any given time
    D0_AN : out std_logic_vector (3 downto 0):= "1111";
    
    D0_SEG : out std_logic_vector (7 downto 0));
end component;

component ButtonPresstoIncreaseScoreCount is
    Port ( button : in STD_LOGIC;
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            --Anodes of 7seg Display
            D1_AN : out std_logic_vector (3 downto 0):= "1111";
            --Cathodes of 7 seg display
            D1_SEG : out std_logic_vector (7 downto 0));
end component;

component ButtonDebouncer is 
Port ( Button : in STD_LOGIC;
       clk : in STD_LOGIC;
       DebouncedButton : out STD_LOGIC);
end component;

signal uButtonO: STD_LOGIC:='1';
signal dButtonO: STD_LOGIC:='1';
signal rButtonO: STD_LOGIC:='1';
signal lButtonO: STD_LOGIC:='1';
signal scoreButtonO: STD_LOGIC:='1';

begin
    DebB1: ButtonDebouncer port map(uButton, clk, uButtonO);
    DebB2: ButtonDebouncer port map(dButton, clk, dButtonO);
    DebB3: ButtonDebouncer port map(rButton, clk, rButtonO);
    DebB4: ButtonDebouncer port map(lButton, clk, lButtonO);
    DebB5: ButtonDebouncer port map(scoreButton, clk, scoreButtonO);


    UserNameSelector: UserNameSelectorWithJoystick port map(rButtonO, lButtonO, uButtonO, dButtonO, clk, rst, rLED, lLED, uLED, dLED, D0_AN, D0_SEG);
    ScoreCounter: ButtonPresstoIncreaseScoreCount port map(scoreButtonO, clk, rst, D1_AN, D1_SEG);
end Behavioral;
