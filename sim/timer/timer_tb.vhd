library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity timer_tb is
end entity timer_tb;

architecture testbench of timer_tb is

    component timer is
        port(
          clk       : in std_logic;
          rst       : in std_logic;
          pb        : in std_logic;
          start     : in std_logic;
          time_out  :  out unsigned(19 downto 0);
          LED       : out std_logic
        );
    end component;

    signal clk_tb       : std_logic  := '0';
    signal rst_tb       : std_logic  := '0';
    signal pb_tb        : std_logic  := '0';
    signal start_tb     : std_logic  := '0';
    signal time_out_tb  : unsigned(19 downto 0);
    signal LED_tb       : std_logic;

    begin 

    dut : component timer
      port map (
        clk      => clk_tb,
        rst      => rst_tb,
        pb       => pb_tb,
        start    => start_tb,
        time_out => time_out_tb,
        LED      => LED_tb
      );

    clk_gen : process is
    begin

        clk_tb <= not clk_tb;
        wait for 10 ns;
    end process clk_gen;

    input_stim : process is 
    begin
        start_tb <= '1';
        wait for 20 ns;
        start_tb <= '0';

        wait for 2000 * 20 ns;

        pb_tb <= '1';
        wait for 20 ns;
        pb_tb <= '0';

        wait for 100 ns;

        start_tb <= '1';
        wait for 20 ns;
        start_tb <= '0';

        wait for 2000 * 20 ns;

        pb_tb <= '1';
        wait for 20 ns;
        pb_tb <= '0';

    end process;

end architecture testbench;