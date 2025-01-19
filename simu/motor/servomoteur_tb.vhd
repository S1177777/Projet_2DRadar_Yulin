Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

Entity DE10_Lite_Servomoteur_tb Is
End Entity;

Architecture Testbench of DE10_Lite_Servomoteur_tb Is

  -- Component Declaration
  Component DE10_Lite_Servomoteur
    Port (
      clk         : In    std_logic;                       -- 50MHz clock
      RST_N     : In    std_logic;                       -- Active-low reset
      position    : In    std_logic_vector(9 downto 0);    -- Position in 0.1°
      commande    : Out   std_logic                        -- PWM Command for the servomotor
    );
  End Component;

  -- Testbench Signals
  Signal clk_tb      : std_logic := '0';
  Signal RST_N_tb  : std_logic := '0';
  Signal position_tb : std_logic_vector(9 downto 0) := (others => '0');
  Signal commande_tb : std_logic;

  -- Clock period
  Constant CLK_PERIOD : time := 20 ns; -- 50MHz clock (20 ns per cycle)

Begin

  -- Instantiate the DUT (Design Under Test)
  UUT : DE10_Lite_Servomoteur
    Port Map (
      clk      => clk_tb,
      RST_N  => RST_N_tb,
      position => position_tb,
      commande => commande_tb
    );

  -- Clock Process
  clk_process : Process
  Begin
    While true Loop
      clk_tb <= '0';
      Wait for CLK_PERIOD / 2;
      clk_tb <= '1';
      Wait for CLK_PERIOD / 2;
    End Loop;
  End Process;

  -- Stimulus Process
  stimulus_process : Process
  Begin
    -- Initial reset
    RST_N_tb <= '0';
    Wait for 100 ns;
    RST_N_tb <= '1';
    Wait for 50 ns;

    -- Test 1: Position 0° (最小角度)
    position_tb <= std_logic_vector(to_unsigned(0, 10));
    Wait for 40 ms; -- 等待足够长的时间来观察 PWM 输出

    -- Test 2: Position 90° (中间角度)
    position_tb <= std_logic_vector(to_unsigned(900, 10));
    Wait for 40 ms;


    -- Test 3: Position 45° (中间值)
    position_tb <= std_logic_vector(to_unsigned(450, 10));
    Wait for 40 ms;

    -- End of simulation
    Wait;
  End Process;

End Architecture;
