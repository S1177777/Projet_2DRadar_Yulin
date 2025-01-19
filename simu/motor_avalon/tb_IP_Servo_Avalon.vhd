library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_IP_Servo_Avalon is 
end entity;

architecture bench of tb_IP_Servo_Avalon is
    signal clk        : std_logic := '0';
    signal reset_n    : std_logic := '1';
    signal WriteData  : std_logic_vector(31 downto 0) := (others => '0');
    signal write_n    : std_logic := '1';
    signal chipselect : std_logic := '0';
    signal stop       : boolean := FALSE;
begin

-- DUT (Device Under Test) Instantiation
U1: entity work.servomoteur_avalon
    port map(
        clk        => clk,
        RST_N      => reset_n,
        WriteData  => WriteData,
        write_n    => write_n,
        chipselect => chipselect
    );

-- Clock Generation (50MHz)
clk <= '0' when stop else not clk after 10 ns;

-- Reset Generation
reset_gen: process
begin
    -- Apply reset for the first 100ns
    reset_n <= '0';
    wait for 100 ns;
    reset_n <= '1';
    wait;
end process;

-- Stimulus Process for WriteData and Control Signals
stimulus_proc: process
begin
    -- Reset phase
    wait for 120 ns;

    -- Test Case 1: Write 0 to WriteData with valid chipselect and write_n
    chipselect <= '1';
    write_n <= '0';
    WriteData <= std_logic_vector(to_unsigned(0, 32));
    wait for 20 ns;
    write_n <= '1';
    chipselect <= '0';
    wait for 40 ms; -- Observe the behavior for 40ms

    -- Test Case 2: Write 180 to WriteData with valid chipselect and write_n
    chipselect <= '1';
    write_n <= '0';
    WriteData <= std_logic_vector(to_unsigned(180, 32));
    wait for 20 ns;
    write_n <= '1';
    chipselect <= '0';
    wait for 40 ms;

    -- Test Case 3: Write 130 to WriteData with valid chipselect and write_n
    chipselect <= '1';
    write_n <= '0';
    WriteData <= std_logic_vector(to_unsigned(130, 32));
    wait for 20 ns;
    write_n <= '1';
    chipselect <= '0';
    wait for 40 ms;

    -- End simulation
    stop <= TRUE;
    wait;
end process;


end architecture;
