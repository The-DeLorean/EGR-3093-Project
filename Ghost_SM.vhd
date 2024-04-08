----------------------------------------------------------------------------------
-- Company: Point Loma Nazarene University
-- Engineer: Kyle Dramov
-- 
-- Create Date: 04/06/2024 09:50:16 AM
-- Design Name: Ghost State Machine
-- Module Name: Ghost_SM - Behavioral
-- Project Name: PacMan


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ghost_SM is
    Port ( 
           Start_Game : in std_logic;
           clk        : in STD_LOGIC;
           PowerUp    : in STD_LOGIC;
           Chase      : out STD_LOGIC;
           Scatter    : out STD_LOGIC;
           Retreat    : out STD_LOGIC);
end Ghost_SM;

architecture Behavioral of Ghost_SM is
  signal Chase_s        :  std_logic :='1';
  signal Scatter_s      :  std_logic :='0';
  signal Retreat_s      :  std_logic :='0';
  signal ChasePrev      :  std_logic :='0';
  signal count          :  integer :=0; 
  signal ScatterTracker : integer range 0 to 4:=0;
  type Ghost is (GChase, GScatter, GRetreat);
begin
    process (clk, ScatterTracker, PowerUp)
    variable GhostState : Ghost;
    begin
        if Start_Game='1' then
            if rising_edge(clk) then
                case GhostState is
                    When GChase =>
                        If PowerUp= '1' then
                            GhostState := GRetreat;
                            count <=0;
                        elsif ScatterTracker /=4 then
                            count <=count+1; 
                            if count = 2000000000 then   
                                Ghoststate:= GScatter;
                                count <=0;
                                ChasePrev<='1';
                            end if;   
                        else    
                                       
                        end if;
                    When GScatter => 
                        if ScatterTracker /=4 and ChasePrev='1' then
                            ScatterTracker <= ScatterTracker+1;
                            ChasePrev<='0';
                        end if;
                        If PowerUp= '1' then
                            GhostState:= GRetreat;
                            count <=0;
                        else
                            count <=count+1; 
                                if ScatterTracker <2 then 
                                    if count = 700000000 then   
                                        Ghoststate:= GChase;
                                        count <=0;
                                    end if;
                                elsif ScatterTracker <4 then
                                    if count = 500000000 then   
                                        Ghoststate:= GChase;
                                        count <=0;
                                    end if;
                                elsif ScatterTracker =4 then
                                    Ghoststate:= GChase;
                                    count <=0;
                                end if;                            
                        end if;
                    when GRetreat =>
                        if PowerUp= '0' then
                            GhostState:=GChase;
                        end if;
               end case;    
          end if;  
          Case GhostState is 
              when GChase =>
                  Chase_s   <='1';
                  Scatter_s <='0';
                  Retreat_s <='0';
              when GScatter =>
                  Chase_s   <='0';
                  Scatter_s <='1';
                  Retreat_s <='0';
              when GRetreat=>
                  Chase_s   <='0';
                  Scatter_s <='0';
                  Retreat_s <='1';
          end case;
        end if;
    end process;
    
    Chase <= Chase_s;
    Scatter<= Scatter_s;
    Retreat<= Retreat_s;
end Behavioral;
