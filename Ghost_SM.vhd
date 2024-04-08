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
           start_game : in std_logic;
           clk        : in STD_LOGIC;
           powerup    : in STD_LOGIC;
           chase      : out STD_LOGIC;
           scatter    : out STD_LOGIC;
           Retreat    : out STD_LOGIC);
end Ghost_SM;

architecture Behavioral of Ghost_SM is
  signal chase_s        :  std_logic :='1';
  signal scatter_s      :  std_logic :='0';
  signal Retreat_s      :  std_logic :='0';
  signal chasePrev      :  std_logic :='0';
  signal count          :  integer :=0; 
  signal scatterTracker : integer range 0 to 4:=0;
  type Ghost is (Gchase, Gscatter, GRetreat);
begin
    process (clk, scatterTracker, powerup)
    variable GhostState : Ghost;
    begin
        if start_game='1' then
            if rising_edge(clk) then
                case GhostState is
                    When Gchase =>
                        If powerup= '1' then
                            GhostState := GRetreat;
                            count <=0;
                        elsif scatterTracker /=4 then
                            count <=count+1; 
                            if count = 2000000000 then   
                                Ghoststate:= Gscatter;
                                count <=0;
                                chasePrev<='1';
                            end if;   
                        else    
                                       
                        end if;
                    When Gscatter => 
                        if scatterTracker /=4 and chasePrev='1' then
                            scatterTracker <= scatterTracker+1;
                            chasePrev<='0';
                        end if;
                        If powerup= '1' then
                            GhostState:= GRetreat;
                            count <=0;
                        else
                            count <=count+1; 
                                if scatterTracker <2 then 
                                    if count = 700000000 then   
                                        Ghoststate:= Gchase;
                                        count <=0;
                                    end if;
                                elsif scatterTracker <4 then
                                    if count = 500000000 then   
                                        Ghoststate:= Gchase;
                                        count <=0;
                                    end if;
                                elsif scatterTracker =4 then
                                    Ghoststate:= Gchase;
                                    count <=0;
                                end if;                            
                        end if;
                    when GRetreat =>
                        if powerup= '0' then
                            GhostState:=Gchase;
                        end if;
               end case;    
          end if;  
          Case GhostState is 
              when Gchase =>
                  chase_s   <='1';
                  scatter_s <='0';
                  Retreat_s <='0';
              when Gscatter =>
                  chase_s   <='0';
                  scatter_s <='1';
                  Retreat_s <='0';
              when GRetreat=>
                  chase_s   <='0';
                  scatter_s <='0';
                  Retreat_s <='1';
          end case;
        end if;
    end process;
    
    chase <= chase_s;
    scatter<= scatter_s;
    Retreat<= Retreat_s;
end Behavioral;
