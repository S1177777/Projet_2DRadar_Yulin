library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; 
use IEEE.STD_LOGIC_UNSIGNED.all;

entity IPtelemetre is
	port(trig : out std_logic;
		 echo : in std_logic;
		 Dist_cm : out STD_LOGIC_VECTOR(9 downto 0);
		 CLK : in Std_logic;
		 Rst_n : in Std_logic);
		 
end entity;

architecture RTL of IPtelemetre is
signal cnt_dist, cnt_trig,cnt_total :integer ;
type StateType is (Init, Go1, Go2, Go3, Go4);
signal State : StateType;

begin

process(Rst_n, clk)
begin
	if Rst_n = '0' then
		State <= Init;
		cnt_dist <= 0;
		cnt_trig <= 0;
		cnt_total <= 0;
		trig <= '0';
		Dist_cm <= "0000000000";
		elsif Rising_Edge(CLK) then

			case State is 
			when Init => 
				Dist_cm <= "0000000000";
				if cnt_trig = 0 then
					trig <= '1';
					--cnt_trig <= cnt_trig + 1;
					State <= Go1;
				end if;

			when Go1 =>
				if cnt_trig = 500 then
					trig <= '0';
					cnt_total <= cnt_total + 1;
					State <= Go2;
				else
					cnt_trig <= cnt_trig + 1;
					State <= Go1;
				end if;

			when Go2 =>
				if echo = '0' then
					cnt_total <= cnt_total + 1;
					State <= Go2;
				elsif echo = '1' then
					cnt_dist <= cnt_dist + 1;
					cnt_total <= cnt_total + 1;
					State <= Go3;
				end if;

			when Go3 =>
				if echo = '1' and cnt_total <= 2000000 then
					cnt_dist <= cnt_dist + 1;
					cnt_total <= cnt_total + 1;
					State <= Go3;
				elsif echo = '0' and cnt_total <= 2000000 then
					cnt_total <= cnt_total + 1;
					if cnt_dist <= 1176470 then
						Dist_cm <= std_logic_vector(to_unsigned(cnt_dist/2941, 10));
						State <= Go4;
					else
						Dist_cm <= std_logic_vector(to_unsigned(400, 10));
						State <= Go4;
					end if;
				elsif cnt_total >= 2000000 then
					Dist_cm <= std_logic_vector(to_unsigned(400, 10));
					cnt_trig <= 0;
					cnt_dist <= 0;
					cnt_total <= 0;
					trig <= '0';
					State <= Init;
				end if;
				
			when Go4 =>
				if cnt_total <= 2000000 then
					cnt_total <= cnt_total + 1;
					State <= Go4;
				elsif cnt_total > 2000000 then
					State <= Init;
					cnt_dist <= 0;
					cnt_trig <= 0;
					cnt_total <= 0;
					trig <= '0';
					
				end if;
		end case;
	end if;
	end process;
end architecture;