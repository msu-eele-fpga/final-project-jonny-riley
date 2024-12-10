library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity led_patterns_avalon is
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
    push_button     : in std_ulogic;
    switches        : in std_ulogic_vector(3 downto 0);
    led             : out std_ulogic_vector(7 downto 0)
    );
end entity led_patterns_avalon;


architecture led_patterns_avalon_arch of led_patterns_avalon is 

    component led_patterns is
        generic(
            SYSTEM_CLOCK_PERIOD : time  := 20 ns);
            port(
            clk             : in std_ulogic; -- system clock
            rst             : in std_ulogic; -- system reset (assume active high, change at top level if needed)
            push_button     : in std_ulogic; -- Pushbutton to change state (assume active high, change at top level if needed)
            switches        : in std_ulogic_vector(3 downto 0); -- Switches that determine the next state to be selected
            hps_led_control : in std_logic; -- Software is in control when asserted (=1)
            base_period     : in unsigned(7 downto 0); -- base transition period in seconds , fixed -point data type (W=8, F=4).
            led_reg         : in std_ulogic_vector(7 downto 0); -- LED register
            led             : out std_ulogic_vector(7 downto 0) -- LEDs on the DE10-Nano board
        );
        end component led_patterns;

        signal hps_led_control  : std_logic := '0';

        signal led_reg  : std_ulogic_vector(7 downto 0) := "11111111";

        signal base_period  : unsigned(7 downto 0) := "00010000";

    begin

        patterns : component led_patterns
		port map (
			clk => clk,
			rst => rst,
			push_button => push_button,
			switches => switches,
			hps_led_control => hps_led_control,
			base_period => base_period,
			led_reg => led_reg,
			led => led
		);

        avalon_register_read : process(clk)
        begin
            if rising_edge(clk) and avs_read = '1' then
                case avs_address is
                when "00" => avs_readdata <= "0000000000000000000000000000000" & hps_led_control;

                when "01" => avs_readdata <= "000000000000000000000000" & std_logic_vector(led_reg);

                when "10" => avs_readdata <= "000000000000000000000000" & std_logic_vector(base_period);

                when others => avs_readdata <= (others =>'0'); -- return zeros for unused registers

                end case;
            end if;
        end process;

        avalon_register_write : process(clk, rst)
        begin
            if rst = '1' then
                hps_led_control <= '0';
                
                led_reg <= "11111111"; 

                base_period <= "00010000";

                elsif rising_edge(clk) and avs_write = '1' then
                    case avs_address is
                    when "00" => hps_led_control <= std_logic(avs_writedata(0));

                    when "01" => led_reg <= std_ulogic_vector(avs_writedata(7 downto 0));

                    when "10" => base_period <= unsigned(avs_writedata(7 downto 0));

                    when others => null;
                    end case;
            end if;
        end process;

end architecture led_patterns_avalon_arch;