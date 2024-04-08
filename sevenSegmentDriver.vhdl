--Controller for the seven segment display
--Receives data for four different digits
--Makes component calls to a decoder which controls the individual segments
--Rename file **sev_seg_driver**

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sev_seg_driver is
  port (
  data_0 : in integer range 0 to 15;
  data_1 : in integer range 0 to 15;
  data_2 : in integer range 0 to 15;
  data_3 : in integer range 0 to 16;
  clk : in STD_LOGIC;
  rst : in STD_LOGIC:='0';
  display_data : out STD_LOGIC_VECTOR(7 downto 0);
  display_digit : out STD_LOGIC_VECTOR(3 downto 0));
end sev_seg_driver;

architecture Behavioral of sev_seg_driver is
   --Internal clock generating 1kHz
   component clock_divider is
   port (clk : in STD_LOGIC; 
     rst : in STD_LOGIC; 
     clk_1k : out STD_LOGIC);
   end component;
   
   --Decoder for seven segment component
   component sev_seg_decoder is
   port(hex_value : in integer range 0 to 16;
   control : in STD_LOGIC_VECTOR (1 downto 0);
   segments : out STD_LOGIC_VECTOR (7 downto 0);
   anodes : out STD_LOGIC_VECTOR (3 downto 0));   
   end component;
   
   --internal signals
   signal hex_value_i : integer range 0 to 16:=0;
   signal control_i : STD_LOGIC_VECTOR (1 downto 0):="00";
   signal clk_1k : STD_LOGIC;
   
begin
    process(data_0, data_1, data_2, data_3, clk_1k) 
    begin
        if (rising_edge(clk_1k)) then 
            --advancing control each cycle and display correect data at that moment
            case control_i is
            when "00"=> control_i <= "01"; 
             hex_value_i <= data_1;
            when "01"=> control_i <= "10"; 
             hex_value_i <= data_2;
            when "10"=> control_i <= "11"; 
             hex_value_i <= data_3;
            when "11"=> control_i <= "00";
             hex_value_i <= data_0;
            end case;
        end if;
    end process;

--Generate the internal clock 
c1: clock_divider port map(clk=> clk, rst=> rst, clk_1k=> clk_1k);
--Transmit signals to decoder
c2: sev_seg_decoder port map(hex_value => hex_value_i, control => control_i, 
                             segments => display_data, anodes => display_digit);
end Behavioral;
