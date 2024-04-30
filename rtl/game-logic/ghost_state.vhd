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


entity ghost_state is
    Port ( 
           start_game : in std_logic;
           clk        : in STD_LOGIC;
           prison_time: in integer;
           pac_death_clyde : in std_logic;
           pac_death_pinky : in std_logic;
           pac_death_blinky : in std_logic;
           pac_death_inky : in std_logic;
           powerup    : in STD_LOGIC;
           ghost_state_vec   : out std_logic_vector(4 downto 0));
end ghost_state;

--IDEA: output semaphores as an active high std logic vector.

architecture Behavioral of ghost_state is

--These signals drive the state machine
--Output that is a vector of 5 bits in order  prison - escape - chase - scatter - retreat
signal ghost_state_vec_i        :  std_logic_vector(4 downto 0);
signal chase_prev      :  std_logic :='0';
signal count          :  integer :=0; 
signal scatter_tracker : integer range 0 to 10:=0;

--Every ghost is in one of three states.  Each of these states 
type Ghost is (prison_state, escape_state,chase_state, scatter_state, reatreat_state);
  
begin
    process (clk, scatter_tracker, powerup)
    variable ghost_state_machine : Ghost;
    begin
       -- if start_game='1' then
            if rising_edge(clk) then
                count<=count+1;
                case ghost_state_machine is
                    --Waiting the prison time in the prison state
                    When prison_state =>
                        if start_game='1' then
                            --count <= count+1;
                            if count >= prison_time  then
                                count<=0;
                                ghost_state_machine := escape_state;
                            end if;
                        end if;
                    --Moving quickly only staying in escape state for 5us
                    When escape_state=> 
                        --count <= count+1;
                        if count =  100000000 then
                            count<=0;
                            ghost_state_machine := chase_state;
                        end if;        
                    --In the chase state for 20s          
                    When chase_state =>
                        if (pac_death_clyde= '1' or pac_death_pinky= '1' or pac_death_blinky= '1' or pac_death_inky= '1') then
                            count <=0;
                            ghost_state_machine := prison_state;
                        elsif scatter_tracker /=10 then
                            --count <=count+1; 
                            if count = 2000000000 then   
                                ghost_state_machine:= scatter_state;
                                count <=0;
                                chase_prev<='1';
                            end if;   
                        else    
                                       
                        end if;
                    When scatter_state => 
                        if scatter_tracker /=10 and chase_prev='1' then
                            scatter_tracker <= scatter_tracker+1;
                            chase_prev<='0';
                        end if;
                        if (pac_death_clyde= '1' or pac_death_pinky= '1' or pac_death_blinky= '1' or pac_death_inky= '1') then
                            count <=0;
                            ghost_state_machine:= prison_state;
                        else
                            --count <=count+1; 
                                if scatter_tracker <5 then 
                                    if count = 700000000 then   
                                        ghost_state_machine:= chase_state;
                                        count <=0;
                                    end if;
                                elsif scatter_tracker <6 then
                                    if count = 500000000 then   
                                        ghost_state_machine:= chase_state;
                                        count <=0;
                                    end if;
                                elsif scatter_tracker =10 then
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
              when prison_state=>
                  ghost_state_vec_i   <="10000";
              when escape_state=>
                  ghost_state_vec_i   <="01000";
              when chase_state =>
                  ghost_state_vec_i   <="00100";
              when scatter_state =>
                  ghost_state_vec_i   <="00010";
              when reatreat_state=>
                  ghost_state_vec_i   <="00001";
          end case;
       -- end if;
    end process;
    
    --output semaphores
    ghost_state_vec <= ghost_state_vec_i;
end Behavioral;
