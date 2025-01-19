library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Telemetre_tb is
	
end entity;

architecture Bench of Telemetre_tb is
signal CLK : Std_logic;
signal Rst_n : Std_logic;
signal trig,echo : std_logic;

begin

G1: entity work.IPtelemetre port map (CLK => CLK, Rst_n => Rst_n, echo => echo, trig => trig);

 Clock: process
  begin
    while now <= 200 ms loop
      CLK <= '0';
      wait for 10 NS;
      CLK <= '1';
      wait for 10 NS;
    end loop;
    wait;
  end process;
  
Rst_n <= '0', '1' after 10 NS;

echon : process
  begin
    wait until trig='1';
    wait until trig='0';
    wait for 100 ns;

      echo <= '1';
      wait for 2 ms;
      echo <= '0';

     wait until trig='1';
     wait until trig='0';
     wait for 100 ns;
 
       echo <= '1';
       wait for 5 ms;
       echo <= '0';
      
       wait until trig='1';
       wait until trig='0';
       wait for 100 ns;
   
         echo <= '1';
         wait for 10 ms;
         echo <= '0';
    wait;
  end process;


end architecture;