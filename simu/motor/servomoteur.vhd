Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

Entity DE10_Lite_Servomoteur Is
  Port (
    -- Host Side
    clk         : In    std_logic;                       -- 50MHz clock
    RST_N     : In    std_logic;                       -- Active-low reset
    position    : In    std_logic_vector(9 downto 0);    -- Position in 0.1°

    -- Telemetre Output Datas
    commande    : Out   std_logic                        -- PWM Command for the servomotor
  );
End Entity;

Architecture RTL of DE10_Lite_Servomoteur Is

  -- Signals
  Signal cpt           : integer range 0 to 1000000 := 0; -- 20ms period counter
  Signal cpt_envoi     : integer range 0 to 1000000 := 0;   -- High pulse width counter
  Signal resultat      : std_logic := '0';                 -- PWM output signal

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

        If (cpt_envoi < (50000 + to_integer(unsigned(position)) * 55)) Then
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

  commande <= resultat;

End Architecture;
