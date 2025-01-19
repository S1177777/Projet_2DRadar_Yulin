LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity servomoteur_avalon is
  
  port(CLK, RST_N: in std_logic;
       COMMANDE : out std_logic;
	   WriteData : in std_logic_vector(31 downto 0);
	   write_n : in std_logic;
	   chipselect : in std_logic);
  
end entity;

architecture BEHAVIOUR of servomoteur_avalon is

signal cpt : integer range 0 to 1000000;
signal cpt_envoi : integer range 0 to 1000000;
signal resultat : std_logic;
signal POSITION : std_logic_vector (7 downto 0);
Begin

  Process(RST_N, clk)
  Begin
    If (RST_N = '0') Then
      cpt <= 0;
      cpt_envoi <= 0;
      resultat <= '0';

    ElsIf Rising_Edge(clk) Then
      If (cpt < 1000000) Then  -- 20ms period (20ns * 1,000,000)
        cpt <= cpt + 1;

        If (cpt_envoi < (50000 + to_integer(unsigned(position)) * 278)) Then
          resultat <= '1'; -- High signal for the required duration
          cpt_envoi <= cpt_envoi + 1;
        Else
          resultat <= '0'; -- Low signal for the remaining period
        End If;

      Else
        cpt <= 0; -- Reset the period counter
        cpt_envoi <= 0; -- Reset the high pulse counter
      End If;
    End If;
  End Process;

process(CLK, RST_N)
begin
	if RST_n = '0' then
		POSITION <= (others =>'0');
	elsif Rising_Edge(CLK) then	
		if chipselect ='1' and write_n = '0' then
			POSITION <= WriteData(7 downto 0);
		end if;
	end if;
end process;

COMMANDE <= resultat;

end architecture;