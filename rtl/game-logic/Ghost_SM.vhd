----------------------------------------------------------------------------------
-- Company: Point Loma Nazarene University
-- Engineer: Kyle Dramov
-- This module is a state machine that reads various game situations (such as powerup).
-- It drives three semaphores which will indicate to other logic files what ghost behavior ought to be.
-- Create Date: 04/06/2024 09:50:16 AM
-- Design Name: Ghost State Machine
-- Module Name: ghost_state - Behavioral
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

entity ghost_state is
    Port ( 
           start_game : in std_logic;
           clk        : in STD_LOGIC;
           powerup    : in STD_LOGIC;
           chase      : out STD_LOGIC;
           scatter    : out STD_LOGIC;
           Retreat    : out STD_LOGIC);
end ghost_state;

architecture Behavioral of ghost_state is

--These signals drive the state machine
signal chase_i        :  std_logic :='1';
signal scatter_i      :  std_logic :='0';
signal retreat_i      :  std_logic :='0';
signal chase_prev      :  std_logic :='0';
signal count          :  integer :=0; 
signal scatter_tracker : integer range 0 to 4:=0;

--Every ghost is in one of three states.  Each of these states 
type Ghost is (chase_state, scatter_state, reatreat_state);
  
begin
    process (clk, scatter_tracker, powerup)
    variable ghost_state_machine : Ghost;
    begin
        if start_game='1' then
            if rising_edge(clk) then
                case ghost_state_machine is
                    When chase_state =>
                        If powerup= '1' then
                            ghost_state_machine := reatreat_state;
                            count <=0;
                        elsif scatter_tracker /=4 then
                            count <=count+1; 
                            if count = 2000000000 then   
                                ghost_state_machine:= scatter_state;
                                count <=0;
                                chase_prev<='1';
                            end if;   
                        else    
                                       
                        end if;
                    When scatter_state => 
                        if scatter_tracker /=4 and chase_prev='1' then
                            scatter_tracker <= scatter_tracker+1;
                            chase_prev<='0';
                        end if;
                        If powerup= '1' then
                            ghost_state_machine:= reatreat_state;
                            count <=0;
                        else
                            count <=count+1; 
                                if scatter_tracker <3 then 
                                    if count = 700000000 then   
                                        ghost_state_machine:= chase_state;
                                        count <=0;
                                    end if;
                                elsif scatter_tracker <4 then
                                    if count = 500000000 then   
                                        ghost_state_machine:= chase_state;
                                        count <=0;
                                    end if;
                                elsif scatter_tracker =4 then
                                    ghost_state_machine:= chase_state;
                                    count <=0;
                                end if;                            
                        end if;
                    when reatreat_state =>
                        if powerup= '0' then
                            ghost_state_machine:=chase_state;
                        end if;
               end case;    
          end if;  
          
          --assign internal signals based on state
          Case ghost_state_machine is 
              when chase_state =>
                  chase_i   <='1';
                  scatter_i <='0';
                  retreat_i <='0';
              when scatter_state =>
                  chase_i   <='0';
                  scatter_i <='1';
                  retreat_i <='0';
              when reatreat_state=>
                  chase_i   <='0';
                  scatter_i <='0';
                  retreat_i <='1';
          end case;
        end if;
    end process;
    
    --output semaphores
    chase <= chase_i;
    scatter <= scatter_i;
    Retreat <= retreat_i;
end Behavioral;
