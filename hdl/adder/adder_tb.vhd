library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity adder_tb is
end entity adder_tb;

architecture testbench of adder_tb is

  constant CLK_PERIOD : time := 20 ns;

  component adder is
    port(
        clk             : in std_ulogic;
        rst             : in std_ulogic; 
        push_button     : in std_ulogic; 
        amount          : in unsigned(7 downto 0); 
        led             : out std_ulogic_vector(7 downto 0) 
    );
end component;

  -- Testbench singal declerations
  signal clk_tb                 : std_ulogic := '0';
  signal rst_tb                 : std_ulogic := '0';
  signal push_button_tb         : std_ulogic := '0';
  signal amount_tb              : unsigned(7 downto 0) := "00000001";
  signal led_tb                 : std_ulogic_vector(7 downto 0) := (others => '0');

begin

  -- instantiate the adder component
  dut : component adder
    port map (
      clk   => clk_tb,
      rst   => rst_tb,
      push_button => push_button_tb,
      amount => amount_tb,
      led => led_tb      
    );

  clk_gen : process is
  begin

    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;

  end process clk_gen;

  -- Create the simulated pushbutton signal and watch LEDs
  async_stim : process is
  begin
    rst_tb <= '1';
    wait for CLK_PERIOD;
    rst_tb <= '0';

    push_button_tb <= '0';
    wait for 5 * CLK_PERIOD;

    push_button_tb <= '1';
    wait for CLK_PERIOD;

    push_button_tb <= '0';
    wait for 20 * CLK_PERIOD;

    push_button_tb <= '1';
    wait for CLK_PERIOD;

    push_button_tb <= '0';
    wait for 12 * CLK_PERIOD;

    push_button_tb <= '1';
    wait for CLK_PERIOD;

    push_button_tb <= '0';
    wait for 20 * CLK_PERIOD;

    push_button_tb <= '1';
    wait for CLK_PERIOD;

    push_button_tb <= '0';
    wait for 12 * CLK_PERIOD;

    wait;

  end process async_stim;

end architecture testbench;
