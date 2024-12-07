library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity pwm_avalon is
    port (
    clk             : in std_ulogic;
    rst             : in std_ulogic;
    -- avalon memory-mapped slave interface
    avs_read        : in std_logic;
    avs_write       : in std_logic;
    avs_address     : in std_logic_vector(1 downto 0);
    avs_readdata    : out std_logic_vector(31 downto 0);
    avs_writedata   : in std_logic_vector(31 downto 0);
    -- external I/O; export to top-level
    blue_output : out std_logic;
    red_output : out std_logic;
    green_output : out std_logic
    );
end entity pwm_avalon;


architecture pwm_avalon_arch of pwm_avalon is 

    component pwm_controller
        generic (
            CLK_PERIOD : time := 20 ns
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            -- PWM repetition period in milliseconds;
            -- datatype (W.F) is individually assigned
            period : in unsigned(31 - 1 downto 0);
            -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
            -- datatype (W.F) is individually assigned
            duty_cycle : in std_logic_vector(18 - 1 downto 0);
            output : out std_logic
        );
        end component pwm_controller;

        signal period  : unsigned(31 - 1 downto 0) := (others => '0');

        signal blue_duty_cycle  : std_logic_vector(18 - 1 downto 0) := (others => '0');

        signal red_duty_cycle  : std_logic_vector(18 - 1 downto 0) := (others => '0');

        signal green_duty_cycle  : std_logic_vector(18 - 1 downto 0) := (others => '0');



    begin


        blue_pwm : component pwm_controller
        port map (
            clk => clk,
            rst => rst,
            period => period,
            duty_cycle => blue_duty_cycle,
            output => blue_output
        );

        red_pwm : component pwm_controller
        port map (
            clk => clk,
            rst => rst,
            period => period,
            duty_cycle => red_duty_cycle,
            output => red_output
        );

        green_pwm : component pwm_controller
        port map (
            clk => clk,
            rst => rst,
            period => period,
            duty_cycle => green_duty_cycle,
            output => green_output
        );

        avalon_register_read : process(clk)
        begin
            if rising_edge(clk) and avs_read = '1' then
                case avs_address is
                when "00" => avs_readdata <= "0" & std_logic_vector(period);

                when "01" => avs_readdata <= "00000000000000" & std_logic_vector(blue_duty_cycle);

                when "10" => avs_readdata <= "00000000000000" & std_logic_vector(red_duty_cycle);

                when "11" => avs_readdata <= "00000000000000" & std_logic_vector(green_duty_cycle);

                when others => avs_readdata <= (others =>'0'); -- return zeros for unused registers

                end case;
            end if;
        end process;

        avalon_register_write : process(clk, rst)
        begin
            if rst = '1' then
                period <= "0001010000000000000000000000000";   -- 2ms period
                
                blue_duty_cycle <= "010110011001100110"; 

                red_duty_cycle <= "010110011001100110";

                green_duty_cycle <= "010110011001100110";

                elsif rising_edge(clk) and avs_write = '1' then
                    case avs_address is
                    when "00" => period <= unsigned(avs_writedata(30 downto 0));

                    when "01" => blue_duty_cycle <= std_logic_vector(avs_writedata(17 downto 0));

                    when "10" => red_duty_cycle <= std_logic_vector(avs_writedata(17 downto 0));

                    when "11" => green_duty_cycle <= std_logic_vector(avs_writedata(17 downto 0));

                    when others => null;
                    end case;
            end if;
        end process;

end architecture pwm_avalon_arch;